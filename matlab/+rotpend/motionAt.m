function motion = motionAt(t, p)
%MOTIONAT Evaluate the prescribed motions and their first two derivatives.

if ~isempty(p.motionFunction)
    values = p.motionFunction(t);
    assert(isnumeric(values) && isequal(size(values), [6, 1]) && ...
        all(isfinite(values)), 'rotpend:InvalidMotionOutput', ...
        'motionFunction(t) must return a finite 6-by-1 vector.');
else
    alpha = evaluateProfile(t, p.alphaProfile);
    beta = evaluateProfile(t, p.betaProfile);
    values = [alpha; beta];
end

motion = struct( ...
    'alpha', values(1), ...
    'alphaDot', values(2), ...
    'alphaDDot', values(3), ...
    'beta', values(4), ...
    'betaDot', values(5), ...
    'betaDDot', values(6));
motion.theta = motion.alpha + motion.beta;
motion.omega = motion.alphaDot + motion.betaDot;
motion.omegaDot = motion.alphaDDot + motion.betaDDot;
end

function values = evaluateProfile(t, profile)
argument = profile.frequency*t + profile.phase;
angle = profile.initialAngle + profile.meanRate*t + ...
    profile.amplitude*(sin(argument) - sin(profile.phase));
rate = profile.meanRate + profile.amplitude*profile.frequency*cos(argument);
acceleration = -profile.amplitude*profile.frequency^2*sin(argument);
values = [angle; rate; acceleration];
end
