%% AE 520 Homework 3, Problem 3: inlet starting, back pressure, and overspeed
% Calorically perfect ideal gas, gamma=1.4. All pressures are absolute Pa.
% Temperature is not specified and is unnecessary for these area/pressure ratios.
% Full captured flow is assumed; smooth portions are steady and isentropic.
% References: L13 pp.1-2 Eqs.(267)-(282); L12 p.1 Eq.(228), p.4 Eq.(245);
% L9 p.3 Eq.(21), p.4 Eq.(27); L12 p.2 Eq.(237).
clear; clc;
gamma=1.4; Minf=3; At_Ac=0.72; Ae_At=1.50; p0inf=500e3;
opts=optimset('TolX',1e-12,'Display','off');
F=@(M) (1./M).*((2/(gamma+1))*(1+(gamma-1)*M.^2/2)).^((gamma+1)/(2*(gamma-1)));
Pi=@(M) (((gamma+1)*M.^2)./((gamma-1)*M.^2+2)).^(gamma/(gamma-1)).* ...
    ((gamma+1)./(2*gamma*M.^2-(gamma-1))).^(1/(gamma-1));
K=@(M) 1./(F(M).*Pi(M));

% (a): equality is the marginal one-dimensional self-starting condition.
Kdesign=K(Minf); selfStarting=At_Ac>=Kdesign;
MpostCapture=sqrt((1+(gamma-1)*Minf^2/2)/(gamma*Minf^2-(gamma-1)/2));
fprintf('(a) Kantrowitz minimum At/Ac = %.12f; prescribed At/Ac = %.4f\n',Kdesign,At_Ac);
fprintf('Self-starting under the stated idealized criterion: %d\n',selfStarting);
assert(abs(Kdesign-1/F(MpostCapture))<1e-12);

% (b): an already-started inlet follows the supersonic branch to its throat.
Mt=fzero(@(M) F(M)-At_Ac*F(Minf),[1,Minf],opts);
MpostThroat=sqrt((1+(gamma-1)*Mt^2/2)/(gamma*Mt^2-(gamma-1)/2));
recovery=Pi(Mt); p02=p0inf*recovery;
Ae_AstarPost=Ae_At*F(Mt)*recovery;
Me=fzero(@(M) F(M)-Ae_AstarPost,[1e-7,1],opts);
pbmax=p02/(1+(gamma-1)*Me^2/2)^(gamma/(gamma-1));
p0loss=p0inf-p02;
fprintf('(b) Limiting throat shock: Mt=%.12f, M_after=%.12f\n',Mt,MpostThroat);
fprintf('Ae/Astar_post=%.12f; Me=%.12f\n',Ae_AstarPost,Me);
fprintf('Maximum estimated back pressure = %.9f kPa\n',pbmax/1000);
fprintf('Pressure recovery = %.12f; downstream p0 = %.9f kPa\n',recovery,p02/1000);
fprintf('Stagnation pressure loss = %.9f kPa (%.9f percent)\n',p0loss/1000,100*(1-recovery));

% (c): start at the equality K(Moverspeed)=0.68, then return to design M=3.
At_Ac_alt=0.68;
Mstart=fzero(@(M) K(M)-At_Ac_alt,[Minf,8],opts);
MtAlt=fzero(@(M) F(M)-At_Ac_alt*F(Minf),[1,Minf],opts);
recoveryAlt=Pi(MtAlt); p02Alt=p0inf*recoveryAlt;
gain=recoveryAlt-recovery; relativeGain=gain/recovery;
fprintf('(c-i) Minimum overspeed Mach = %.12f\n',Mstart);
fprintf('(c-ii) Throat Mach after returning to M_inf=3 = %.12f\n',MtAlt);
fprintf('(c-iii) Throat-shock recovery = %.12f; p02 at design = %.9f kPa\n',recoveryAlt,p02Alt/1000);
fprintf('(c-iv) Recovery gain = %.12f = %.9f percentage points = %.9f percent relative\n', ...
    gain,100*gain,100*relativeGain);
fprintf('At common design p0inf, recovered-pressure gain = %.9f kPa\n',(p02Alt-p02)/1000);
assert(abs(K(Mstart)-At_Ac_alt)<1e-10);
assert(abs(F(Mt)-At_Ac*F(Minf))<1e-9 && abs(F(MtAlt)-At_Ac_alt*F(Minf))<1e-9);
assert(Mt>1 && MtAlt>1 && MpostThroat<1 && Me>0 && Me<1);
assert(abs(F(MpostThroat)-F(Mt)*recovery)<1e-9);
assert(abs(F(Me)-Ae_AstarPost)<1e-9);
assert(recoveryAlt>recovery && recoveryAlt<1 && pbmax<p02);
fprintf('All Problem 3 checks passed. The throat-shock unstart criterion is the prescribed idealized estimate.\n');
