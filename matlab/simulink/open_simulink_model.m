function open_simulink_model()
%OPEN_SIMULINK_MODEL Open the generated model and fit it to the window.
scriptDirectory = fileparts(mfilename('fullpath'));
matlabRoot = fileparts(scriptDirectory);
addpath(matlabRoot);
modelPath = fullfile(scriptDirectory, 'rotating_pendulum.slx');
if ~isfile(modelPath)
    modelPath = build_simulink_model(false);
end
open_system(modelPath);
set_param('rotating_pendulum', 'ZoomFactor', 'FitSystem');
end
