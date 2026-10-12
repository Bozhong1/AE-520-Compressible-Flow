%% HW2 Problem 6: strong shock with prescribed oxygen dissociation
% Standalone; base MATLAB only. Every value uses the assigned simplified model.
% Strong-shock momentum neglects p1; energy neglects h1. The initial density
% still uses the specified nonzero p1 and T1. Do not interpret alpha as an
% equilibrium composition or use the lower quadratic root as a shock.
clear; clc;

%% Inputs (SI, mass-specific gas properties)
T1 = 300;                         % K
p1 = 10e3;                        % Pa, absolute
u1 = 5.0e3;                       % m/s, shock-rest velocity
RO2 = 259.84;                     % J/(kg K)
RO = 2*RO2;                       % J/(kg K)
cpO2 = (7/2)*RO2;                 % J/(kg K)
cpO = (5/2)*RO;                   % J/(kg K)
Qd = 15.6e6;                      % J/kg, specified dissociation energy
alpha = [0; 0.10; 0.20; 0.30];   % downstream atomic-O mass fraction
rho1 = p1/(RO2*T1);               % kg/m^3

%% Mixture gas constant, heat capacity, and compressive quadratic root
R2 = (1-alpha)*RO2 + alpha*RO;
cp2 = (1-alpha)*cpO2 + alpha*cpO;
C = cp2./R2;
beta = alpha*Qd/u1^2;
A = 1-2*beta;
D = C.^2 - A.*(2*C-1);           % quarter of the full discriminant
assert(all(alpha >= 0 & alpha <= 1));
assert(all(beta >= 0 & beta < 0.5), ...
    'Finite positive-temperature compressive states need beta < 1/2.');
assert(all(D >= 0));
r = (C+sqrt(D))./A;               % upper, compressive root
% The conjugate expression avoids subtracting nearly equal positive values.
rLower = (2*C-1)./(C+sqrt(D));
rho2 = r*rho1;
u2 = u1./r;
p2 = rho1*u1^2*(1-1./r);         % Pa: strong-shock approximation
T2 = u1^2*(r-1)./(r.^2.*R2);     % K
hSensible = cp2.*T2;             % J/kg
hChemical = alpha*Qd;            % J/kg
h2 = hSensible+hChemical;        % J/kg, both contributions included

%% Checks against the equations actually used
massResidual = (rho2.*u2-rho1*u1)/(rho1*u1);
momentumResidual = (p2+rho2.*u2.^2-rho1*u1^2)/(rho1*u1^2);
energyResidual = (h2+u2.^2/2-u1^2/2)/(u1^2/2);
eosResidual = (p2-rho2.*R2.*T2)./p2;
quadraticResidual = A.*r.^2-2*C.*r+(2*C-1);
scaledQuadraticResidual = quadraticResidual./(A.*r.^2+2*C.*r+(2*C-1));
allResiduals = [massResidual; momentumResidual; energyResidual; ...
    eosResidual; scaledQuadraticResidual];
assert(max(abs(allResiduals)) < 1e-12);
assert(all(r > 1) && all(T2 > 0) && all(p2 > 0));
assert(all(diff(r) > 0) && all(diff(T2) < 0));
assert(abs(r(1)-6) < 1e-12, 'The undissociated CPG limit should be six.');
assert(all(rLower <= 1+1e-12));

%% Report
fprintf('HW2 Problem 6: prescribed-composition strong-shock model\n');
fprintf('rho1 = %.12f kg/m^3\n', rho1);
fprintf('p1/(rho1*u1^2) = %.8f\n', p1/(rho1*u1^2));
fprintf('h1/(u1^2/2), using h1=cpO2*T1, = %.8f\n\n', cpO2*T1/(u1^2/2));
fprintf('%7s %12s %10s %13s %14s %14s %12s\n', ...
    'alpha','C','beta','r','T2 (K)','p2 (MPa)','lower root');
for k = 1:numel(alpha)
    fprintf('%7.2f %12.8f %10.6f %13.9f %14.6f %14.9f %12.9f\n', ...
        alpha(k),C(k),beta(k),r(k),T2(k),p2(k)/1e6,rLower(k));
end
fprintf('\nEnergy split, per kg of downstream mixture:\n');
fprintf('%7s %19s %19s %19s\n','alpha','sensible (MJ/kg)', ...
    'chemical (MJ/kg)','kinetic (MJ/kg)');
for k = 1:numel(alpha)
    fprintf('%7.2f %19.9f %19.9f %19.9f\n',alpha(k), ...
        hSensible(k)/1e6,hChemical(k)/1e6,u2(k)^2/(2e6));
end
fprintf('\nMaximum scaled residual = %.3e\n',max(abs(allResiduals)));
fprintf('Finite compressive states require alpha < %.9f as well as alpha <= 1.\n', ...
    u1^2/(2*Qd));
fprintf('For alpha=0, the lower root is a degenerate r=1 branch.\n');
fprintf('For alpha>0 here, the lower root is <1 and gives negative p2 and T2.\n');
fprintf('This is not an equilibrium-chemistry or high-accuracy oxygen model.\n');
