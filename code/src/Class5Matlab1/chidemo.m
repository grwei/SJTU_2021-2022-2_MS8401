%script to demonstrate the use of chi2 distribution for calculating
%confidence intervals
%

N=input('Degrees of freedom ');
perc=input('Confidence limit ');
eps=(1-perc)/2;

mul=N/chi2inv(1-eps,N)
muu=N/chi2inv(eps,N)

x=linspace(0,10*N,1000);
y=chi2pdf(x,N);

figure
plot(x,y,x,normpdf(x,N,sqrt(2*N)));
grid on;
set(gca,'xlim',[0 2*N]);
title([int2str(N) ' degrees of freedom']);
xlabel('$N\hat\mu_2/\mu_2$','interpreter','latex');
ylabel('pdf');
legend('Chi-square','Normal');

figure
plot(x*mul/N,y*N/mul,x*muu/N,y*N/muu);
yax=get(gca,'ylim');
hold on;
plot([mul mul],[0 yax(2)],'k',[muu muu],[0 yax(2)],'k');
hold off;
grid on;
set(gca,'xlim',[0 5]);
title([int2str(N) ' degrees of freedom, ' num2str(perc) ' confidence interval']);
xlabel('$\hat\mu_2$','interpreter','latex');
ylabel('pdf');
