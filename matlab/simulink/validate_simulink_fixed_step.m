function report = validate_simulink_fixed_step()
%VALIDATE_SIMULINK_FIXED_STEP Validate ode4 with a 0.002 s fixed step.

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

simulationInput = Simulink.SimulationInput(modelName);
simulationInput = setModelParameter(simulationInput, ...
    'StopTime', '20', ...
    'SolverType', 'Fixed-step', ...
    'Solver', 'ode4', ...
    'FixedStep', '0.002', ...
    'ReturnWorkspaceOutputs', 'on');
output = sim(simulationInput);

t = output.simPsi.Time;
simulinkState = [output.simPsi.Data, output.simPsiDot.Data];
[referenceTime, referenceState] = numerics.rk4( ...
    @(time,state) rotpend.rhs(time,state,p), [0,20], ...
    [p.psi0; p.psiRate0], 0.002);

assert(max(abs(t - referenceTime)) < 10*eps(max(t)), ...
    'Simulink and MATLAB fixed-step time vectors differ.');
error = simulinkState - referenceState;

report = struct();
report.maximumPsiError = max(abs(error(:,1)));
report.maximumPsiDotError = max(abs(error(:,2)));
report.minimumTension = min(output.simTension.Data);
report.numberOfSamples = numel(t);

assert(report.maximumPsiError < 1e-10, ...
    'Simulink ode4 psi differs from the MATLAB RK4 reference.');
assert(report.maximumPsiDotError < 1e-9, ...
    'Simulink ode4 psiDot differs from the MATLAB RK4 reference.');

fprintf('Fixed-step Simulink validation passed.\n');
fprintf('Maximum |psi_ode4 - psi_RK4|: %.3e rad\n', ...
    report.maximumPsiError);
fprintf('Maximum |psiDot_ode4 - psiDot_RK4|: %.3e rad/s\n', ...
    report.maximumPsiDotError);

close_system(modelName, 0);
end
