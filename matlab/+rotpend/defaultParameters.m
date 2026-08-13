function p = defaultParameters()
%DEFAULTPARAMETERS Illustrative SI parameters for the rotating pendulum.
% Replace these values with measured/CAD values before physical validation.

p.a = 0.30;              % [m] O-to-A vertical offset (kinematics only)
p.b = 0.50;              % [m] rotating arm length A-to-B
p.c = 0.10;              % [m] B-to-C vertical offset (kinematics only)
p.r = 0.20;              % [m] radial offset C-to-D along +j_2
p.h = 0.15;              % [m] vertical offset C-to-D along +k_2
p.l = 0.35;              % [m] pendulum length D-to-E
p.m = 0.25;              % [kg] point mass at E
p.g = 9.80665;           % [m/s^2]

% Smooth prescribed motions. Each profile combines a mean rotation with a
% harmonic modulation, so angle, velocity and acceleration remain consistent.
p.alphaProfile = angularProfile(0.0, 1.00, 0.20, 0.80, 0.0);
p.betaProfile = angularProfile(0.0, 1.60, 0.16, 0.55, pi/4);

% Optional custom law. It must return
% [alpha; alphaDot; alphaDDot; beta; betaDot; betaDDot] at time t.
p.motionFunction = [];

p.psi0 = deg2rad(10);    % [rad]
p.psiRate0 = 0.0;        % [rad/s]

p.damping = 0.0;         % [N*m*s/rad], optional hinge damping
p.appliedTorque = @(t, x) 0.0; % [N*m], positive in +psi direction
end

function profile = angularProfile(initialAngle, meanRate, amplitude, frequency, phase)
profile = struct( ...
    'initialAngle', initialAngle, ...
    'meanRate', meanRate, ...
    'amplitude', amplitude, ...
    'frequency', frequency, ...
    'phase', phase);
end
