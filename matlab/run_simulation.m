%% Rotating-disk pendulum: nonlinear simulation and solver comparison
clear; clc; close all;

matlabRoot = fileparts(mfilename('fullpath'));
projectRoot = fileparts(matlabRoot);
addpath(matlabRoot);

p = rotpend.defaultParameters();
cfg = struct('tspan',[0,20], 'step',2e-3, 'solver',"rk4", ...
    'relativeTolerance',1e-10, 'absoluteTolerance',1e-12);

simRK4 = rotpend.simulate(p, tspan=cfg.tspan, step=cfg.step, ...
    solver=cfg.solver, relativeTolerance=cfg.relativeTolerance, ...
    absoluteTolerance=cfg.absoluteTolerance);
cfg.solver = "ode45";
simOde45 = rotpend.simulate(p, tspan=cfg.tspan, step=cfg.step, ...
    solver=cfg.solver, relativeTolerance=cfg.relativeTolerance, ...
    absoluteTolerance=cfg.absoluteTolerance);

maximumStateDifference = max(abs(simRK4.x - simOde45.x), [], 'all');
fprintf('Maximum |RK4 - ode45| state difference: %.3e\n', ...
    maximumStateDifference);
fprintf('Maximum equation residual: %.3e m/s^2\n', ...
    max(abs(simRK4.dynamicResidual)));
if any(simRK4.tension < 0)
    warning('rotpend:SlackPendulum', ...
        'Computed tension becomes negative; the rigid taut-rod model is then invalid.');
end

figures = post.plotSimulation(simRK4, simOde45);
resultsDirectory = fullfile(projectRoot, 'results');
if ~isfolder(resultsDirectory)
    mkdir(resultsDirectory);
end
for k = 1:numel(figures)
    exportgraphics(figures(k), fullfile(resultsDirectory, ...
        sprintf('simulation_%d.png', k)), 'Resolution', 180);
end
save(fullfile(resultsDirectory,'simulation.mat'), 'p', 'cfg', ...
    'simRK4', 'simOde45', 'maximumStateDifference');
