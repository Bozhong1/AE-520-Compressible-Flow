% HW2 Problem 2: Boundary-layer control volume and local viscous stress.
% Standalone. SI units. No toolbox or shared helper is required.
% Fixed, steady, constant-density CV; forces/fluxes are per unit span.
% In the integral momentum estimate, neglect body force and viscous
% tractions on inlet, outlet, and top; equal boundary static pressures cancel.
% The given local velocity field is used only near the outlet, not globally.
% Matrix convention: grad_u(i,j) = partial u_i / partial x_j.
clearvars; clc;
L = 0.50;               % m
H = 0.020;              % m
U = 30;                % m/s
rho = 1.20;            % kg/m^3
mu = 1.8e-5;           % Pa s
temperature = 300;     % K, locally uniform for the requested entropy rate
delta = 1.20e-3;       % m
assert(delta > 0 && delta < H && L > 0 && temperature > 0);

% (a) Signed mass fluxes through surfaces per unit span [kg/(m s)].
% All fluxes use the outward unit normal; the inlet is negative.
int_u_out = U*(H-delta/2);                  % integral_0^H u dy [m^2/s]
vH = (U*H-int_u_out)/L;
mflux_in = -rho*U*H;
mflux_out = rho*int_u_out;
mflux_top = rho*vH*L;
mass_residual = mflux_in+mflux_out+mflux_top;

% (b) Signed x-momentum fluxes per unit span [N/m].
int_u2_out = U^2*(H-2*delta/3);             % integral_0^H u^2 dy
mom_in = -rho*U^2*H;
mom_out = rho*int_u2_out;
mom_top = rho*U*vH*L;                      % top transports x-momentum!
F_wall_on_fluid_per_span = mom_in+mom_out+mom_top; % N/m, negative = upstream
tau_wall_mean_signed = F_wall_on_fluid_per_span/L; % Pa, traction on fluid
tau_wall_mean = -tau_wall_mean_signed;      % Pa, positive drag magnitude

% (c) Local velocity-gradient tensor and its decomposition [1/s].
G = [-vH/delta, U/delta, 0; 0, vH/delta, 0; 0, 0, 0];
D = (G+G.')/2;
W = (G-G.')/2;
dilatation = trace(G);
Dprime = D-(dilatation/3)*eye(3);           % THREE-dimensional trace removal

% (d) Local viscous stress [Pa]. The bulk term is zero for any finite zeta
% because dilatation=0; no assumption of zero bulk viscosity is needed.
tau = 2*mu*Dprime;

% (e) Double contraction sums matching components, not matrix multiplication.
Phi = sum(sum(tau.*G));                    % W/m^3
Phi_from_D = 2*mu*sum(sum(Dprime.^2));
Phi_closed = mu*((U/delta)^2+4*(vH/delta)^2);
sgen = Phi/temperature;                    % W/(m^3 K), viscous entropy production

% (f) Local positive shear magnitude versus CV-average positive magnitude.
tau_wall_local = mu*U/delta;
relative_difference = (tau_wall_local-tau_wall_mean)/tau_wall_mean;

% Independent integral checks use the two separate profile segments.
int_u_check = integral(@(y) U*y/delta,0,delta)+U*(H-delta);
int_u2_check = integral(@(y) (U*y/delta).^2,0,delta)+U^2*(H-delta);
assert(abs(int_u_out-int_u_check) < 1e-12);
assert(abs(int_u2_out-int_u2_check) < 1e-10);
assert(abs(mass_residual) < 1e-12);
assert(abs(F_wall_on_fluid_per_span+rho*U^2*delta/6) < 1e-11);
assert(norm(G-D-W,'fro') < 1e-12);
assert(norm(D-D.','fro') < 1e-12 && norm(W+W.','fro') < 1e-12);
assert(abs(dilatation) < 1e-12 && abs(trace(Dprime)) < 1e-12);
assert(abs(Phi-Phi_from_D) < 1e-8 && abs(Phi-Phi_closed) < 1e-8);
assert(Phi >= 0 && sgen >= 0);
assert(abs(sum(sum(tau.*W))) < 1e-12);     % rigid rotation does no viscous work

fprintf('HW2 Problem 2\n');
fprintf('(a) vH = %+.8f m/s: outward through the top.\n',vH);
fprintf('    signed mass fluxes [inlet outlet top] = [%+.6f %+.6f %+.6f] kg/(m s)\n',mflux_in,mflux_out,mflux_top);
fprintf('(b) signed momentum fluxes = [%+.6f %+.6f %+.6f] N/m\n',mom_in,mom_out,mom_top);
fprintf('    wall force on fluid = %+.6f N/m; mean wall traction = %+.6f Pa\n',F_wall_on_fluid_per_span,tau_wall_mean_signed);
fprintf('    positive average wall shear magnitude = %.6f Pa\n',tau_wall_mean);
fprintf('(c) grad(u), D, W [1/s]:\n'); disp(G); disp(D); disp(W);
fprintf('    div(u) = %.3e 1/s\n',dilatation);
fprintf('(d) viscous stress tensor [Pa]:\n'); disp(tau);
fprintf('(e) Phi = %.8f W/m^3; sgen = %.9f W/(m^3 K)\n',Phi,sgen);
fprintf('(f) local shear = %.6f Pa; local exceeds mean by %.6f %%\n',tau_wall_local,100*relative_difference);
fprintf('Mass, momentum, tensor-decomposition, integral, and dissipation checks passed.\n');
