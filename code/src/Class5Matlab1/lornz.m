function [t,y]=lornz
%solve the lorenz equation
%

global SIGMA RHO BETA
SIGMA = 10.;
RHO = 30.;
BETA = 8./3.;

y0 = [1 1 1];
t0=0;
tfinal=100;

%options=odeset('maxstep',0.002);
%[t,y]=ode23(@lorenzeq,[t0 tfinal],y0,options);
[t,y]=ode23(@lorenzeq,[t0 tfinal],y0);



%===============================================================================
function ydot = lorenzeq(t,y)
%LORENZEQ Equation of the Lorenz chaotic attractor.
%   ydot = lorenzeq(t,y).
%   The differential equation is written in almost linear form.

global SIGMA RHO BETA

A = [-SIGMA, SIGMA, 0; RHO, -1, -y(1) ;0, y(1), -BETA];
    
ydot = A*y;
