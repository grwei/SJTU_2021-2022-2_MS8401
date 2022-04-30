%script to demonstrate function fitting
%

N=5;
X=10;
noise=2;
dx=0.1;

x=linspace(0,X,N)';
d=x+noise*randn(size(x));
plot(x,d,'kx');
hold on;

icolor=-1;
col=get(gca,'colororder');

for M=1:N
   
   G=bsxfun(@power,x,0:M-1);
   
   xx=(0:dx:X)';
   GG=bsxfun(@power,xx,0:M-1);
   
   ncol=size(col,1);
   icolor=icolor+1;
   m=(G'*G)\G'*d;
   dd=GG*m;
   plot(xx,dd,'color',col(mod(icolor,ncol)+1,:));
   disp((G*m-d)'*(G*m-d))
   
end

hold off;

