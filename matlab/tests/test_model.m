function tests = test_model
tests = functiontests(localfunctions);
end

function testReducesToSimplePendulum(testCase)
p = rotpend.defaultParameters();
p.alphaRate = 0;
p.betaRate = 0;
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
omega = p1.alphaRate + p1.betaRate;
expectedDelta = omega^2*deltaR*cos(x(1))/p1.l;

dx1 = rotpend.rhs(t, x, p1);
dx2 = rotpend.rhs(t, x, p2);
verifyEqual(testCase, dx2(2) - dx1(2), expectedDelta, ...
    'RelTol', 1e-13);
end
