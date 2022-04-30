%joint pdf demo script
%

num=100000;
yox=0.5;
% theta=pi/6;
theta=0.5*atan(2*0.5/(1-0.5));
xox=sqrt(cos(theta)^2+2*0.5*cos(theta)*sin(theta)+0.5*sin(theta)^2);
yox=sqrt(0.5*cos(theta)^2-2*0.5*cos(theta)*sin(theta)+sin(theta)^2);
xlim=5;
nbin=50;

x=xox*randn(num,1);
y=yox*randn(num,1);

z=x+i*y;
z=z*exp(i*theta);
x=real(z);
y=imag(z);

plot(x,y,'.');
axis equal
axis([-xlim xlim -xlim xlim]);
grid on;
xlabel('x');
ylabel('y');

bin=linspace(-xlim,xlim,nbin);
n=hist2d(x,y,bin,bin)/(bin(2)-bin(1))^2/num;

figure;
contourf(bin,bin,n');
axis equal
axis([-xlim xlim -xlim xlim]);
grid on;
xlabel('x');
ylabel('y');
colorbar;

