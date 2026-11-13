%% AE 520 Homework 3, Problem 1: three routes to a sonic state
% Calorically perfect ideal gas; SI units unless output labels state otherwise.
% Each process starts at the same inlet and has the same mass flow rate.
% The enthalpy datum is h = cp*T. Delta s = s-s1.
% References: L9 notes p.2 (h=cpT, a^2=gamma*R*T), p.4 Eq.(25);
% L10 p.7 Eqs.(91),(96), p.8 Eqs.(101),(104), p.9 Eq.(108);
% L11 p.5 Eqs.(160)-(162); L12 p.1 Eqs.(223),(228), p.2 Eq.(237).
clear; clc;
gamma = 1.4; R = 287; cp = gamma*R/(gamma-1); % J/(kg K)
M1 = 0.25; T1 = 300; p1 = 100e3; A1 = 0.10;
tau = @(M) 1+(gamma-1)*M.^2/2;
areaMach = @(M) (1./M).*((2/(gamma+1))*tau(M)).^((gamma+1)/(2*(gamma-1)));
a1 = sqrt(gamma*R*T1); u1 = M1*a1; rho1 = p1/(R*T1);
T01 = T1*tau(M1); p01 = p1*tau(M1)^(gamma/(gamma-1));
A1_over_A1star = areaMach(M1); A1star = A1/A1_over_A1star;
mdot = rho1*u1*A1;

% Rayleigh: mass and momentum flux remain fixed in a constant-area duct.
pR = p1*(1+gamma*M1^2)/(1+gamma);
TR = T1*((1+gamma*M1^2)/(1+gamma))^2/M1^2;
T0R = TR*tau(1); p0R = pR*tau(1)^(gamma/(gamma-1));
qR = cp*(T0R-T01);
% Fanno: mass flux and stagnation temperature remain fixed.
TF = T01/tau(1); pF = p1*M1*sqrt(TF/T1);
p0F = pF*tau(1)^(gamma/(gamma-1));
% Isentropic area change: p0,T0,s and mdot remain fixed.
TS = TF; pS = p01/tau(1)^(gamma/(gamma-1));

state = ["I: initial";"R: Rayleigh sonic";"F: Fanno sonic";"S: isentropic sonic"];
M = [M1;1;1;1]; T = [T1;TR;TF;TS]; p = [p1;pR;pF;pS];
a = sqrt(gamma*R*T); u = M.*a; T0 = [T01;T0R;T01;T01];
p0 = [p01;p0R;p0F;p01]; A = [A1;A1;A1;A1star];
rho = p./(R*T); mdotCheck = rho.*u.*A;
h = cp*T; ds = cp*log(T/T1)-R*log(p/p1);
results = table(state,M,T,p/1000,a,u,T0,p0/1000,A,mdotCheck,h/1000,ds, ...
    'VariableNames',{'State','Mach','T_K','p_kPa','a_m_s','u_m_s', ...
    'T0_K','p0_kPa','PhysicalArea_m2','mdot_kg_s','h_kJ_kg','ds_J_kgK'});
disp(results);
fprintf('Initial A1/A1star = %.12f; A1star = %.12f m^2\n',A1_over_A1star,A1star);
fprintf('Heat required for Rayleigh sonic state = %.9f kJ/kg\n',qR/1000);
fprintf('Sonic endpoint area: Rayleigh/Fanno = A1; isentropic = A1star.\n');
assert(max(abs(mdotCheck-mdot))/mdot < 1e-12,'Mass conservation failed.');
assert(abs((pR+rho(2)*u(2)^2)-(p1+rho1*u1^2))/(p1+rho1*u1^2)<1e-12);
assert(max(abs(T0([3 4])-T01))<1e-10 && abs(ds(4))<1e-9);
assert(all(ds([2 3])>0) && all(p0([2 3])<p01));
assert(abs(cp*(TR-T1)+(u(2)^2-u1^2)/2-qR)<1e-6);

% Curves are parameterized by local Mach number from M1 to the sonic state.
mc = linspace(M1,1,1001);
pRc = p1*(1+gamma*M1^2)./(1+gamma*mc.^2);
TRc = T1*(mc/M1).^2.*((1+gamma*M1^2)./(1+gamma*mc.^2)).^2;
TFc = T01./tau(mc); pFc = p1*(M1./mc).*sqrt(TFc/T1);
TSc = TFc; pSc = p01./tau(mc).^(gamma/(gamma-1));
sRc = cp*log(TRc/T1)-R*log(pRc/p1);
sFc = cp*log(TFc/T1)-R*log(pFc/p1);
sSc = zeros(size(mc));
Mmax = 1/sqrt(gamma);
pmax = p1*(1+gamma*M1^2)/(1+gamma*Mmax^2);
Tmax = T1*(Mmax/M1)^2*((1+gamma*M1^2)/(1+gamma*Mmax^2))^2;
smax = cp*log(Tmax/T1)-R*log(pmax/p1);
fprintf('Rayleigh maximum h: M=%.12f, T=%.9f K, h=%.9f kJ/kg, ds=%.9f J/(kg K)\n', ...
    Mmax,Tmax,cp*Tmax/1000,smax);

% Compact submission figure; exact beginning/end states are tabulated above.
f = figure('Visible','off','Color','w','Units','inches','Position',[1 1 6.5 3.5]);
ax = axes(f); hold(ax,'on');
cR = [0.75 0.20 0.14]; cF = [0.08 0.38 0.66]; cS = [0.17 0.48 0.28];
plot(sRc,cp*TRc/1000,'Color',cR,'LineWidth',1.6,'DisplayName','Rayleigh');
plot(sFc,cp*TFc/1000,'Color',cF,'LineWidth',1.6,'DisplayName','Fanno');
plot(sSc,cp*TSc/1000,'Color',cS,'LineWidth',1.6,'DisplayName','Isentropic');
plot(ds,h/1000,'ko','MarkerFaceColor','w','MarkerSize',4,'HandleVisibility','off');
plot(smax,cp*Tmax/1000,'s','Color',cR,'MarkerFaceColor','w','MarkerSize',4,'HandleVisibility','off');
text(18,h(1)/1000+18,'I','FontSize',9);
text(ds(2)+18,h(2)/1000-15,'R','FontSize',9);
text(ds(3)+16,h(3)/1000-7,'F','FontSize',9);
text(ds(4)-18,h(4)/1000-22,'S','FontSize',9,'HorizontalAlignment','right');
text(smax-23,cp*Tmax/1000+27,'T_{max}','FontSize',8,'HorizontalAlignment','right');
% Direction arrows are tangent secants in data coordinates, with autoscaling off.
for k = [210 610]
    quiver(sRc(k),cp*TRc(k)/1000,sRc(k+20)-sRc(k),cp*(TRc(k+20)-TRc(k))/1000, ...
        0,'Color',cR,'LineWidth',1.2,'MaxHeadSize',2,'HandleVisibility','off');
end
k = 260;
quiver(sFc(k),cp*TFc(k)/1000,sFc(k+75)-sFc(k),cp*(TFc(k+75)-TFc(k))/1000, ...
    0,'Color',cF,'LineWidth',1.2,'MaxHeadSize',1.3,'HandleVisibility','off');
quiver(0,285,0,-13,0,'Color',cS,'LineWidth',1.2,'MaxHeadSize',0.8,'HandleVisibility','off');
xlabel('\Delta s = s-s_1 (J kg^{-1} K^{-1})'); ylabel('h (kJ kg^{-1})');
xlim([-70 1540]); ylim([200 1100]);
legend('Location','northwest','Box','off'); grid on; box on;
set(ax,'FontSize',9,'LineWidth',0.6,'Position',[0.12 0.17 0.85 0.79]);
scriptDir = fileparts(mfilename('fullpath')); figDir = fullfile(scriptDir,'..','figures');
if ~exist(figDir,'dir'), mkdir(figDir); end
exportgraphics(f,fullfile(figDir,'HW3_Problem1_hs.png'),'Resolution',200);
close(f);
fprintf('All Problem 1 checks passed; compact h-s figure exported.\n');
