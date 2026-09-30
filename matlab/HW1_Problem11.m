%% HW1 Problem 11: thermal equilibration and ideal-gas mixing
% Standalone script; MATLAB base functionality only.
% Inputs: 1 kg CH4 at 300 K and 1 kg Ar at 600 K, both initially 1 bar.
% Model: ideal and calorically perfect gases with prescribed f = [6, 3].
% The exterior is rigid and insulated. No reaction, shaft work, final bulk
% kinetic energy, or potential-energy change; partition heat capacity ignored.
% All energy and entropy outputs refer to total quantities for the given mass.
clear; clc;

%% Given data and heat capacities
Ru = 8.3144626;                   % J/(mol K), supplied in Problem 11
species = {'CH4', 'Ar'};
m = [1.0, 1.0];                 % kg
M = [16.0425, 39.948]*1e-3;       % kg/mol (converted from g/mol)
T_initial = [300.0, 600.0];       % K
p_initial = [1.0, 1.0]*1e5;      % Pa, absolute
f = [6, 3];                     % active quadratic energy terms per molecule
n = m./M;                       % mol
R = Ru./M;                      % J/(kg K)
cv_molar = (f/2)*Ru;             % J/(mol K)
cp_molar = cv_molar + Ru;        % J/(mol K)
cv = cv_molar./M;                % J/(kg K)
Cv_total = n.*cv_molar;          % J/K, heat capacity of each entire gas sample
V_initial = n.*Ru.*T_initial./p_initial;  % m^3
V_total = sum(V_initial);        % m^3, rigid vessel volume
n_total = sum(n);
x = n/n_total;                  % final mole fractions
phi_initial = V_initial/V_total; % initial compartment volume fractions

%% (a) Fixed partition; thermal contact between the compartments
% Q_external = W_external = 0, so sum_i Cvi*(Tf - Ti) = 0.
T_final_a = sum(Cv_total.*T_initial)/sum(Cv_total);
DeltaE_a = Cv_total.*(T_final_a-T_initial);             % J
DeltaS_a = Cv_total.*log(T_final_a./T_initial);        % J/K
p_final_a = n.*Ru.*T_final_a./V_initial;               % Pa
DeltaS_a_total = sum(DeltaS_a);
% Each gas has a rigid boundary in (a), so its Q equals its DeltaE.
Q_a = DeltaE_a;

%% (b) Start from the original state and remove the partition
% Ideal-gas energy is additive and temperature-dependent only. The same
% total energy and heat capacity therefore give the same final temperature.
T_final_b = sum(n.*cv_molar.*T_initial)/sum(n.*cv_molar);
p_final_b = n_total*Ru*T_final_b/V_total;              % Pa, total pressure
p_partial_b = x*p_final_b;                            % Pa, species pressures
DeltaS_volume = n.*Ru.*log(V_total./V_initial);        % J/K
DeltaS_b = Cv_total.*log(T_final_b./T_initial) + DeltaS_volume;
DeltaS_b_total = sum(DeltaS_b);
% Independent entropy identity: use each species' partial pressure,
% not the total mixture pressure, for its final entropy.
DeltaS_b_pressure = n.*cp_molar.*log(T_final_b./T_initial) ...
                   - n.*Ru.*log(p_partial_b./p_initial);
DeltaE_b = n.*cv_molar.*(T_final_b-T_initial);

%% (c) Extra entropy and its relation to conventional ideal-gas mixing
DeltaS_extra = DeltaS_b - DeltaS_a;
DeltaS_extra_total = sum(DeltaS_extra);
DeltaS_mix = -n.*Ru.*log(x);     % standard equal-T, equal-p mixing entropy
DeltaS_mix_total = sum(DeltaS_mix);
% State-based decomposition: first change the separated gas volumes at Tf
% from Vi to Vi_star=xi*Vtotal, giving a common pressure equal to p_final_b.
% Then mix at that common temperature and pressure.
V_star = x*V_total;
DeltaS_pressure_equalization = n.*Ru.*log(V_star./V_initial);
DeltaS_pressure_equalization_total = sum(DeltaS_pressure_equalization);
% The sum is n_total*Ru*sum(x.*log(x./phi_initial)) >= 0.
DeltaS_pressure_equalization_check = ...
    n_total*Ru*sum(x.*log(x./phi_initial));

%% Reproducible physical and numerical checks
energyTol = 1e-8;                % J, sums of changes of order 1e5 J
entropyTol = 1e-9;               % J/K
pressureTol = 1e-8;              % Pa
assert(T_final_a > min(T_initial) && T_final_a < max(T_initial));
assert(abs(T_final_b-T_final_a) < 1e-10);
assert(abs(sum(DeltaE_a)) < energyTol, 'Part (a) energy imbalance.');
assert(abs(sum(DeltaE_b)) < energyTol, 'Part (b) energy imbalance.');
assert(abs(sum(Q_a)) < energyTol, 'Internal heat transfers do not cancel.');
assert(all(p_partial_b > 0) && p_final_b > 0);
assert(abs(sum(p_partial_b)-p_final_b) < pressureTol);
assert(max(abs(DeltaS_b-DeltaS_b_pressure)) < entropyTol, ...
       'The two ideal-gas entropy forms disagree.');
assert(max(abs(DeltaS_extra-DeltaS_volume)) < entropyTol);
assert(abs(DeltaS_extra_total-DeltaS_mix_total ...
           -DeltaS_pressure_equalization_total) < entropyTol);
assert(abs(DeltaS_pressure_equalization_total ...
           -DeltaS_pressure_equalization_check) < entropyTol);
assert(DeltaS_a_total > 0 && DeltaS_b_total > DeltaS_a_total);
assert(DeltaS_pressure_equalization_total >= -entropyTol);
assert(abs(sum(V_star)-V_total) < 1e-12);

%% Report
fprintf('HW1 Problem 11: all pressures absolute; total entropies in J/K\n');
fprintf('Prescribed ideal-CPG model; Ru = %.7f J/(mol K)\n\n', Ru);
fprintf('%-6s %12s %15s %13s %14s\n', ...
        'Gas','n (mol)','cv (J/kg K)','Cv (J/K)','Vi (m^3)');
for i = 1:numel(species)
    fprintf('%-6s %12.8f %15.8f %13.8f %14.10f\n', ...
        species{i}, n(i), cv(i), Cv_total(i), V_initial(i));
end
fprintf('V_total = %.10f m^3; n_total = %.10f mol\n\n', V_total, n_total);
fprintf('(a) Fixed partition: Tf = %.10f K\n', T_final_a);
for i = 1:numel(species)
    fprintf('%-6s: p_f = %.10f bar, Q_i = %+.8f J, DeltaS_i = %+.10f J/K\n', ...
        species{i}, p_final_a(i)/1e5, Q_a(i), DeltaS_a(i));
end
fprintf('DeltaS_a,total = Sgen_a = %.10f J/K\n\n', DeltaS_a_total);
fprintf('(b) Removed partition: Tf = %.10f K; p_f = %.10f bar\n', ...
        T_final_b, p_final_b/1e5);
for i = 1:numel(species)
    fprintf('%-6s: x_i = %.10f, p_i = %.10f bar, DeltaS_i = %+.10f J/K\n', ...
        species{i}, x(i), p_partial_b(i)/1e5, DeltaS_b(i));
end
fprintf('DeltaS_b,total = Sgen_b = %.10f J/K\n\n', DeltaS_b_total);
fprintf('(c) Extra entropy (b)-(a) = %.10f J/K\n', DeltaS_extra_total);
fprintf('Standard equal-T,equal-p mixing entropy = %.10f J/K\n', DeltaS_mix_total);
fprintf('Pressure-equalization contribution = %.10f J/K\n', ...
        DeltaS_pressure_equalization_total);
fprintf('Initial volume fractions: CH4 = %.10f, Ar = %.10f\n', phi_initial);
fprintf('They differ from mole fractions because initial temperatures differ.\n');
fprintf('Do not equate the entire extra entropy to -Ru*sum(n.*log(x)).\n\n');
fprintf('Checks passed: energy, both entropy forms, Dalton law, and decomposition.\n');
