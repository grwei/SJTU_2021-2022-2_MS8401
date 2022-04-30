% script to run lorenz model

[t,y]=lornz;
figure
% comet(y(:,1),y(:,3))
% plot(y(:,1),y(:,3))
% replacement for comet
h=animatedline;
axis([-20,25,0,60]);
xlabel('X')
ylabel('Z')

for k=1:length(t)
   addpoints(h,y(k,1),y(k,3));
   pause(1/100);
   drawnow
end

figure
plot(t,y(:,1))
xlabel('t')
ylabel('X')
