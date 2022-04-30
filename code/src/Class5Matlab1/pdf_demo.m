% pdf_demo script
%

load pdfdemo.mat;
figure;
plot(x);
figure;
plot(y);

%%

num=input('Number of bins? ');
figure;
[nx,xbin]=hist(x,num);
bar(xbin,nx);
figure;
[ny,ybin]=hist(y,num);
bar(ybin,ny);

sum(nx)
sum(ny)

%%

pdfx=nx/(xbin(2)-xbin(1))/sum(nx);
pdfy=ny/(ybin(2)-ybin(1))/sum(ny);

figure;
bar(xbin,pdfx);
figure;
bar(ybin,pdfy);

sum(pdfx)*(xbin(2)-xbin(1))
sum(pdfy)*(ybin(2)-ybin(1))
