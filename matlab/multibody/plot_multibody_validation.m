function outputPath = plot_multibody_validation(resultsFile)
%PLOT_MULTIBODY_VALIDATION Plot a previously computed Multibody comparison.

arguments
    resultsFile (1,1) string = ""
end

scriptDirectory = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(scriptDirectory));
if strlength(resultsFile) == 0
    resultsFile = fullfile(projectRoot, 'results', ...
        'multibody_validation.mat');
end
data = load(resultsFile, 't', 'psi', 'referenceState');

figureHandle = figure('Name','Multibody validation','Color','w');
tiledlayout(2,1,'TileSpacing','compact');
nexttile;
plot(data.t, rad2deg(data.referenceState(:,1)), 'LineWidth', 1.4);
hold on;
plot(data.t, rad2deg(data.psi), '--', 'LineWidth', 1.1);
ylabel('\psi [deg]'); grid on;
legend('ODE model','Simscape Multibody','Location','best');
nexttile;
plot(data.t, 1e6*(data.psi-data.referenceState(:,1)), 'LineWidth', 1.2);
xlabel('Time [s]'); ylabel('Angular error [\murad]'); grid on;

documentationDirectory = fullfile(projectRoot, 'docs', 'figures');
if ~isfolder(documentationDirectory)
    mkdir(documentationDirectory);
end
outputPath = fullfile(documentationDirectory, 'multibody-validation.png');
exportgraphics(figureHandle, outputPath, 'Resolution', 180);
close(figureHandle);
end
