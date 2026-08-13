function modelPath = build_simulink_model(openAfterBuild)
%BUILD_SIMULINK_MODEL Generate the nonlinear rotating-pendulum Simulink model.
% The resulting SLX is reproducible from source and stores its parameters in
% the model workspace. Run this function again after changing the diagram.

arguments
    openAfterBuild (1,1) logical = true
end

scriptDirectory = fileparts(mfilename('fullpath'));
matlabRoot = fileparts(scriptDirectory);
addpath(matlabRoot);

p = rotpend.defaultParameters();
modelName = 'rotating_pendulum';
modelPath = fullfile(scriptDirectory, modelName + ".slx");

load_system('simulink');
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
new_system(modelName);

set_param(modelName, ...
    'SolverType', 'Variable-step', ...
    'Solver', 'ode45', ...
    'StopTime', '20', ...
    'RelTol', '1e-8', ...
    'AbsTol', '1e-10', ...
    'MaxStep', '0.01', ...
    'ReturnWorkspaceOutputs', 'on', ...
    'SignalLogging', 'off');

modelWorkspace = get_param(modelName, 'ModelWorkspace');
assignin(modelWorkspace, 'p', p);

% Prescribed disk angle beta(t).
add_block('simulink/Sources/Clock', modelName + "/Tempo t", ...
    'Position', [35 70 65 90]);
add_block('simulink/Math Operations/Gain', modelName + "/betaRate", ...
    'Gain', 'p.betaRate', 'Position', [100 60 165 100]);
add_block('simulink/Sources/Constant', modelName + "/beta0", ...
    'Value', 'p.beta0', 'Position', [100 125 165 155]);
add_block('simulink/Math Operations/Sum', modelName + "/beta(t)", ...
    'Inputs', '++', 'Position', [205 75 235 135]);
add_block('simulink/Math Operations/Trigonometric Function', ...
    modelName + "/sin(beta)", 'Operator', 'sin', ...
    'Position', [280 85 340 125]);

% State feedback: trigonometric functions of psi.
add_block('simulink/Math Operations/Trigonometric Function', ...
    modelName + "/sin(psi)", 'Operator', 'sin', ...
    'Position', [310 285 375 325]);
add_block('simulink/Math Operations/Trigonometric Function', ...
    modelName + "/cos(psi)", 'Operator', 'cos', ...
    'Position', [310 365 375 405]);

% rho = r + l*sin(psi).
add_block('simulink/Math Operations/Gain', modelName + "/l sin(psi)", ...
    'Gain', 'p.l', 'Position', [420 275 485 335]);
add_block('simulink/Sources/Constant', modelName + "/raio r", ...
    'Value', 'p.r', 'Position', [420 225 485 255]);
add_block('simulink/Math Operations/Sum', modelName + "/rho", ...
    'Inputs', '++', 'Position', [525 260 555 320]);

% Centrifugal term: Omega^2*rho*cos(psi).
add_block('simulink/Math Operations/Gain', modelName + "/Omega squared", ...
    'Gain', '(p.alphaRate+p.betaRate)^2', ...
    'Position', [595 260 690 320]);
add_block('simulink/Math Operations/Product', ...
    modelName + "/Termo centrifugo", 'Inputs', '**', ...
    'Position', [735 270 780 330]);

% Gravity term: g*sin(psi).
add_block('simulink/Math Operations/Gain', modelName + "/Termo gravitacional", ...
    'Gain', 'p.g', 'Position', [595 365 690 405]);

% Arm excitation: b*alphaRate^2*sin(beta)*cos(psi).
add_block('simulink/Math Operations/Product', ...
    modelName + "/sin(beta) cos(psi)", 'Inputs', '**', ...
    'Position', [425 95 470 155]);
add_block('simulink/Math Operations/Gain', modelName + "/Termo do braco", ...
    'Gain', 'p.b*p.alphaRate^2', 'Position', [530 100 650 150]);

% Equation and the two integrations: psiDDot -> psiDot -> psi.
add_block('simulink/Math Operations/Sum', modelName + "/Equacao dinamica", ...
    'Inputs', '+--', 'Position', [835 260 870 380]);
add_block('simulink/Math Operations/Gain', modelName + "/Dividir por l", ...
    'Gain', '1/p.l', 'Position', [915 295 985 345]);
add_block('simulink/Continuous/Integrator', modelName + "/Integrador psiDot", ...
    'InitialCondition', 'p.psiRate0', 'Position', [1035 285 1080 355]);
add_block('simulink/Continuous/Integrator', modelName + "/Integrador psi", ...
    'InitialCondition', 'p.psi0', 'Position', [1140 285 1185 355]);

% Tension diagnostic.
add_block('simulink/Math Operations/Product', modelName + "/sin(beta) sin(psi)", ...
    'Inputs', '**', 'Position', [420 455 465 515]);
add_block('simulink/Math Operations/Gain', modelName + "/Braco tensao", ...
    'Gain', '-p.b*p.alphaRate^2', 'Position', [505 460 610 510]);
add_block('simulink/Math Operations/Product', modelName + "/rho sin(psi)", ...
    'Inputs', '**', 'Position', [595 535 640 595]);
add_block('simulink/Math Operations/Gain', modelName + "/Centrifuga tensao", ...
    'Gain', '(p.alphaRate+p.betaRate)^2', ...
    'Position', [680 540 790 590]);
add_block('simulink/Math Operations/Product', modelName + "/psiDot squared", ...
    'Inputs', '**', 'Position', [595 625 640 685]);
add_block('simulink/Math Operations/Gain', modelName + "/Tangencial tensao", ...
    'Gain', 'p.l', 'Position', [680 630 790 680]);
add_block('simulink/Math Operations/Gain', modelName + "/g cos(psi)", ...
    'Gain', 'p.g', 'Position', [505 715 610 765]);
add_block('simulink/Math Operations/Sum', modelName + "/Soma tensao especifica", ...
    'Inputs', '++++', 'Position', [835 515 870 695]);
add_block('simulink/Math Operations/Gain', modelName + "/Tensao T", ...
    'Gain', 'p.m', 'Position', [915 575 985 625]);

% Visualization and data export.
add_block('simulink/Signal Routing/Mux', modelName + "/Mux estados", ...
    'Inputs', '3', 'Position', [1240 260 1245 380]);
add_block('simulink/Sinks/Scope', modelName + "/Scope estados", ...
    'Position', [1300 280 1360 340]);
add_block('simulink/Sinks/Scope', modelName + "/Scope tensao", ...
    'Position', [1040 570 1100 630]);
add_block('simulink/Sinks/To Workspace', modelName + "/Salvar psi", ...
    'VariableName', 'simPsi', 'SaveFormat', 'Timeseries', ...
    'Position', [1240 420 1335 450]);
add_block('simulink/Sinks/To Workspace', modelName + "/Salvar psiDot", ...
    'VariableName', 'simPsiDot', 'SaveFormat', 'Timeseries', ...
    'Position', [1110 420 1210 450]);
add_block('simulink/Sinks/To Workspace', modelName + "/Salvar psiDDot", ...
    'VariableName', 'simPsiDDot', 'SaveFormat', 'Timeseries', ...
    'Position', [980 420 1085 450]);
add_block('simulink/Sinks/To Workspace', modelName + "/Salvar tensao", ...
    'VariableName', 'simTension', 'SaveFormat', 'Timeseries', ...
    'Position', [1040 665 1145 695]);

% Signal connections.
connect(modelName, 'Tempo t/1', 'betaRate/1');
connect(modelName, 'betaRate/1', 'beta(t)/1');
connect(modelName, 'beta0/1', 'beta(t)/2');
connect(modelName, 'beta(t)/1', 'sin(beta)/1');
connect(modelName, 'sin(beta)/1', 'sin(beta) cos(psi)/1');
connect(modelName, 'sin(beta)/1', 'sin(beta) sin(psi)/1');

connect(modelName, 'Integrador psi/1', 'sin(psi)/1');
connect(modelName, 'Integrador psi/1', 'cos(psi)/1');
connect(modelName, 'sin(psi)/1', 'l sin(psi)/1');
connect(modelName, 'l sin(psi)/1', 'rho/1');
connect(modelName, 'raio r/1', 'rho/2');
connect(modelName, 'rho/1', 'Omega squared/1');
connect(modelName, 'Omega squared/1', 'Termo centrifugo/1');
connect(modelName, 'cos(psi)/1', 'Termo centrifugo/2');
connect(modelName, 'sin(psi)/1', 'Termo gravitacional/1');
connect(modelName, 'cos(psi)/1', 'sin(beta) cos(psi)/2');
connect(modelName, 'sin(beta) cos(psi)/1', 'Termo do braco/1');
connect(modelName, 'Termo centrifugo/1', 'Equacao dinamica/1');
connect(modelName, 'Termo gravitacional/1', 'Equacao dinamica/2');
connect(modelName, 'Termo do braco/1', 'Equacao dinamica/3');
connect(modelName, 'Equacao dinamica/1', 'Dividir por l/1');
connect(modelName, 'Dividir por l/1', 'Integrador psiDot/1');
connect(modelName, 'Integrador psiDot/1', 'Integrador psi/1');

connect(modelName, 'cos(psi)/1', 'g cos(psi)/1');
connect(modelName, 'sin(psi)/1', 'sin(beta) sin(psi)/2');
connect(modelName, 'sin(beta) sin(psi)/1', 'Braco tensao/1');
connect(modelName, 'rho/1', 'rho sin(psi)/1');
connect(modelName, 'sin(psi)/1', 'rho sin(psi)/2');
connect(modelName, 'rho sin(psi)/1', 'Centrifuga tensao/1');
connect(modelName, 'Integrador psiDot/1', 'psiDot squared/1');
connect(modelName, 'Integrador psiDot/1', 'psiDot squared/2');
connect(modelName, 'psiDot squared/1', 'Tangencial tensao/1');
connect(modelName, 'g cos(psi)/1', 'Soma tensao especifica/1');
connect(modelName, 'Braco tensao/1', 'Soma tensao especifica/2');
connect(modelName, 'Centrifuga tensao/1', 'Soma tensao especifica/3');
connect(modelName, 'Tangencial tensao/1', 'Soma tensao especifica/4');
connect(modelName, 'Soma tensao especifica/1', 'Tensao T/1');

connect(modelName, 'Dividir por l/1', 'Mux estados/1');
connect(modelName, 'Integrador psiDot/1', 'Mux estados/2');
connect(modelName, 'Integrador psi/1', 'Mux estados/3');
connect(modelName, 'Mux estados/1', 'Scope estados/1');
connect(modelName, 'Tensao T/1', 'Scope tensao/1');
connect(modelName, 'Integrador psi/1', 'Salvar psi/1');
connect(modelName, 'Integrador psiDot/1', 'Salvar psiDot/1');
connect(modelName, 'Dividir por l/1', 'Salvar psiDDot/1');
connect(modelName, 'Tensao T/1', 'Salvar tensao/1');

% Visual organization and explanatory annotations.
set_param(modelName + "/Tempo t", 'BackgroundColor', 'lightBlue');
set_param(modelName + "/Integrador psiDot", 'BackgroundColor', 'yellow');
set_param(modelName + "/Integrador psi", 'BackgroundColor', 'yellow');
set_param(modelName + "/Equacao dinamica", 'BackgroundColor', 'green');
set_param(modelName + "/Tensao T", 'BackgroundColor', 'orange');
addAnnotation(modelName, ...
    'ENTRADA PRESCRITA: beta(t) = beta0 + betaRate*t', ...
    [35 25 345 45], 'blue');
addAnnotation(modelName, ...
    'DINAMICA: psiDDot = [centrifugo - gravidade - excitacao do braco]/l', ...
    [590 205 1030 225], 'darkGreen');
addAnnotation(modelName, ...
    'ESTADOS: integrar psiDDot produz psiDot; integrar psiDot produz psi', ...
    [920 235 1270 255], 'black');
addAnnotation(modelName, ...
    'DIAGNOSTICO: T deve permanecer positiva para uma haste/fio tracionado', ...
    [505 790 1020 810], 'red');

set_param(modelName, 'ZoomFactor', 'FitSystem');
save_system(modelName, modelPath);

if openAfterBuild
    open_system(modelName);
else
    close_system(modelName, 0);
end
end

function connect(modelName, source, destination)
add_line(modelName, source, destination, 'autorouting', 'on');
end

function addAnnotation(modelName, text, position, color)
annotation = Simulink.Annotation(modelName, text);
annotation.Position = position;
annotation.ForegroundColor = color;
end
