%script to demonstrate confidence intervals for the sample mean
%

N=input('Degrees of freedom ');
perc=input('Confidence limit ');
eps=(1-perc)/2;

ml=-norminv(1-eps,0,1/sqrt(N))
mu=-norminv(eps,0,1/sqrt(N))

x=linspace(-5,5,1000);
y=normpdf(x,0,1/sqrt(N));

figure
plot(x+ml,y,x+mu,y)
yax=get(gca,'ylim');
hold on;
plot([ml ml],[0 yax(2)],'k',[mu mu],[0 yax(2)],'k');
hold off;
grid on;
title([int2str(N) ' degrees of freedom, ' num2str(perc) ' confidence interval']);
xlabel('$\hat m$','interpreter','latex');
ylabel('pdf');
