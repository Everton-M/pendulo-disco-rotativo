function open_multibody_model()
%OPEN_MULTIBODY_MODEL Open the simplified physical model.
scriptDirectory = fileparts(mfilename('fullpath'));
matlabRoot = fileparts(scriptDirectory);
addpath(matlabRoot);
modelPath = fullfile(scriptDirectory, 'rotating_pendulum_multibody.slx');
if ~isfile(modelPath)
    modelPath = build_multibody_model(false);
end
open_system(modelPath);
set_param('rotating_pendulum_multibody', 'ZoomFactor', 'FitSystem');
end
