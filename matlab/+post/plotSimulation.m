function figures = plotSimulation(sim, comparison)
%PLOTSIMULATION Create portfolio-ready plots from a simulation result.
% comparison is optional and is expected to contain fields t and x.

arguments
    sim (1,1) struct
    comparison (1,1) struct = struct()
end

figures = gobjects(3,1);

figures(1) = figure('Name','Angular response','Color','w');
tiledlayout(2,1,'TileSpacing','compact');
nexttile;
plot(sim.t, rad2deg(sim.x(:,1)), 'LineWidth', 1.3);
hold on;
if isfield(comparison, 't')
    plot(comparison.t, rad2deg(comparison.x(:,1)), '--', 'LineWidth', 1.0);
    legend(string(sim.solver), string(comparison.solver), 'Location','best');
end
ylabel('\psi [deg]'); grid on;
nexttile;
plot(sim.t, sim.x(:,2), 'LineWidth', 1.3);
xlabel('Time [s]'); ylabel('d\psi/dt [rad/s]'); grid on;

figures(2) = figure('Name','Physical outputs','Color','w');
tiledlayout(2,1,'TileSpacing','compact');
nexttile;
plot(sim.t, sim.tension, 'LineWidth', 1.3);
yline(0, ':k'); ylabel('Tension [N]'); grid on;
nexttile;
plot(sim.t, sim.mechanicalEnergy, 'LineWidth', 1.3);
xlabel('Time [s]'); ylabel('K + V [J]'); grid on;

figures(3) = figure('Name','Mass trajectory','Color','w');
plot3(sim.positionE(:,1), sim.positionE(:,2), sim.positionE(:,3), ...
    'LineWidth', 1.2);
axis equal; grid on; box on;
xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
title('Absolute trajectory of mass E');
end
