function dx = rhs(t, x, p)
%RHS First-order nonlinear equation of motion for prescribed base motions.
% State x = [psi; psiDot].

psi = x(1);
psiDot = x(2);
motion = rotpend.motionAt(t, p);
rho = p.r + p.l*sin(psi);
torque = p.appliedTorque(t, x);
armAcceleration = p.b*(motion.alphaDot^2*sin(motion.beta) ...
    + motion.alphaDDot*cos(motion.beta));

psiDDot = ( ...
      motion.omega^2*rho*cos(psi) ...
    - p.g*sin(psi) ...
    - armAcceleration*cos(psi) ...
    - (p.damping/(p.m*p.l))*psiDot ...
    + torque/(p.m*p.l) ) / p.l;

dx = [psiDot; psiDDot];
end