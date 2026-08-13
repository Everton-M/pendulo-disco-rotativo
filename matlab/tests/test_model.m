function tests = test_model
tests = functiontests(localfunctions);
end

function testReducesToSimplePendulum(testCase)
p = rotpend.defaultParameters();
p.motionFunction = @(t) zeros(6,1);
p.r = 0;
x = [0.30; -0.20];
dx = rotpend.rhs(0.7, x, p);
verifyEqual(testCase, dx(2), -p.g*sin(x(1))/p.l, ...
    'RelTol', 1e-13);
end

function testEquationResidualIsZero(testCase)
p = rotpend.defaultParameters();
x = [0.45; -0.7];
sample = rotpend.stateAt(0.83, x, p);
verifyLessThan(testCase, abs(sample.dynamicResidual), 1e-12);
end

function testAnalyticalVelocityMatchesFiniteDifference(testCase)
p = rotpend.defaultParameters();
t = 0.71;
x = [0.22; -0.31];
dt = 1e-7;
s0 = rotpend.stateAt(t, x, p);
xNext = x + dt*rotpend.rhs(t, x, p);
s1 = rotpend.stateAt(t + dt, xNext, p);
finiteDifference = (s1.positionE - s0.positionE)/dt;
verifyEqual(testCase, finiteDifference, s0.velocityE, 'AbsTol', 2e-6);
end

function testAnalyticalAccelerationMatchesFiniteDifference(testCase)
p = rotpend.defaultParameters();
t = 0.71;
x = [0.22; -0.31];
dt = 2e-6;
s0 = rotpend.stateAt(t, x, p);
xNext = x + dt*rotpend.rhs(t, x, p);
s1 = rotpend.stateAt(t + dt, xNext, p);
finiteDifference = (s1.velocityE - s0.velocityE)/dt;
verifyEqual(testCase, finiteDifference, s0.accelerationE, 'AbsTol', 2e-4);
end

function testVerticalOffsetOnlyChangesHeight(testCase)
p1 = rotpend.defaultParameters();
p2 = p1;
p2.h = p1.h + 0.40;
t = 0.91;
x = [0.27; -0.18];

verifyEqual(testCase, rotpend.rhs(t, x, p2), rotpend.rhs(t, x, p1), ...
    'AbsTol', 10*eps);
s1 = rotpend.stateAt(t, x, p1);
s2 = rotpend.stateAt(t, x, p2);
verifyEqual(testCase, s2.positionE - s1.positionE, [0; 0; 0.40], ...
    'AbsTol', 10*eps);
end

function testRadialOffsetChangesCentrifugalTerm(testCase)
p1 = rotpend.defaultParameters();
p2 = p1;
deltaR = 0.08;
p2.r = p1.r + deltaR;
t = 0.63;
x = [0.31; 0.12];
motion = rotpend.motionAt(t, p1);
expectedDelta = motion.omega^2*deltaR*cos(x(1))/p1.l;

dx1 = rotpend.rhs(t, x, p1);
dx2 = rotpend.rhs(t, x, p2);
verifyEqual(testCase, dx2(2) - dx1(2), expectedDelta, ...
    'RelTol', 1e-13);
end

function testArmAngularAccelerationEntersPendulumEquation(testCase)
p = rotpend.defaultParameters();
p.motionFunction = @(t) [0; 0; 2; 0; 0; 0];
x = [0; 0];
dx = rotpend.rhs(0, x, p);
verifyEqual(testCase, dx(2), -2*p.b/p.l, 'RelTol', 1e-13);
end

function testBetaAccelerationActsTransversely(testCase)
p1 = rotpend.defaultParameters();
p2 = p1;
p1.motionFunction = @(t) [0.1; 0.7; 0.2; 0.3; 0.8; 0];
p2.motionFunction = @(t) [0.1; 0.7; 0.2; 0.3; 0.8; 4];
x = [0.25; -0.1];
t = 0.4;
verifyEqual(testCase, rotpend.rhs(t, x, p2), rotpend.rhs(t, x, p1), ...
    'AbsTol', 10*eps);
s1 = rotpend.stateAt(t, x, p1);
s2 = rotpend.stateAt(t, x, p2);
rho = p1.r + p1.l*sin(x(1));
verifyEqual(testCase, s2.accelerationE_B2(1)-s1.accelerationE_B2(1), ...
    -4*rho, 'RelTol', 1e-13);
end

function testDefaultMotionDerivativesAreConsistent(testCase)
p = rotpend.defaultParameters();
t = 0.81;
dt = 1e-5;
m0 = rotpend.motionAt(t, p);
mm = rotpend.motionAt(t-dt, p);
mp = rotpend.motionAt(t+dt, p);
verifyEqual(testCase, (mp.alpha-mm.alpha)/(2*dt), m0.alphaDot, ...
    'AbsTol', 1e-9);
verifyEqual(testCase, (mp.alphaDot-mm.alphaDot)/(2*dt), m0.alphaDDot, ...
    'AbsTol', 1e-9);
verifyEqual(testCase, (mp.beta-mm.beta)/(2*dt), m0.betaDot, ...
    'AbsTol', 1e-9);
verifyEqual(testCase, (mp.betaDot-mm.betaDot)/(2*dt), m0.betaDDot, ...
    'AbsTol', 1e-9);
end