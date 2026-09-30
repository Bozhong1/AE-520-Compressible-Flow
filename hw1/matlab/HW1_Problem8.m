% HW1 Problem 8: Isentropic nitrogen nozzle, CPG versus TPG.
% Standalone script; no optional toolboxes or shared helpers.
% Ideal gas, fixed composition, steady adiabatic flow, no shaft work,
% negligible elevation change, and negligible inlet speed.
clearvars; clc;
Ru = 8.31446261815324;      % J/(mol K)
M = 28.0134e-3;            % kg/mol
T1 = 1200;                % K
p1 = 50e5;                % Pa, absolute
p2 = 1e5;                 % Pa, absolute
gamma = 1.40;
A = 27.0;                 % J/(mol K), cp(T) = A + B*T
B = 0.0040;               % J/(mol K^2)

% (a): calorically perfect gas.
cp_CPG = gamma*Ru/(gamma-1);   % J/(mol K)
T2_CPG = T1*(p2/p1)^((gamma-1)/gamma);

% (b): thermally perfect gas. F'(T) = A/T + B > 0 for T > 0.
F = @(T) A*log(T/T1) + B*(T-T1) - Ru*log(p2/p1);
bracket_K = [300, 500];
assert(F(bracket_K(1))*F(bracket_K(2)) < 0, 'Root not bracketed.');
options = optimset('TolX',1e-10,'Display','off');
[T2_TPG,residual,exitflag] = fzero(F,bracket_K,options);
assert(exitflag > 0 && abs(residual) < 1e-9, 'TPG root solve failed.');

% (c): positive static enthalpy drops h1-h2 and ideal exit speeds.
dhbar_CPG = cp_CPG*(T1-T2_CPG);               % J/mol
dhbar_TPG = A*(T1-T2_TPG) + 0.5*B*(T1^2-T2_TPG^2);
dh_CPG = dhbar_CPG/M;                        % J/kg
dh_TPG = dhbar_TPG/M;
V2_CPG = sqrt(2*dh_CPG);                     % m/s
V2_TPG = sqrt(2*dh_TPG);
Model = {'CPG'; 'TPG'};
T2_K = [T2_CPG; T2_TPG];
Enthalpy_drop_kJ_kg = [dh_CPG; dh_TPG]/1000;
Exit_speed_m_s = [V2_CPG; V2_TPG];
disp(table(Model,T2_K,Enthalpy_drop_kJ_kg,Exit_speed_m_s));
fprintf('TPG root bracket [%.1f, %.1f] K; residual = %.3e J/(mol K).\n',...
    bracket_K(1),bracket_K(2),residual);
cp_in = A + B*T1;
cp_out = A + B*T2_TPG;
fprintf('TPG cp(in,out) = %.6f, %.6f J/(mol K).\n', cp_in,cp_out);
fprintf('TPG gamma(in,out) = %.6f, %.6f.\n',cp_in/(cp_in-Ru),cp_out/(cp_out-Ru));

% Check entropy, energy, positive heat capacity, and physical branch.
ds_CPG = cp_CPG*log(T2_CPG/T1)-Ru*log(p2/p1);
assert(abs(ds_CPG) < 1e-10 && abs(F(T2_TPG)) < 1e-9);
assert(abs(dh_CPG-V2_CPG^2/2) < 1e-7);
assert(abs(dh_TPG-V2_TPG^2/2) < 1e-7);
assert(all(T2_K > 0 & T2_K < T1));
assert(cp_in > Ru && cp_out > Ru);
fprintf('Entropy, steady-flow energy, and physical-branch checks passed.\n');
