"""Independent HW3 numerical checks; Python standard library only.

Run: python verify_hw3.py [--json output.json]
All temperatures and pressures are absolute. SI units are used in calculations.
Roots are selected on explicit physical branches with bisection width <= 1e-13.
Unlike the MATLAB scripts, normal-shock recovery is obtained from entropy and
Rayleigh sonic heating is independently obtained from mass/momentum balances.
"""
from __future__ import annotations
import argparse
import json
import math
from pathlib import Path

GAMMA = 1.4
R = 287.0
CP = GAMMA * R / (GAMMA - 1)
ROOT_TOL = 1e-13


def bisect(fun, lo, hi):
    flo, fhi = fun(lo), fun(hi)
    if flo == 0:
        return lo
    if fhi == 0:
        return hi
    if flo * fhi > 0:
        raise ValueError(f"Root is not bracketed on [{lo}, {hi}]")
    for _ in range(200):
        mid = (lo + hi) / 2
        fm = fun(mid)
        if fm == 0 or hi - lo <= ROOT_TOL:
            return mid
        if flo * fm > 0:
            lo, flo = mid, fm
        else:
            hi = mid
    raise RuntimeError("Bisection did not converge")


def tau(m):
    return 1 + (GAMMA - 1) * m * m / 2


def area_ratio(m):
    return ((2 / (GAMMA + 1)) * tau(m)) ** ((GAMMA + 1) / (2 * (GAMMA - 1))) / m


def state(m, p0=1.0, t0=700.0):
    t = t0 / tau(m)
    p = p0 / tau(m) ** (GAMMA / (GAMMA - 1))
    rho = p / (R * t)
    u = m * math.sqrt(GAMMA * R * t)
    return p, t, rho, u


def mass_flux(m, p0=1.0, t0=700.0):
    p, t, rho, u = state(m, p0, t0)
    return rho * u


def normal_shock(m):
    p, t, rho, u = state(m)
    compression = (GAMMA + 1) * m * m / (2 + (GAMMA - 1) * m * m)
    p2 = p * (1 + 2 * GAMMA / (GAMMA + 1) * (m * m - 1))
    rho2 = rho * compression
    u2 = u / compression
    t2 = p2 / (rho2 * R)
    m2 = u2 / math.sqrt(GAMMA * R * t2)
    ds = CP * math.log(t2 / t) - R * math.log(p2 / p)
    recovery = math.exp(-ds / R)
    assert abs(rho * u - rho2 * u2) < 1e-12
    assert abs(p + rho * u*u - p2 - rho2 * u2*u2) < 1e-12
    assert abs(CP*t + u*u/2 - CP*t2 - u2*u2/2) < 1e-7
    return m2, recovery, ds


def sonic_heat(m, t0=700.0):
    # Set p_pre=1 Pa; the pressure datum cancels from the sonic temperature.
    t = t0 / tau(m)
    rho = 1 / (R * t)
    u = m * math.sqrt(GAMMA * R * t)
    flux = rho * u
    momentum = 1 + rho * u * u
    pstar = momentum / (1 + GAMMA)
    tstar = GAMMA * pstar*pstar / (R * flux*flux)
    return CP * (tau(1) * tstar - t0), tau(1) * tstar


def rayleigh_t0_ratio(m):
    return 2*(GAMMA+1)*m*m*tau(m)/(1+GAMMA*m*m)**2


def solve():
    results = {"inputs": {"gamma": GAMMA, "R_J_kgK": R, "cp_J_kgK": CP,
                          "root_interval_tolerance": ROOT_TOL}}
    # Problem 1: independent sonic endpoints from the governing balances.
    m1, t1, p1, a1area = 0.25, 300.0, 100000.0, 0.10
    a1 = math.sqrt(GAMMA*R*t1)
    u1 = m1*a1
    rho1 = p1/(R*t1)
    t01, p01 = t1*tau(m1), p1*tau(m1)**(GAMMA/(GAMMA-1))
    mdot = rho1*u1*a1area
    astar = a1area/area_ratio(m1)
    flux = rho1*u1
    p_r = (p1+rho1*u1*u1)/(1+GAMMA)
    t_r = GAMMA*p_r*p_r/(R*flux*flux)
    t_f = t01/tau(1)
    p_f = flux*math.sqrt(R*t_f/GAMMA)
    p_s = p01/tau(1)**(GAMMA/(GAMMA-1))
    p1records = {}
    for name,m,t,p,area in [("initial",m1,t1,p1,a1area),
                           ("rayleigh",1,t_r,p_r,a1area),
                           ("fanno",1,t_f,p_f,a1area),
                           ("isentropic",1,t_f,p_s,astar)]:
        a = math.sqrt(GAMMA*R*t)
        u = m*a
        rho = p/(R*t)
        record = dict(M=m,T=t,p=p,a=a,u=u,rho=rho,T0=t*tau(m),
                      p0=p*tau(m)**(GAMMA/(GAMMA-1)),A=area,
                      mdot=rho*u*area,h=CP*t,ds=CP*math.log(t/t1)-R*math.log(p/p1))
        assert abs(record['mdot']/mdot-1)<1e-12
        p1records[name] = record
    p1records['initial'].update(area_ratio=area_ratio(m1),Astar=astar)
    p1records['rayleigh']['q'] = CP*(p1records['rayleigh']['T0']-t01)
    assert abs(p1records['isentropic']['ds'])<1e-9
    assert p1records['rayleigh']['ds']>0 and p1records['fanno']['ds']>0
    mmax = 1/math.sqrt(GAMMA)
    pmax = p1*(1+GAMMA*m1*m1)/(1+GAMMA*mmax*mmax)
    tmax = t1*(mmax/m1)**2*((1+GAMMA*m1*m1)/(1+GAMMA*mmax*mmax))**2
    p1records['rayleigh_max_h'] = dict(M=mmax,T=tmax,h=CP*tmax,
                                      ds=CP*math.log(tmax/t1)-R*math.log(pmax/p1))
    results['P1'] = p1records

    # Problem 2: direct exit mass flux and a separate nested shock-area root.
    def nozzle(as_at):
        m1s = bisect(lambda m: area_ratio(m)-as_at,1,10)
        m2s,recovery,_ = normal_shock(m1s)
        p02 = 800000*recovery
        ae_astar2 = 6*recovery
        me = bisect(lambda m: area_ratio(m)-ae_astar2,1e-7,1)
        pe,te,_,_ = state(me,p02,600)
        return dict(As_At=as_at,M1s=m1s,M2s=m2s,p02_p01=recovery,p02=p02,
                    Astar2_At=1/recovery,Ae_Astar2=ae_astar2,Me=me,Te=te,
                    T0e=600,p0e=p02,pe=pe,pb=pe)
    initial = nozzle(3)
    exitshock = nozzle(6)
    # Determine Me from the absolute exit static pressure using mass conservation.
    mdot_at = mass_flux(1,800000,600)
    me_direct = bisect(lambda m: 200000/(R*(600/tau(m)))*m*
                       math.sqrt(GAMMA*R*600/tau(m))*6-mdot_at,1e-7,1)
    p02_direct = 200000*tau(me_direct)**(GAMMA/(GAMMA-1))
    m1s_direct = bisect(lambda m: normal_shock(m)[1]-p02_direct/800000,1,exitshock['M1s'])
    asat = area_ratio(m1s_direct)
    new = nozzle(asat)
    nested = bisect(lambda x: nozzle(x)['pe']-200000,1+1e-7,6)
    assert abs(asat-nested)<1e-9
    assert abs(new['pe']/200000-1)<1e-10
    assert abs(new['Me']-me_direct)<1e-10
    for row in (initial,new,exitshock):
        assert abs(mass_flux(row['Me'],row['p0e'],600)*6/mdot_at-1)<1e-10
    p_exit_sup = state(exitshock['M1s'],800000,600)[0]
    results['P2'] = dict(initial=initial,new=new,exit_shock=exitshock,
                         fully_supersonic_exit=dict(Me=exitshock['M1s'],pe=p_exit_sup),
                         independent_nested_As_At=nested)

    # Problem 3: starting capacity evaluated from the post-capture-shock state.
    def kantrowitz(m):
        mpost,_,_ = normal_shock(m)
        return 1/area_ratio(mpost)
    minf,p0inf,atac,aeat = 3.0,500000.0,0.72,1.5
    mt = bisect(lambda m: mass_flux(m)*atac-mass_flux(minf),1,minf)
    mpost,rec,_ = normal_shock(mt)
    p02 = p0inf*rec
    me = bisect(lambda m: mass_flux(m,p02)*(atac*aeat)-mass_flux(minf,p0inf),1e-7,1)
    pbmax = state(me,p02)[0]
    mstart = bisect(lambda m: kantrowitz(m)-0.68,3,8)
    mtalt = bisect(lambda m: mass_flux(m)*0.68-mass_flux(minf),1,minf)
    recalt = normal_shock(mtalt)[1]
    gain = recalt-rec
    mcap,picap,_ = normal_shock(minf)
    assert abs(kantrowitz(minf)-1/(area_ratio(minf)*picap))<1e-12
    assert abs(kantrowitz(mstart)-0.68)<1e-12
    results['P3'] = dict(F3=area_ratio(3),Pi3=picap,K3=kantrowitz(3),
        M_after_capture_shock=mcap,Mt_072=mt,Mt_072_after_shock=mpost,recovery_072=rec,
        Ae_over_Astar_downstream=aeat*area_ratio(mt)*rec,Me_at_max_pb=me,
        p02_Pa=p02,pbmax_Pa=pbmax,p0loss_Pa=p0inf-p02,p0loss_fraction=1-rec,
        Mstart_068=mstart,K_at_Mstart=kantrowitz(mstart),Mt_068=mtalt,
        recovery_068=recalt,recovery_gain_absolute=gain,recovery_gain_percent_points=100*gain,
        recovery_gain_relative_percent=100*gain/rec,p02_068_Pa=p0inf*recalt,p02_gain_Pa=p0inf*gain)

    # Problem 4: hold captured mass flow; solve physical second-throat mass flux.
    pi15 = normal_shock(1.5)[1]
    pi12 = normal_shock(1.2)[1]
    mdot_at1 = mass_flux(1.2)
    at2at1 = mdot_at1/mass_flux(0.8,pi15)
    mpre = bisect(lambda m: mass_flux(m,pi12)*at2at1-mdot_at1,1e-7,1)
    qa,t0a = sonic_heat(0.8)
    qc,t0c = sonic_heat(mpre)
    rb = (mdot_at1/mass_flux(1,pi15))/at2at1
    rd = (mdot_at1/mass_flux(1,pi12))/at2at1
    assert abs(qa-CP*700*(1/rayleigh_t0_ratio(0.8)-1))<1e-7
    assert abs(qc-CP*700*(1/rayleigh_t0_ratio(mpre)-1))<1e-7
    assert abs(area_ratio(mpre)-area_ratio(0.8)*pi12/pi15)<1e-10
    assert qa>0 and qc>qa and 0<mpre<0.8
    results['P4'] = dict(Pi15=pi15,Pi12=pi12,F08=area_ratio(.8),F12=area_ratio(1.2),
        At2_original_over_Astar_upstream=at2at1*area_ratio(1.2),At2_original_over_At1=at2at1,
        rayleigh_T0_ratio_08=rayleigh_t0_ratio(.8),q_a_J_kg=qa,T0star_a_K=t0a,
        area_reduction_b_fraction=1-rb,area_ratio_b=rb,Fpre_c=area_ratio(mpre),Mpre_c=mpre,
        rayleigh_T0_ratio_c=rayleigh_t0_ratio(mpre),q_c_total_J_kg=qc,
        q_c_additional_beyond_a_J_kg=qc-qa,T0star_c_K=t0c,
        area_reduction_d_fraction=1-rd,area_ratio_d=rd,At2_final_d_over_At1=rd*at2at1)
    results['verification'] = 'All conservation, branch, and independent-method assertions passed.'
    return results


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--json',type=Path)
    args = parser.parse_args()
    results = solve()
    text = json.dumps(results,indent=2)
    if args.json:
        args.json.parent.mkdir(parents=True,exist_ok=True)
        args.json.write_text(text,encoding='utf-8')
    print(text)
