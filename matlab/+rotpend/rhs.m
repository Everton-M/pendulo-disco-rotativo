function dx = rhs(t, x, p)
%RHS First-order nonlinear equation of motion.
% State x = [psi; psiDot]. Angles alpha and beta have constant rates.

psi = x(1);
psiDot = x(2);
beta = p.beta0 + p.betaRate*t;
omega = p.alphaRate + p.betaRate;
rho = p.r + p.l*sin(psi);
torque = p.appliedTorque(t, x);

psiDDot = ( ...
      omega^2*rho*cos(psi) ...
    - p.g*sin(psi) ...
    - p.b*p.alphaRate^2*sin(beta)*cos(psi) ...
    - (p.damping/(p.m*p.l))*psiDot ...
    + torque/(p.m*p.l) ) / p.l;

dx = [psiDot; psiDDot];
end
