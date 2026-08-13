function report = validate_simulink_model()
%VALIDATE_SIMULINK_MODEL Compare the SLX result with MATLAB ode45.

scriptDirectory = fileparts(mfilename('fullpath'));
matlabRoot = fileparts(scriptDirectory);
addpath(matlabRoot);

modelName = 'rotating_pendulum';
modelPath = fullfile(scriptDirectory, modelName + ".slx");
if ~isfile(modelPath)
    build_simulink_model(false);
end

load_system(modelPath);
p = rotpend.defaultParameters();
modelWorkspace = get_param(modelName, 'ModelWorkspace');
assignin(modelWorkspace, 'p', p);

simulationOutput = sim(modelName, 'StopTime', '20', ...
    'ReturnWorkspaceOutputs', 'on');
psiSeries = simulationOutput.simPsi;
psiDotSeries = simulationOutput.simPsiDot;
t = psiSeries.Time;

odefun = @(time, state) rotpend.rhs(time, state, p);
options = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, referenceState] = ode45(odefun, t, [p.psi0; p.psiRate0], options);
simulinkState = [psiSeries.Data, psiDotSeries.Data];
stateError = simulinkState - referenceState;
expectedAlpha = zeros(size(t));
expectedAlphaDDot = zeros(size(t));
expectedBeta = zeros(size(t));
expectedBetaDDot = zeros(size(t));
for k = 1:numel(t)
    motion = rotpend.motionAt(t(k), p);
    expectedAlpha(k) = motion.alpha;
    expectedAlphaDDot(k) = motion.alphaDDot;
    expectedBeta(k) = motion.beta;
    expectedBetaDDot(k) = motion.betaDDot;
end

report = struct();
report.maximumPsiError = max(abs(stateError(:,1)));
report.maximumPsiDotError = max(abs(stateError(:,2)));
report.minimumTension = min(simulationOutput.simTension.Data);
report.maximumAlphaError = max(abs(simulationOutput.simAlpha.Data(:)-expectedAlpha));
report.maximumAlphaDDotError = max(abs(simulationOutput.simAlphaDDot.Data(:)-expectedAlphaDDot));
report.maximumBetaError = max(abs(simulationOutput.simBeta.Data(:)-expectedBeta));
report.maximumBetaDDotError = max(abs(simulationOutput.simBetaDDot.Data(:)-expectedBetaDDot));
report.numberOfSamples = numel(t);

assert(report.maximumPsiError < 1e-6, ...
    'Simulink psi differs excessively from the MATLAB reference.');
assert(report.maximumPsiDotError < 1e-5, ...
    'Simulink psiDot differs excessively from the MATLAB reference.');
assert(report.minimumTension > 0, ...
    'The pendulum tension became nonpositive.');
assert(max([report.maximumAlphaError, report.maximumAlphaDDotError, ...
    report.maximumBetaError, report.maximumBetaDDotError]) < 1e-10, ...
    'The prescribed motion sources are inconsistent with the MATLAB profiles.');

fprintf('Simulink validation passed.\n');
fprintf('Maximum |psi_SLX - psi_ode45|: %.3e rad\n', ...
    report.maximumPsiError);
fprintf('Maximum |psiDot_SLX - psiDot_ode45|: %.3e rad/s\n', ...
    report.maximumPsiDotError);
fprintf('Minimum tension: %.3f N (%d output samples)\n', ...
    report.minimumTension, report.numberOfSamples);

close_system(modelName, 0);
end
