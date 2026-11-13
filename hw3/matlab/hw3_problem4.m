%% AE 520 Homework 3, Problem 4: a heated flowpath with two constrictions
% Calorically perfect ideal gas; T0 in K, q in J/kg, areas as dimensionless ratios.
% The first throat remains supersonic: Mt1=1.20, so At1 is NOT upstream Astar.
% Heating is in a short constant-area section at the second-throat area.
% Initially its inlet Mach is 0.80; M=0.40 is the upstream diffuser station.
% All other smooth sections are isentropic; the normal shock is adiabatic.
% References: L9 p.4 Eq.(27); L10 p.8 Eq.(104), p.9 Eq.(108);
% L12 p.1 Eq.(228), p.4 Eq.(244); L13 pp.7-8 Eqs.(327)-(333).
clear; clc;
gamma=1.4; R=287; cp=gamma*R/(gamma-1); T01=700;
Mt1=1.20; MshockInitial=1.50; MpreInitial=0.80;
opts=optimset('TolX',1e-12,'Display','off');
F=@(M) (1./M).*((2/(gamma+1))*(1+(gamma-1)*M.^2/2)).^((gamma+1)/(2*(gamma-1)));
Pi=@(M) (((gamma+1)*M.^2)./((gamma-1)*M.^2+2)).^(gamma/(gamma-1)).* ...
    ((gamma+1)./(2*gamma*M.^2-(gamma-1))).^(1/(gamma-1));
% Ratio of local stagnation temperature to its sonic Rayleigh reference.
rayleighT0=@(M) 2*(gamma+1)*M.^2.*(1+(gamma-1)*M.^2/2)./(1+gamma*M.^2).^2;
PiInitial=Pi(MshockInitial); PiLimit=Pi(Mt1);
At2original_AstarUp=F(MpreInitial)/PiInitial;
At2original_At1=At2original_AstarUp/F(Mt1);
fprintf('Original At2/At1 = %.12f; F(Mt1) = %.12f (not unity)\n',At2original_At1,F(Mt1));

% (a): fixed shock and original area, add heat until exit M=1.
T0star_a=T01/rayleighT0(MpreInitial);
qa=cp*(T0star_a-T01);
fprintf('(a) Sonic T0 = %.9f K; heat required = %.9f kJ/kg\n',T0star_a,qa/1000);

% (b): without heating, fixed-shock downstream Astar is fixed.
areaRatio_b=1/F(MpreInitial); reduction_b=1-areaRatio_b;
fprintf('(b) At2_new/At2_original = %.12f; fractional reduction = %.12f (%.9f percent)\n', ...
    areaRatio_b,reduction_b,100*reduction_b);

% (c): the limiting upstream normal shock has M=1.20.
% Weaker shock raises downstream p0, decreases Astar before heating, and
% therefore lowers the pre-heating subsonic Mach at the fixed second throat.
Fpre=F(MpreInitial)*PiLimit/PiInitial;
MpreLimit=fzero(@(M) F(M)-Fpre,[1e-7,1],opts);
T0star_c=T01/rayleighT0(MpreLimit);
qcTotal=cp*(T0star_c-T01); qcAdditional=qcTotal-qa;
fprintf('(c) Limiting pre-heating Mach at second throat = %.12f\n',MpreLimit);
fprintf('Sonic T0 = %.9f K; maximum TOTAL heat = %.9f kJ/kg\n',T0star_c,qcTotal/1000);
fprintf('Additional heat beyond first thermal choking = %.9f kJ/kg\n',qcAdditional/1000);

% (d): no heat; limiting second throat equals Astar behind the M=1.20 shock.
areaRatio_d=PiInitial/(PiLimit*F(MpreInitial)); reduction_d=1-areaRatio_d;
At2limit_At1=areaRatio_d*At2original_At1;
fprintf('(d) At2_limit/At2_original = %.12f; fractional reduction = %.12f (%.9f percent)\n', ...
    areaRatio_d,reduction_d,100*reduction_d);
fprintf('At2_limit/At1 = %.12f\n',At2limit_At1);
assert(abs(F(MpreLimit)-Fpre)<1e-9);
assert(MpreLimit>0 && MpreLimit<MpreInitial && PiLimit>PiInitial);
assert(qcTotal>qa && qa>0 && reduction_d>reduction_b && reduction_d<1);
assert(abs(At2limit_At1*F(Mt1)*PiLimit-1)<1e-10);
% Independent Rayleigh mass/momentum calculation with an arbitrary common
% pre-heating pressure datum, p_pre=1 Pa. Its value cancels from the result.
for pair=[MpreInitial,qa;MpreLimit,qcTotal].'
    m=pair(1); q=pair(2);
    Tpre=T01/(1+(gamma-1)*m^2/2); ppre=1;
    rho=ppre/(R*Tpre); u=m*sqrt(gamma*R*Tpre);
    G=rho*u; momentum=ppre+rho*u^2;
    pstar=momentum/(1+gamma); Tstar=gamma*pstar^2/(R*G^2);
    qIndependent=cp*((1+(gamma-1)/2)*Tstar-T01);
    assert(abs(qIndependent-q)<1e-5,'Rayleigh heat balance failed.');
end
fprintf('All Problem 4 checks passed.\n');
