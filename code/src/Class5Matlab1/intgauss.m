%Linear estimate interpolation using gaussian correlation.
%
d=input('Data (2-vector for values at t=[-1 1])? ');
scale=input('e-folding scales? ');
noise=input('Noise? ');
d=d(:);
t=(-5:0.1:5)';
skill=zeros(length(t),length(scale));
x=zeros(size(skill));
skillt=zeros(size(skill));
xt=zeros(size(skill));
for n=1:length(scale)
   cov=[1+noise exp(-(2/scale(n))^2); exp(-(2/scale(n))^2) 1+noise];
   ct=[exp(-((t+1)/scale(n)).^2) exp(-((t-1)/scale(n)).^2)];
   skill(:,n)=diag(ct/cov*ct');
   x(:,n)=ct/cov*d;
   ctt=-2/(scale(n).^2)*[t+1 t-1].*ct;
   skillt(:,n)=diag(ctt/cov*ctt')/(2/(scale(n).^2));
   xt(:,n)=ctt/cov*d;
end
figure;
subplot(2,1,1)
plot(t,x),xlabel('t'),ylabel('x');
subplot(2,1,2)
plot(t,skill),xlabel('t'),ylabel('skill')
figure;
subplot(2,1,1)
plot(t,xt),xlabel('t'),ylabel('dxdt');
subplot(2,1,2)
plot(t,skillt),xlabel('t'),ylabel('skill-dxdt')
