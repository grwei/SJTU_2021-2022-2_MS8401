%script to demonstrate function fitting
%

M=5;
N=5;
X=10;
noise=2;
dx=0.1;

x=linspace(0,X,N)';
d=x+noise*randn(size(x));
plot(x,d,'kx');
hold on;

G=bsxfun(@power,x,0:M-1);

[m1,m2]=meshgrid(0:M-1,0:M-1);
Wm=(m1.*m2)./(m1+m2-1).*X.^(m1+m2-1);
Wm(isnan(Wm))=0;

xx=(0:dx:X)';
GG=bsxfun(@power,xx,0:M-1);

misfit=[];
modsize=[];
icolor=-1;
col=get(gca,'colororder');
ncol=size(col,1);
lambda=input('lambda? ');
while ~isempty(lambda)
   for ii=1:length(lambda);
      icolor=icolor+1;
      m=(G'*G+lambda(ii)*Wm)\G'*d;
      dd=GG*m;
      plot(xx,dd,'color',col(mod(icolor,ncol)+1,:));
      misfit=[misfit; (G*m-d)'*(G*m-d)];
      modsize=[modsize; m'*Wm*m];
   end
   lambda=input('lambda? ');
end

hold off;

figure
plot(misfit,modsize,'x');
xlabel('Misfit');
ylabel('Model Size');
