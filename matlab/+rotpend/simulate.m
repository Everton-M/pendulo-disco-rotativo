function sim = simulate(p, cfg)
%SIMULATE Integrate the model and compute derived physical quantities.

arguments
    p (1,1) struct
    cfg.tspan (1,2) double = [0, 20]
    cfg.step (1,1) double {mustBePositive} = 2e-3
    cfg.solver (1,1) string {mustBeMember(cfg.solver,["rk4","ode45"])} = "rk4"
    cfg.relativeTolerance (1,1) double {mustBePositive} = 1e-9
    cfg.absoluteTolerance (1,1) double {mustBePositive} = 1e-11
end

rotpend.validateParameters(p);
y0 = [p.psi0; p.psiRate0];
odefun = @(t, x) rotpend.rhs(t, x, p);

switch cfg.solver
    case "rk4"
        [t, x] = numerics.rk4(odefun, cfg.tspan, y0, cfg.step);
    case "ode45"
        sampleTimes = (cfg.tspan(1):cfg.step:cfg.tspan(2)).';
        if sampleTimes(end) < cfg.tspan(2)
            sampleTimes(end+1,1) = cfg.tspan(2);
        end
        options = odeset('RelTol', cfg.relativeTolerance, ...
            'AbsTol', cfg.absoluteTolerance);
        [t, x] = ode45(odefun, sampleTimes, y0, options);
end

n = numel(t);
positionE = zeros(n,3);
velocityE = zeros(n,3);
accelerationE = zeros(n,3);
tension = zeros(n,1);
energy = zeros(n,1);
residual = zeros(n,1);
psiDDot = zeros(n,1);
alpha = zeros(n,1);
alphaDot = zeros(n,1);
alphaDDot = zeros(n,1);
beta = zeros(n,1);
betaDot = zeros(n,1);
betaDDot = zeros(n,1);

for k = 1:n
    sample = rotpend.stateAt(t(k), x(k,:).', p);
    positionE(k,:) = sample.positionE.';
    velocityE(k,:) = sample.velocityE.';
    accelerationE(k,:) = sample.accelerationE.';
    tension(k) = sample.tension;
    energy(k) = sample.mechanicalEnergy;
    residual(k) = sample.dynamicResidual;
    psiDDot(k) = sample.psiDDot;
    alpha(k) = sample.alpha;
    alphaDot(k) = sample.alphaDot;
    alphaDDot(k) = sample.alphaDDot;
    beta(k) = sample.beta;
    betaDot(k) = sample.betaDot;
    betaDDot(k) = sample.betaDDot;
end

sim = struct('t', t, 'x', x, 'psiDDot', psiDDot, ...
    'alpha', alpha, 'alphaDot', alphaDot, 'alphaDDot', alphaDDot, ...
    'beta', beta, 'betaDot', betaDot, 'betaDDot', betaDDot, ...
    'positionE', positionE, 'velocityE', velocityE, ...
    'accelerationE', accelerationE, 'tension', tension, ...
    'mechanicalEnergy', energy, 'dynamicResidual', residual, ...
    'solver', cfg.solver, 'configuration', cfg);
end
