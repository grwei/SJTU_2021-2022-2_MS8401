function n=hist2d(x,y,binx,biny)
%function n=hist2d(x,y,binx,biny) makes a 2-d histogram 
%of x and y in bins binx and biny.
%All inputs are vectors.
%Output n is a matrix of size [length(binx) length(biny)].
%

%D. Rudnick, August 18, 2003

nbinx=length(binx);
nbiny=length(biny);
n=zeros(nbinx,nbiny);

ii=~isnan(x) & ~isnan(y);
x=x(ii);
y=y(ii);

for nn=1:length(x)
   [dum,i]=min(abs(x(nn)-binx));
   [dum,j]=min(abs(y(nn)-biny));
   n(i,j)=n(i,j)+1;
end
