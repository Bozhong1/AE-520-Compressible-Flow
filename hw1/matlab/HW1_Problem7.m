% HW1 Problem 7: Isothermal enthalpy change from two second-virial models.
% Standalone script; B is molar (m^3/mol), not mass specific.
% Values at 200 bar are formal outputs of a truncated approximation.
clearvars; clc;
Ru = 8.31446261815324;      % J/(mol K)
NA = 6.02214076e23;         % mol^-1
M = 28.0134e-3;            % kg/mol
T = 150;                  % K
p1 = 1e5;                 % Pa, absolute
p2 = 200e5;               % Pa, absolute
dp = p2 - p1;
sigma = 3.681e-10;         % m; 1 angstrom = 1e-10 m
B_RS = (2*pi/3)*NA*sigma^3;
dB_RS_dT = 0;              % Fixed hard-sphere diameter
B_att = -75.7e-6;          % m^3/mol
dB_att_dT = 1.01e-6;       % m^3/(mol K)

Model = {'Rigid sphere'; 'Attraction-inclusive'};
B = [B_RS; B_att];
dBdT = [dB_RS_dT; dB_att_dT];
coefficient = B - T*dBdT;  % m^3/mol
Dh_molar_J_mol = coefficient*dp;
Dh_mass_kJ_kg = Dh_molar_J_mol/M/1000;
Z1 = 1 + B*p1/(Ru*T);
Z2 = 1 + B*p2/(Ru*T);
B_cm3_mol = B*1e6;
coef_cm3_mol = coefficient*1e6;
disp(table(Model,B_cm3_mol,coef_cm3_mol,Dh_molar_J_mol,...
    Dh_mass_kJ_kg,Z1,Z2));

% Cross-check by differentiating Z = 1 + B(T)*p/(Ru*T).
p_test = 0.5*(p1 + p2);
dZ_dT = p_test/Ru*(dBdT/T - B/T^2);
coefficient_from_Z = -Ru*T^2/p_test*dZ_dT;
assert(max(abs(coefficient_from_Z - coefficient)) < 1e-15);
assert(Dh_mass_kJ_kg(1) > 0 && Dh_mass_kJ_kg(2) < 0);
p_Z_zero_bar = -Ru*T/B_att/1e5;
fprintf('Attraction model: Z = 0 at %.6f bar.\n', p_Z_zero_bar);
fprintf('At 200 bar, attraction-model Z = %.6f is unphysical.\n', Z2(2));
fprintf('Rigid-sphere correction |Z-1| = %.6f is also not small.\n', abs(Z2(1)-1));
fprintf('Report both enthalpy changes as formal model results, not reliable N2 data.\n');
