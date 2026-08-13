function tests = test_rk4
tests = functiontests(localfunctions);
end

function testFourthOrderConvergence(testCase)
f = @(~, y) y;
[~, yCoarse] = numerics.rk4(f, [0,1], 1, 0.1);
[~, yFine] = numerics.rk4(f, [0,1], 1, 0.05);
errorCoarse = abs(yCoarse(end) - exp(1));
errorFine = abs(yFine(end) - exp(1));
verifyGreaterThan(testCase, errorCoarse/errorFine, 12);
end

function testReachesFinalTime(testCase)
[t, ~] = numerics.rk4(@(~,y) -y, [0,1], 1, 0.3);
verifyEqual(testCase, t(end), 1, 'AbsTol', eps);
end
