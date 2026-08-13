function modelPath = build_simulink_model(openAfterBuild)
%BUILD_SIMULINK_MODEL Generate the nonlinear rotating-pendulum model.
% Alpha and beta are prescribed through consistent angle, rate and
% acceleration signals. Replace the source blocks to use another motion law.

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
set_param(modelName, 'SolverType', 'Variable-step', 'Solver', 'ode45', ...
    'StopTime', '20', 'RelTol', '1e-8', 'AbsTol', '1e-10', ...
    'MaxStep', '0.01', 'ReturnWorkspaceOutputs', 'on', ...
    'SignalLogging', 'off');
assignin(get_param(modelName, 'ModelWorkspace'), 'p', p);

% Prescribed motion and its analytical derivatives.
add_block('simulink/Sources/Clock', modelName + "/Tempo t", ...
    'Position', [25 65 55 85]);
addMotionFcn(modelName, 'alpha', 'p.alphaProfile', [95 25]);
addMotionFcn(modelName, 'alphaDot', 'p.alphaProfile', [95 70], 1);
addMotionFcn(modelName, 'alphaDDot', 'p.alphaProfile', [95 115], 2);
addMotionFcn(modelName, 'beta', 'p.betaProfile', [95 170]);
addMotionFcn(modelName, 'betaDot', 'p.betaProfile', [95 215], 1);
addMotionFcn(modelName, 'betaDDot', 'p.betaProfile', [95 260], 2);

add_block('simulink/Math Operations/Trigonometric Function', ...
    modelName + "/sin(beta)", 'Operator', 'sin', ...
    'Position', [250 165 310 195]);
add_block('simulink/Math Operations/Trigonometric Function', ...
    modelName + "/cos(beta)", 'Operator', 'cos', ...
    'Position', [250 210 310 240]);

% Omega = alphaDot + betaDot and Omega^2.
add_block('simulink/Math Operations/Sum', modelName + "/Omega", ...
    'Inputs', '++', 'Position', [260 75 290 120]);
add_block('simulink/Math Operations/Product', modelName + "/Omega squared", ...
    'Inputs', '**', 'Position', [335 75 375 120]);

% Tangential acceleration of C projected on Y2:
% b*(alphaDot^2*sin(beta) + alphaDDot*cos(beta)).
add_block('simulink/Math Operations/Product', ...
    modelName + "/alphaDot squared", 'Inputs', '**', ...
    'Position', [345 135 385 175]);
add_block('simulink/Math Operations/Product', ...
    modelName + "/alphaDot2 sin(beta)", 'Inputs', '**', ...
    'Position', [425 140 470 190]);
add_block('simulink/Math Operations/Product', ...
    modelName + "/alphaDDot cos(beta)", 'Inputs', '**', ...
    'Position', [345 215 390 265]);
add_block('simulink/Math Operations/Sum', ...
    modelName + "/Aceleracao tangencial C", 'Inputs', '++', ...
    'Position', [515 165 545 235]);
add_block('simulink/Math Operations/Gain', ...
    modelName + "/Multiplicar por b", 'Gain', 'p.b', ...
    'Position', [590 180 655 220]);

% State feedback.
add_block('simulink/Math Operations/Trigonometric Function', ...
    modelName + "/sin(psi)", 'Operator', 'sin', ...
    'Position', [345 390 405 425]);
add_block('simulink/Math Operations/Trigonometric Function', ...
    modelName + "/cos(psi)", 'Operator', 'cos', ...
    'Position', [345 455 405 490]);
add_block('simulink/Math Operations/Gain', modelName + "/l sin(psi)", ...
    'Gain', 'p.l', 'Position', [450 380 515 430]);
add_block('simulink/Sources/Constant', modelName + "/raio r", ...
    'Value', 'p.r', 'Position', [450 335 515 365]);
add_block('simulink/Math Operations/Sum', modelName + "/rho", ...
    'Inputs', '++', 'Position', [555 365 585 425]);

% Dynamic equation.
add_block('simulink/Math Operations/Product', ...
    modelName + "/Termo centrifugo", 'Inputs', '***', ...
    'Position', [705 330 750 390]);
add_block('simulink/Math Operations/Gain', ...
    modelName + "/Termo gravitacional", 'Gain', 'p.g', ...
    'Position', [590 455 665 490]);
add_block('simulink/Math Operations/Product', ...
    modelName + "/Termo do braco", 'Inputs', '**', ...
    'Position', [705 205 750 255]);
add_block('simulink/Math Operations/Sum', modelName + "/Equacao dinamica", ...
    'Inputs', '+--', 'Position', [805 300 840 455]);
add_block('simulink/Math Operations/Gain', modelName + "/Dividir por l", ...
    'Gain', '1/p.l', 'Position', [885 350 955 400]);
add_block('simulink/Continuous/Integrator', modelName + "/Integrador psiDot", ...
    'InitialCondition', 'p.psiRate0', 'Position', [1000 340 1045 410]);
add_block('simulink/Continuous/Integrator', modelName + "/Integrador psi", ...
    'InitialCondition', 'p.psi0', 'Position', [1100 340 1145 410]);

% Tension diagnostic.
add_block('simulink/Math Operations/Product', ...
    modelName + "/braco sin(psi)", 'Inputs', '**', ...
    'Position', [705 535 750 585]);
add_block('simulink/Math Operations/Gain', ...
    modelName + "/Sinal braco tensao", 'Gain', '-1', ...
    'Position', [790 540 855 580]);
add_block('simulink/Math Operations/Product', ...
    modelName + "/centrifuga tensao", 'Inputs', '***', ...
    'Position', [705 610 750 670]);
add_block('simulink/Math Operations/Product', ...
    modelName + "/psiDot squared", 'Inputs', '**', ...
    'Position', [705 705 750 755]);
add_block('simulink/Math Operations/Gain', ...
    modelName + "/l psiDot squared", 'Gain', 'p.l', ...
    'Position', [790 710 865 750]);
add_block('simulink/Math Operations/Gain', modelName + "/g cos(psi)", ...
    'Gain', 'p.g', 'Position', [590 785 665 825]);
add_block('simulink/Math Operations/Sum', ...
    modelName + "/Soma tensao especifica", 'Inputs', '++++', ...
    'Position', [900 575 935 765]);
add_block('simulink/Math Operations/Gain', modelName + "/Tensao T", ...
    'Gain', 'p.m', 'Position', [980 645 1050 695]);

% Scopes and exports.
add_block('simulink/Signal Routing/Mux', modelName + "/Mux estados", ...
    'Inputs', '3', 'Position', [1195 325 1200 445]);
add_block('simulink/Sinks/Scope', modelName + "/Scope estados", ...
    'Position', [1250 350 1310 410]);
add_block('simulink/Sinks/Scope', modelName + "/Scope tensao", ...
    'Position', [1100 640 1160 700]);
addWorkspaceSink(modelName, 'psi', 'simPsi', [1190 490]);
addWorkspaceSink(modelName, 'psiDot', 'simPsiDot', [1065 490]);
addWorkspaceSink(modelName, 'psiDDot', 'simPsiDDot', [940 490]);
addWorkspaceSink(modelName, 'tensao', 'simTension', [1090 745]);
addWorkspaceSink(modelName, 'alpha', 'simAlpha', [250 15]);
addWorkspaceSink(modelName, 'alphaDDot', 'simAlphaDDot', [250 120]);
addWorkspaceSink(modelName, 'beta', 'simBeta', [250 260]);
addWorkspaceSink(modelName, 'betaDDot', 'simBetaDDot', [250 305]);

% Signal connections: motion.
for name = ["alpha","alphaDot","alphaDDot","beta","betaDot","betaDDot"]
    connect(modelName, 'Tempo t/1', name + "/1");
end
connect(modelName, 'beta/1', 'sin(beta)/1');
connect(modelName, 'beta/1', 'cos(beta)/1');
connect(modelName, 'alphaDot/1', 'Omega/1');
connect(modelName, 'betaDot/1', 'Omega/2');
connect(modelName, 'Omega/1', 'Omega squared/1');
connect(modelName, 'Omega/1', 'Omega squared/2');
connect(modelName, 'alphaDot/1', 'alphaDot squared/1');
connect(modelName, 'alphaDot/1', 'alphaDot squared/2');
connect(modelName, 'alphaDot squared/1', 'alphaDot2 sin(beta)/1');
connect(modelName, 'sin(beta)/1', 'alphaDot2 sin(beta)/2');
connect(modelName, 'alphaDDot/1', 'alphaDDot cos(beta)/1');
connect(modelName, 'cos(beta)/1', 'alphaDDot cos(beta)/2');
connect(modelName, 'alphaDot2 sin(beta)/1', 'Aceleracao tangencial C/1');
connect(modelName, 'alphaDDot cos(beta)/1', 'Aceleracao tangencial C/2');
connect(modelName, 'Aceleracao tangencial C/1', 'Multiplicar por b/1');

% Signal connections: equation.
connect(modelName, 'Integrador psi/1', 'sin(psi)/1');
connect(modelName, 'Integrador psi/1', 'cos(psi)/1');
connect(modelName, 'sin(psi)/1', 'l sin(psi)/1');
connect(modelName, 'l sin(psi)/1', 'rho/1');
connect(modelName, 'raio r/1', 'rho/2');
connect(modelName, 'Omega squared/1', 'Termo centrifugo/1');
connect(modelName, 'rho/1', 'Termo centrifugo/2');
connect(modelName, 'cos(psi)/1', 'Termo centrifugo/3');
connect(modelName, 'sin(psi)/1', 'Termo gravitacional/1');
connect(modelName, 'Multiplicar por b/1', 'Termo do braco/1');
connect(modelName, 'cos(psi)/1', 'Termo do braco/2');
connect(modelName, 'Termo centrifugo/1', 'Equacao dinamica/1');
connect(modelName, 'Termo gravitacional/1', 'Equacao dinamica/2');
connect(modelName, 'Termo do braco/1', 'Equacao dinamica/3');
connect(modelName, 'Equacao dinamica/1', 'Dividir por l/1');
connect(modelName, 'Dividir por l/1', 'Integrador psiDot/1');
connect(modelName, 'Integrador psiDot/1', 'Integrador psi/1');

% Signal connections: tension.
connect(modelName, 'Multiplicar por b/1', 'braco sin(psi)/1');
connect(modelName, 'sin(psi)/1', 'braco sin(psi)/2');
connect(modelName, 'braco sin(psi)/1', 'Sinal braco tensao/1');
connect(modelName, 'Omega squared/1', 'centrifuga tensao/1');
connect(modelName, 'rho/1', 'centrifuga tensao/2');
connect(modelName, 'sin(psi)/1', 'centrifuga tensao/3');
connect(modelName, 'Integrador psiDot/1', 'psiDot squared/1');
connect(modelName, 'Integrador psiDot/1', 'psiDot squared/2');
connect(modelName, 'psiDot squared/1', 'l psiDot squared/1');
connect(modelName, 'cos(psi)/1', 'g cos(psi)/1');
connect(modelName, 'g cos(psi)/1', 'Soma tensao especifica/1');
connect(modelName, 'Sinal braco tensao/1', 'Soma tensao especifica/2');
connect(modelName, 'centrifuga tensao/1', 'Soma tensao especifica/3');
connect(modelName, 'l psiDot squared/1', 'Soma tensao especifica/4');
connect(modelName, 'Soma tensao especifica/1', 'Tensao T/1');

% Signal connections: diagnostics.
connect(modelName, 'Dividir por l/1', 'Mux estados/1');
connect(modelName, 'Integrador psiDot/1', 'Mux estados/2');
connect(modelName, 'Integrador psi/1', 'Mux estados/3');
connect(modelName, 'Mux estados/1', 'Scope estados/1');
connect(modelName, 'Tensao T/1', 'Scope tensao/1');
connect(modelName, 'Integrador psi/1', 'Salvar psi/1');
connect(modelName, 'Integrador psiDot/1', 'Salvar psiDot/1');
connect(modelName, 'Dividir por l/1', 'Salvar psiDDot/1');
connect(modelName, 'Tensao T/1', 'Salvar tensao/1');
connect(modelName, 'alpha/1', 'Salvar alpha/1');
connect(modelName, 'alphaDDot/1', 'Salvar alphaDDot/1');
connect(modelName, 'beta/1', 'Salvar beta/1');
connect(modelName, 'betaDDot/1', 'Salvar betaDDot/1');

set_param(modelName + "/Tempo t", 'BackgroundColor', 'lightBlue');
set_param(modelName + "/Integrador psiDot", 'BackgroundColor', 'yellow');
set_param(modelName + "/Integrador psi", 'BackgroundColor', 'yellow');
set_param(modelName + "/Equacao dinamica", 'BackgroundColor', 'green');
set_param(modelName + "/Tensao T", 'BackgroundColor', 'orange');
addAnnotation(modelName, ...
    'MOVIMENTOS PRESCRITOS: angulo, velocidade e aceleracao consistentes', ...
    [25 0 515 20], 'blue');
addAnnotation(modelName, ...
    'DINAMICA DE psi: centrifuga - gravidade - aceleracao tangencial do braco', ...
    [540 280 1040 300], 'darkGreen');
addAnnotation(modelName, ...
    'betaDDot atua na direcao X2 e nas reacoes; nao se projeta na equacao escalar de psi', ...
    [385 855 1010 875], 'red');

set_param(modelName, 'ZoomFactor', 'FitSystem');
save_system(modelName, modelPath);
if openAfterBuild
    open_system(modelName);
else
    close_system(modelName, 0);
end
end

function addMotionFcn(modelName, name, profile, position, derivative)
arguments
    modelName
    name
    profile
    position
    derivative = 0
end
modelName = string(modelName);
name = string(name);
profile = string(profile);
switch derivative
    case 0
        expression = profile + ".initialAngle + " + profile + ".meanRate*u + " + ...
            profile + ".amplitude*(sin(" + profile + ".frequency*u + " + ...
            profile + ".phase) - sin(" + profile + ".phase))";
    case 1
        expression = profile + ".meanRate + " + profile + ".amplitude*" + ...
            profile + ".frequency*cos(" + profile + ".frequency*u + " + ...
            profile + ".phase)";
    case 2
        expression = "-" + profile + ".amplitude*" + profile + ...
            ".frequency^2*sin(" + profile + ".frequency*u + " + ...
            profile + ".phase)";
end
add_block('simulink/User-Defined Functions/Fcn', modelName + "/" + name, ...
    'Expr', char(expression), ...
    'Position', [position(1) position(2) position(1)+115 position(2)+30]);
end

function addWorkspaceSink(modelName, name, variable, position)
add_block('simulink/Sinks/To Workspace', modelName + "/Salvar " + name, ...
    'VariableName', variable, 'SaveFormat', 'Timeseries', ...
    'Position', [position(1) position(2) position(1)+105 position(2)+30]);
end

function connect(modelName, source, destination)
add_line(modelName, source, destination, 'autorouting', 'on');
end

function addAnnotation(modelName, text, position, color)
annotation = Simulink.Annotation(modelName, text);
annotation.Position = position;
annotation.ForegroundColor = color;
end