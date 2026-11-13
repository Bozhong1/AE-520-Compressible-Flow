%% AE 520 Homework 3, Problem 2: a normal shock in a choked nozzle
% Calorically perfect ideal gas; absolute pressures in Pa, temperatures in K.
% All smooth sections are steady, adiabatic, inviscid, and isentropic.
% References: L12 p.1 Eq.(228), pp.3-4 Eqs.(240)-(246), p.6 Eq.(260);
% L9 p.3 Eq.(21), p.4 Eq.(27); L10 p.8 Eq.(101).
clear; clc;
gamma = 1.4; R = 287;
p01 = 800e3; T01 = 600; Ae_At = 6; As_At_initial = 3;
opts = optimset('TolX',1e-12,'Display','off');
initial = nozzleState(As_At_initial,Ae_At,p01,T01,gamma,opts);
pb = 200e3;
% With an internal shock the downstream exit is subsonic, hence pe = pb.
% The shock-location bracket is the physical diverging section, 1 < As/At <= 6.
exitShock = nozzleState(Ae_At,Ae_At,p01,T01,gamma,opts);
nearThroat = nozzleState(1+1e-7,Ae_At,p01,T01,gamma,opts);
assert(pb>exitShock.pe && pb<nearThroat.pe,'No internal-shock root in the nozzle.');
% Direct exit calculation: mass flow at the sonic throat equals exit mass flow.
% With y=Me^2 and alpha=(gamma-1)/2, y+alpha*y^2=C^2.
C = (p01/pb)/Ae_At*(2/(gamma+1))^((gamma+1)/(2*(gamma-1)));
alpha = (gamma-1)/2;
y = 2*C^2/(1+sqrt(1+4*alpha*C^2)); % algebraically equivalent, avoids cancellation
MeDirect = sqrt(y); p02Direct = pb*(1+alpha*y)^(gamma/(gamma-1));
MsupExit = machFromArea(Ae_At,'supersonic',gamma,opts);
Pi = @(M) (((gamma+1)*M.^2)./((gamma-1)*M.^2+2)).^(gamma/(gamma-1)).* ...
    ((gamma+1)./(2*gamma*M.^2-(gamma-1))).^(1/(gamma-1));
M1sDirect = fzero(@(M) Pi(M)-p02Direct/p01,[1,MsupExit],opts);
As_At_new = (1/M1sDirect)*((2/(gamma+1))*(1+alpha*M1sDirect^2))^ ...
    ((gamma+1)/(2*(gamma-1)));
new = nozzleState(As_At_new,Ae_At,p01,T01,gamma,opts);
% Independent nested calculation: match the back pressure at a trial shock area.
As_At_nested = fzero(@(x) exitPressure(x,Ae_At,p01,T01,gamma,opts)-pb, ...
    [1+1e-7,Ae_At],opts);
assert(abs(As_At_nested-As_At_new)<1e-9);
assert(abs(new.Me-MeDirect)<1e-10 && abs(new.p0e-p02Direct)/p02Direct<1e-10);
fprintf('Direct exit solution: C=%.12f, y=Me^2=%.12f\n',C,y);
fprintf('Initial normal shock:\n'); disp(struct2table(initial));
fprintf('Normal shock at lowered pb = 200 kPa:\n'); disp(struct2table(new));
fprintf('Shock-at-exit back pressure = %.9f kPa\n',exitShock.pe/1000);
MsupExit = machFromArea(Ae_At,'supersonic',gamma,opts);
pSupExit = p01/(1+(gamma-1)*MsupExit^2/2)^(gamma/(gamma-1));
fprintf('Isentropic supersonic exit after shock leaves: Me=%.12f, pe=%.9f kPa\n', ...
    MsupExit,pSupExit/1000);
fprintf('A supersonic exit adjusts to pb through external expansion/compression waves.\n');
fprintf('pe<pb is overexpanded; pe>pb is underexpanded.\n');
assert(abs(new.pe-pb)/pb<1e-10 && new.As_At>initial.As_At);
assert(new.Me>0 && new.Me<1 && new.M1s>1 && new.M2s<1);
% Independent mass-flux check, normalized by physical throat area At.
Tt = T01/(1+(gamma-1)/2); pt = p01/(1+(gamma-1)/2)^(gamma/(gamma-1));
mdot_At = pt/(R*Tt)*sqrt(gamma*R*Tt);
for v = [initial,new]
    rhoe = v.pe/(R*v.Te); ue = v.Me*sqrt(gamma*R*v.Te);
    assert(abs(rhoe*ue*Ae_At-mdot_At)/mdot_At<1e-10);
    assert(v.p02_p01>0 && v.p02_p01<1 && v.Astar2_At>1);
end
fprintf('All Problem 2 checks passed.\n');

function p = exitPressure(x,AeAt,p01,T01,g,opts)
    s = nozzleState(x,AeAt,p01,T01,g,opts); p = s.pe;
end
function s = nozzleState(x,AeAt,p01,T01,g,opts)
    M1 = machFromArea(x,'supersonic',g,opts);
    M2 = sqrt((1+(g-1)*M1^2/2)/(g*M1^2-(g-1)/2));
    Pi = (((g+1)*M1^2)/((g-1)*M1^2+2))^(g/(g-1))* ...
        ((g+1)/(2*g*M1^2-(g-1)))^(1/(g-1));
    Astar2At = 1/Pi; AeAstar2 = AeAt/Astar2At;
    Me = machFromArea(AeAstar2,'subsonic',g,opts);
    Te = T01/(1+(g-1)*Me^2/2); p02 = p01*Pi;
    pe = p02/(1+(g-1)*Me^2/2)^(g/(g-1));
    s = struct('As_At',x,'M1s',M1,'M2s',M2,'p02_p01',Pi, ...
        'p02_Pa',p02,'Astar2_At',Astar2At,'Ae_Astar2',AeAstar2, ...
        'Me',Me,'Te',Te,'T0e',T01,'pe',pe,'p0e',p02,'pb',pe);
end
function M = machFromArea(ratio,branch,g,opts)
    area = @(m) (1./m).*((2/(g+1))*(1+(g-1)*m.^2/2)).^((g+1)/(2*(g-1)));
    assert(ratio>=1-1e-12,'Area ratio must be at least one.');
    if abs(ratio-1)<1e-13, M=1; return; end
    if strcmp(branch,'subsonic'), bracket=[1e-7,1]; else, bracket=[1,10]; end
    M=fzero(@(m) area(m)-ratio,bracket,opts);
    assert(abs(area(M)-ratio)<1e-9,'Area-Mach root residual too large.');
end
