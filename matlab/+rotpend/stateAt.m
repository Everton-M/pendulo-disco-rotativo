function out = stateAt(t, x, p)
%STATEAT Kinematics, acceleration, tension and residual at one instant.

psi = x(1);
psiDot = x(2);
alpha = p.alpha0 + p.alphaRate*t;
beta = p.beta0 + p.betaRate*t;
theta = alpha + beta;
omega = p.alphaRate + p.betaRate;

dx = rotpend.rhs(t, x, p);
psiDDot = dx(2);
rho = p.r + p.l*sin(psi);
rhoDot = p.l*psiDot*cos(psi);

RzAlpha = rotationZ(alpha);
RzTheta = rotationZ(theta);

out.positionA = [0; 0; p.a];
out.positionB = out.positionA + RzAlpha*[p.b; 0; 0];
out.positionC = out.positionB + [0; 0; p.c];
out.positionD = out.positionC + RzTheta*[0; p.r; 0] + [0; 0; p.h];
out.positionE = out.positionD + RzTheta*[0; p.l*sin(psi); -p.l*cos(psi)];

velocityE_B2 = [ ...
     p.b*p.alphaRate*sin(beta) - omega*rho; ...
     p.b*p.alphaRate*cos(beta) + rhoDot; ...
     p.l*psiDot*sin(psi)];
out.velocityE = RzTheta*velocityE_B2;

accelerationE_B2 = [ ...
    -p.b*p.alphaRate^2*cos(beta) - 2*p.l*omega*psiDot*cos(psi); ...
     p.b*p.alphaRate^2*sin(beta) - omega^2*rho ...
        + p.l*psiDDot*cos(psi) - p.l*psiDot^2*sin(psi); ...
     p.l*psiDDot*sin(psi) + p.l*psiDot^2*cos(psi)];
out.accelerationE_B2 = accelerationE_B2;
out.accelerationE = RzTheta*accelerationE_B2;

out.tension = p.m*( ...
      p.g*cos(psi) ...
    - p.b*p.alphaRate^2*sin(beta)*sin(psi) ...
    + omega^2*rho*sin(psi) ...
    + p.l*psiDot^2);

torque = p.appliedTorque(t, x);
out.dynamicResidual = p.l*psiDDot + p.g*sin(psi) ...
    + p.b*p.alphaRate^2*sin(beta)*cos(psi) ...
    - omega^2*rho*cos(psi) ...
    + p.damping/(p.m*p.l)*psiDot ...
    - torque/(p.m*p.l);

out.mechanicalEnergy = 0.5*p.m*dot(out.velocityE, out.velocityE) ...
    + p.m*p.g*out.positionE(3);
out.alpha = alpha;
out.beta = beta;
out.theta = theta;
out.psiDDot = psiDDot;
end

function R = rotationZ(angle)
R = [cos(angle), -sin(angle), 0; ...
     sin(angle),  cos(angle), 0; ...
              0,           0, 1];
end
