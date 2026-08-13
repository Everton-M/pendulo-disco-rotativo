function [t, y] = rk4(odefun, tspan, y0, step)
%RK4 Classical fourth-order Runge--Kutta integrator with fixed step.
%   [T,Y] = numerics.rk4(F,[T0 TF],Y0,H) integrates Y'=F(T,Y).

arguments
    odefun (1,1) function_handle
    tspan (1,2) double {mustBeFinite}
    y0 (:,1) double {mustBeFinite}
    step (1,1) double {mustBePositive,mustBeFinite}
end

t0 = tspan(1);
tf = tspan(2);
assert(tf > t0, 'numerics:rk4:InvalidInterval', ...
    'The final time must be greater than the initial time.');

numberOfSteps = ceil((tf - t0) / step);
step = (tf - t0) / numberOfSteps; % Land exactly on tf.
t = linspace(t0, tf, numberOfSteps + 1).';
y = zeros(numberOfSteps + 1, numel(y0));
y(1,:) = y0.';

for k = 1:numberOfSteps
    tk = t(k);
    yk = y(k,:).';

    k1 = odefun(tk, yk);
    k2 = odefun(tk + step/2, yk + step*k1/2);
    k3 = odefun(tk + step/2, yk + step*k2/2);
    k4 = odefun(tk + step, yk + step*k3);

    y(k+1,:) = (yk + step*(k1 + 2*k2 + 2*k3 + k4)/6).';
end
end
