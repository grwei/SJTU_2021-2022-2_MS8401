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
Wm=(m1.*(m1-1).*m2.*(m2-1))./(m1+m2-3).*X.^(m1+m2-3);
Wm(isnan(Wm))=0;

b=zeros(M,1);
b(2:M)=X.^(1:M-1);

xx=(0:dx:X)';
GG=bsxfun(@power,xx,0:M-1);

misfit=[];
modsize=[];
error=[];
icolor=-1;
col=get(gca,'colororder');
ncol=size(col,1);
lambda=input('lambda? ');
while ~isempty(lambda)
   for ii=1:length(lambda);
      icolor=icolor+1;
      Gmg=(G'*G+lambda(ii)*Wm)\G';
      m=Gmg*d;
      dd=GG*m;
      plot(xx,dd,'color',col(mod(icolor,ncol)+1,:));
      misfit=[misfit; (G*m-d)'*(G*m-d)];
      modsize=[modsize; m'*Wm*m];
      error=[error; b'*Gmg*Gmg'*b];
   end
   lambda=input('lambda? ');
end

hold off;

figure;
plot(misfit,modsize,'x');
xlabel('Misfit');
ylabel('Model Size');

figure
plot(misfit,error,'x');
xlabel('Misfit');
ylabel('Error in first derivative');
