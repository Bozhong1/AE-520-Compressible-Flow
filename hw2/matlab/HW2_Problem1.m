%% HW2 Problem 1: expanding balloon and two control volumes
% SI units. Q is evaluated at the prescribed balloon-gas density.
% Source: Lecture 5 organized notes, PDF p.5, Eqs. (33)-(36).
clear; clc;
Q = 2.0e-3;             % m^3/s
rhoInside = 1.30;       % kg/m^3
rhoOutside = 1.20;      % kg/m^3
R0 = 0.10;             % m
Rc = 0.15;             % m
V0 = 4*pi*R0^3/3;
Vc = 4*pi*Rc^3/3;
tHit = (Vc-V0)/Q;
radialSpeed = Q/(4*pi*Rc^2);
M0 = rhoOutside*Vc + (rhoInside-rhoOutside)*V0;
massSlope = (rhoInside-rhoOutside)*Q;
Mfinal = rhoInside*Vc;
fprintf('dR/dt at R = Rc: %.10f m/s\n',radialSpeed);
fprintf('Time to reach Rc: %.10f s\n',tHit);
fprintf('M(0): %.11f kg; M(tHit): %.11f kg\n',M0,Mfinal);
fprintf('dM/dt before contact: %.10f kg/s\n',massSlope);
fprintf('Mean outward speed after contact: %.10f m/s\n',radialSpeed);
mdotIn = rhoInside*Q;
mdotOutBefore = rhoOutside*Q;
mdotOutAfter = rhoInside*4*pi*Rc^2*radialSpeed;
assert(abs(massSlope-(mdotIn-mdotOutBefore)) < 1e-12);
assert(abs(mdotIn-mdotOutAfter) < 1e-12);
assert(abs(M0+massSlope*tHit-Mfinal) < 1e-12);

t = linspace(0,tHit,201);
R = (R0^3+3*Q*t/(4*pi)).^(1/3);
M = rhoOutside*Vc + (rhoInside-rhoOutside)*4*pi*R.^3/3;
f = figure('Visible','off','Color','w','Position',[100 100 1000 600]);
plot(t,1000*M,'LineWidth',2,'Color',[0.08 0.32 0.55]); hold on;
plot([0 tHit],1000*[M0 Mfinal],'o','MarkerFaceColor',[0.08 0.32 0.55], ...
    'MarkerEdgeColor',[0.08 0.32 0.55],'MarkerSize',7);
text(0.08,1000*M0+0.06,sprintf('M(0) = %.4f g',1000*M0));
text(tHit-0.08,1000*Mfinal-0.07,sprintf('M(t_c) = %.4f g',1000*Mfinal), ...
    'HorizontalAlignment','right');
xlabel('Time, t (s)'); ylabel('Total gas mass in fixed sphere, M (g)');
title('Problem 1: fixed control volume before R = R_c');
xlim([0 1.03*tHit]); ylim(1000*[M0-0.00012 Mfinal+0.00012]);
grid on; box off; set(gca,'FontSize',13);
scriptDir = fileparts(mfilename('fullpath'));
figDir = fullfile(scriptDir,'..','figures');
if ~exist(figDir,'dir'), mkdir(figDir); end
exportgraphics(f,fullfile(figDir,'HW2_Problem1_Mass.png'),'Resolution',180);
close(f);
