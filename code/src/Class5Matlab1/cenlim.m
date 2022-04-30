%script to demonstrate the central limit theorem
%

num=100000;
bin=[-5:0.1:5];
nvar=input('Number of random variables to sum ');

x=(rand(nvar,num)-0.5)*sqrt(12/nvar);
y=sum(x,1);

n=hist(y,bin);
pdfy=n/num/(bin(2)-bin(1));

bar(bin,pdfy);

hold on;
plot(bin,normpdf(bin,0,1),'r');
hold off;

disp(sprintf('mean = %f',mean(y)));
disp(sprintf('2nd moment = %f',moment(y,2)));
disp(sprintf('3rd moment = %f',moment(y,3)));
disp(sprintf('4th moment = %f',moment(y,4)));
disp(sprintf('5th moment = %f',moment(y,5)));
disp(sprintf('6th moment = %f',moment(y,6)));
