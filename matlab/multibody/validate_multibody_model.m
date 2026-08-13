function report = validate_multibody_model()
%VALIDATE_MULTIBODY_MODEL Compare the physical model with the ODE model.

scriptDirectory = fileparts(mfilename('fullpath'));
matlabRoot = fileparts(scriptDirectory);
projectRoot = fileparts(matlabRoot);
addpath(matlabRoot);

modelName = 'rotating_pendulum_multibody';
modelPath = fullfile(scriptDirectory, modelName + ".slx");
if ~isfile(modelPath)
    build_multibody_model(false);
end

load_system(modelPath);
p = rotpend.defaultParameters();
workspace = get_param(modelName, 'ModelWorkspace');
assignin(workspace, 'p', p);

output = sim(modelName, 'StopTime', '20', ...
    'ReturnWorkspaceOutputs', 'on');

t = output.mbPsi.Time;
psi = output.mbPsi.Data(:);
psiDot = output.mbPsiDot.Data(:);
psiDDot = output.mbPsiDDot.Data(:);
alpha = output.mbAlpha.Data(:);
beta = output.mbBeta.Data(:);
positionE = squeeze(output.mbPositionE.Data).';
jointForce = squeeze(output.mbJointForce.Data).';

odefun = @(time, state) rotpend.rhs(time, state, p);
options = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, referenceState] = ode45(odefun, t, [p.psi0; p.psiRate0], options);

referencePositionE = zeros(numel(t),3);
referenceTension = zeros(numel(t),1);
referencePsiDDot = zeros(numel(t),1);
for k = 1:numel(t)
    sample = rotpend.stateAt(t(k), referenceState(k,:).', p);
    referencePositionE(k,:) = sample.positionE.';
    referenceTension(k) = sample.tension;
    referencePsiDDot(k) = sample.psiDDot;
end

% In the psi-joint base frame, the D-to-E unit vector is
% [sin(psi), -cos(psi), 0]. Project the vector constraint force onto the
% opposite direction, which points from E toward D and defines tension.
rodDirection = [sin(psi), -cos(psi), zeros(size(psi))];
axialForce = sum(jointForce.*rodDirection, 2);
if norm(axialForce - referenceTension) > norm(-axialForce - referenceTension)
    axialForce = -axialForce;
end

report = struct();
report.maximumPsiError = max(abs(psi - referenceState(:,1)));
report.maximumPsiDotError = max(abs(psiDot - referenceState(:,2)));
report.maximumPsiDDotError = max(abs(psiDDot - referencePsiDDot));
report.maximumPositionError = max(vecnorm(positionE-referencePositionE,2,2));
report.maximumTensionError = max(abs(axialForce-referenceTension));
report.maximumAlphaError = max(abs(alpha-(p.alpha0+p.alphaRate*t)));
report.maximumBetaError = max(abs(beta-(p.beta0+p.betaRate*t)));
report.minimumAxialForce = min(axialForce);
report.numberOfSamples = numel(t);

assert(report.maximumPsiError < 2e-4, ...
    'Multibody psi differs excessively from the analytical model.');
assert(report.maximumPsiDotError < 2e-3, ...
    'Multibody psiDot differs excessively from the analytical model.');
assert(report.maximumPositionError < 2e-4, ...
    'Multibody position E differs excessively from the analytical model.');
assert(report.maximumTensionError < 2e-5, ...
    'Multibody axial force differs excessively from analytical tension.');
assert(report.maximumAlphaError < 5e-5 && report.maximumBetaError < 5e-5, ...
    'The prescribed joint motions were not reproduced accurately.');
assert(report.minimumAxialForce > 0, ...
    'The pendulum axial force became nonpositive.');

fprintf('Simscape Multibody validation passed.\n');
fprintf('Maximum psi error: %.3e rad\n', report.maximumPsiError);
fprintf('Maximum psiDot error: %.3e rad/s\n', report.maximumPsiDotError);
fprintf('Maximum position-E error: %.3e m\n', report.maximumPositionError);
fprintf('Maximum tension error: %.3e N\n', report.maximumTensionError);

resultsDirectory = fullfile(projectRoot, 'results');
if ~isfolder(resultsDirectory)
    mkdir(resultsDirectory);
end
save(fullfile(resultsDirectory, 'multibody_validation.mat'), ...
    'report', 't', 'psi', 'psiDot', 'positionE', 'jointForce', ...
    'referenceState', 'referencePositionE', 'referenceTension');

figureHandle = figure('Name','Multibody validation','Color','w');
tiledlayout(2,1,'TileSpacing','compact');
nexttile;
plot(t, rad2deg(referenceState(:,1)), 'LineWidth', 1.4);
hold on;
plot(t, rad2deg(psi), '--', 'LineWidth', 1.1);
ylabel('\psi [deg]'); grid on;
legend('ODE model','Simscape Multibody','Location','best');
nexttile;
plot(t, 1e6*(psi-referenceState(:,1)), 'LineWidth', 1.2);
xlabel('Time [s]'); ylabel('Angular error [\murad]'); grid on;
exportgraphics(figureHandle, fullfile(resultsDirectory, ...
    'multibody_validation.png'), 'Resolution', 180);
documentationDirectory = fullfile(projectRoot, 'docs', 'figures');
if ~isfolder(documentationDirectory)
    mkdir(documentationDirectory);
end
exportgraphics(figureHandle, fullfile(documentationDirectory, ...
    'multibody-validation.png'), 'Resolution', 180);
close(figureHandle);

close_system(modelName, 0);
end
