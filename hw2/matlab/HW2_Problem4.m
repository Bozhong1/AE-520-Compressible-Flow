%% HW2 Problem 4: stagnation quantities and different paths
% Standalone script; SI units throughout, pressures absolute.
% Ideal-gas air with constant heat capacities; steady adiabatic diffuser;
% one inlet and one outlet, no shaft work;
% negligible potential-energy change and endpoint conductive/viscous-work flux.
% Sources: L5 notes PDF p.5 Eq.(38); L7 notes PDF p.2 Eqs.(139)-(143);
% L2 notes PDF p.6 Eq.(40), p.9 Eq.(68); L9 notes PDF p.4 Eq.(26).
% Guide: Lecture 7 PDF pp.12-15, Sections 3.4-3.8.
clear; clc;

gamma = 1.4;
R = 287;                  % J/(kg K)
M1 = 0.80;
T1 = 300;                 % K
p1 = 100e3;               % Pa
V2 = 100;                 % m/s
cp = gamma*R/(gamma-1);    % J/(kg K)

a1 = sqrt(gamma*R*T1);
V1 = M1*a1;
T0 = T1 + V1^2/(2*cp);
T2 = T0 - V2^2/(2*cp);
M2 = V2/sqrt(gamma*R*T2);

% Both cases have the same T2 and T0. Entropy distinguishes their pressures.
caseNames = {'A: isentropic'; 'B: irreversible adiabatic'};
entropyOverR = [0; 1];
p2 = p1*(T2/T1)^(cp/R).*exp(-entropyOverR);
p01 = p1*(T0/T1)^(cp/R);
p02 = p2.*(T0/T2)^(cp/R);
p02_from_entropy = p01.*exp(-entropyOverR);

% Independent forms of the energy, entropy, and stagnation-pressure checks.
h01 = cp*T1 + V1^2/2;      % J/kg, common reference h=cp*T
h02 = cp*T2 + V2^2/2;
energyResidual = (h02-h01)/h01;
entropyReconstructed = (cp/R)*log(T2/T1) - log(p2/p1);
p0RelativeResidual = (p02-p02_from_entropy)/p01;
tol = 1e-10;
assert(abs(energyResidual) < tol, 'Steady energy balance failed.');
assert(max(abs(entropyReconstructed-entropyOverR)) < tol, ...
    'Entropy reconstruction failed.');
assert(max(abs(p0RelativeResidual)) < tol, ...
    'Stagnation-pressure calculations disagree.');
assert(T1 < T2 && T2 < T0 && V2 < V1, 'Deceleration trend failed.');
assert(all(p2 > 0) && all(p02 > p2), 'Invalid station pressure.');
assert(p2(1) > p1 && p2(2) < p1, ...
    'The assigned Case B entropy rise must produce a static-pressure drop.');
assert(abs(p02(1)/p01-1) < tol && p02(2) < p01, ...
    'Stagnation-pressure trend failed.');

fprintf('HW2 Problem 4\n');
fprintf('cp = %.6f J/(kg K)\n', cp);
fprintf('a1 = %.6f m/s, V1 = %.6f m/s\n', a1, V1);
fprintf('T0 = %.6f K, T2 = %.6f K, M2 = %.9f\n', T0, T2, M2);
fprintf('p01 = %.6f kPa\n', p01/1e3);
results = table(caseNames, entropyOverR, p2/1e3, p02/1e3, p02/p01, ...
    'VariableNames', {'Case','DeltaS_over_R','p2_kPa','p02_kPa','p02_over_p01'});
disp(results);
fprintf('Static-pressure-rise threshold: DeltaS/R < %.9f\n', ...
    (cp/R)*log(T2/T1));
fprintf('Case B: p2 < p1 follows from the given DeltaS/R = 1.\n');
fprintf('Normalized energy residual = %.3e\n', energyResidual);
fprintf('Maximum entropy residual = %.3e\n', ...
    max(abs(entropyReconstructed-entropyOverR)));
fprintf('Maximum normalized stagnation-pressure residual = %.3e\n', ...
    max(abs(p0RelativeResidual)));
fprintf('All energy, entropy, and pressure checks passed.\n');
