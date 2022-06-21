clc 
clear
% 求 NINO3.4
 lon=ncread('sst.mnmean.nc','lon');lon=double(lon);
 lat=ncread('sst.mnmean.nc','lat');lat=double(lat);
 sst=ncread('sst.mnmean.nc','sst');sst=double(sst);
 time=ncread('sst.mnmean.nc','time');
 t0=datenum('1800-01-01');
 t1=time+t0;
 t2=datevec(t1);t3=datestr(t1);
 t4=t2(:,1);
 id=find(t4==1900);id2=find(t4==2020);%553:2004
 sst_0=sst(96:121,42:48,553:2004);
 sst_01=reshape(sst_0,[26,7,12,121]);
 sst_mean_01=squeeze(mean(sst_01,3));


for i = 1:26
    for j = 1:7
        sst_xq(i,j,:) = detrend(squeeze(sst_0(i,j,:)))+nanmean(sst_0(i,j,:));
    end
end

for i = 1:26
    for j = 1:7
        for n = 1:121
            for k = 1:12
                ssta(i,j,(n-1)*12+k) = sst_xq(i,j,(n-1)*12+k)-nanmean(sst_xq(i,j,k:12:end),3);
            end
        end
    end
end
%选择Nino3.4区域
ssta34 = squeeze(nanmean(nanmean(ssta,1),2));
sst_ano=ssta;
sst_ano1=sst_ano(:,1:2,:);
sst_ano1=mean(sst_ano1,2);
sst_ano2=sst_ano(:,6:7,:);
sst_ano2=mean(sst_ano2,2);
sst_ano3=sst_ano(:,3:5,:);
sst_ano0=cat(2,sst_ano1,sst_ano3,sst_ano2);

index2=squeeze(mean(mean(sst_ano0)));

%重新定义时间
index_time=t1(553:2004);
%频率
dt=1/12;
time = [0:length(index2)-1]*dt + 1900 ;  % construct time array
xlim = [1900,2020];  % plotting range
ylim = [-3 3];

%时间序列
 figure
    plot(time,index2)
    set(gca,'XLim',xlim(:),'YLim',ylim(:))
    xlabel('Time (year)')
    ylabel('NINO3.4 SST (°C)')
    title('NINO3.4 Sea Surface Temperature (Monthly)')

%fft 
%%
pc1s=index2;

%PC1功率谱分析
x=pc1s;
x_m=mean(pc1s);
temp=0;
for i=1:length(x)
    temp=temp+(x(i)-x_m)*(x(i)-x_m);
end
Sx=sqrt(temp/length(x));
clear temp

%第一步：计算样本时间序列的自相关系数r

%m为最大滞后时步数
m=fix(length(x)/7);
n=length(x);
for j=1:m
    temp=0;
    for i=1:n-j
        temp=temp+((x(i)-x_m)/Sx)*((x(i+j)-x_m)/Sx);
    end
    r(j)=temp/((n-j));
end
%%
r(2:207)=r(1:206);
clear temp

temp=0;
for i=1:n
    temp=temp+((x(i)-x_m)/Sx)*((x(i)-x_m)/Sx);
end
r(1)=temp/n;
clear temp

%作图
figure(1)
xx=(1:m);
plot(xx,r,'linewidth',1.5);
set(gca,'ylim',[-1 1],'ytick',(0:0.2:1),'yticklabel',{[0:0.2:1]},'xlim',[0 250],'xtick',(0:50:250),...
    'xticklabel',{0:50:250},'fontsize',8);
xlabel('Lag(month)','fontsize',10);
ylabel('correlation coefficient value','fontsize',10);
title('Auto-correlation coefficient of NINO3.4 series as a function of lag time','fontsize',10);
hold on
legend('Step=7');
%第二步：求粗谱S1 
temp=0;
for i=2:m
    temp=temp+r(i);
end
S0=(r(1)+r(end))/(2*m)+temp/m;
clear temp

for k=1:m-1
    temp=0;
    for i=2:m
        temp=temp+r(i)*cos(k*pi*(i-1)/m);
    end
    Sk(k)=(r(1)+2*temp+((-1).^k)*r(end))/m;
end
clear temp

temp=0;
for i=2:m
    temp=temp+((-1).^(i-1))*r(i);
end
Sm=(r(1)+((-1).^m)*r(end))/(2*m)+temp/m;
S1(1)=S0;
S1(2:m)=Sk;
S1(m+1)=Sm;

%第三步：计算平滑功率谱Hanning平滑方法
SS0=(S1(1)+S1(2))/2;
SSk=zeros(m,1);
for i=2:m
    SSk(i)=S1(i-1)/4+S1(i)/2+S1(i+1)/4;
end
SSk=SSk(2:end);
SSm=(S1(end)/2+S1(end-1)/2);
SS(1)=SS0;
SS(2:m)=SSk;
SS(m+1)=SSm;

%第四步：确定频率和周期
f0=0;
for i=1:m
    fk(i)=i/(2*m);
end
f(1)=f0;
f(2:m+1)=fk;%单位：周/时步
T(:)=1./f(:);%单位：时步

%第五步：对谱估计作显著性检验
temp=0;
for i=2:m
    temp=temp+SS(i);
end
SSmean=(SS(1)+SS(end))/(2*m)+temp/m;
redn0=SSmean*((1-r(2)*r(2))/(1+r(2)*r(2)-2*r(2)));
clear temp

for i=1:m
    rednk(i)=SSmean*((1-r(2)*r(2))/(1+r(2)*r(2)-2*r(2)*cos((i*pi)/m)));
end
redn(1)=redn0;
redn(2:m+1)=rednk;%红噪声标准谱

%给定显著性水平a，计算红噪声检验置信上限（临界）谱值
v=(2*n-m/2)/m;%自由度
Sc=redn*chi2inv(1-0.05,v)/v;

figure(2)

%PC1功率谱作图

plot(f,SS,'b-','linewidth',1.5);hold on
plot(f,Sc,'r--','linewidth',1.5);
set(gca,'ylim',[0 0.16],'ytick',(0:0.01:0.16),'yticklabel',{0:0.01:0.16},'xlim',[0 0.15],'xtick',(0:0.05:0.15),...
'xticklabel',{'0','0.05','0.1','0.15'},'fontsize',8);
legend('estimated spectrum','95% red-noise confidence limit','location','northeast');
xlabel('Frequency(cycles/month)','fontsize',10);
ylabel('Power Spectrum','fontsize',10);
grid on

%WAVETEST Example Matlab script for WAVELET, using NINO3 SST dataset
%
% See "http://paos.colorado.edu/research/wavelets/"
% Written January 1998 by C. Torrence
%
% Modified Oct 1999, changed Global Wavelet Spectrum (GWS) to be sideways,
%   changed all "log" to "log2", chandddged logarithmic axis on GWS to
%   a normal axis.

% load 'sst_nino3.dat'   % input SST time series
% sst = sst_nino3;


%小波分析
clear
ii=1;
sst=index2;
%------------------------------------------------------ Computation

% normalize by standard deviation (not necessary, but makes it easier
% to compare with plot on Interactive Wavelet page, at
% "http://paos.colorado.edu/research/wavelets/plot/"
variance = std(sst)^2;
sst = (sst - mean(sst))/sqrt(variance) ;

n = length(sst);
dt = 1/12 ;%一年包含几个数据,0.25是四个
time = [0:length(sst)-1]*dt + 1900 ;  % construct time array
xlim = [1900,2020];  % plotting range
pad = 1;      % pad the time series with zeroes (recommended)
dj = 0.25;    % this will do 4 sub-octaves per octave
s0 = 2*dt;    % this says start at a scale of 6 months
j1 = 7/dj;    % this says do 7 powers-of-two with dj sub-octaves each
lag1 = 0.72;  % lag-1 autocorrelation for red noise background
mother = 'Morlet';

% Wavelet transform:
[wave,period,scale,coi] = wavelet(sst,dt,pad,dj,s0,j1,mother);
power = (abs(wave)).^2 ;        % compute wavelet power spectrum

% Significance levels: (variance=1 for the normalized SST)
[signif,fft_theor] = wave_signif(1.0,dt,scale,0,lag1,-1,-1,mother);
sig95 = (signif')*(ones(1,n));  % expand signif --> (J+1)x(N) array
sig95 = power ./ sig95;         % where ratio > 1, power is significant

% Global wavelet spectrum & significance levels:
global_ws = variance*(sum(power')/n);   % time-average over all times
dof = n - scale;  % the -scale corrects for padding at edges
global_signif = wave_signif(variance,dt,scale,1,lag1,-1,dof,mother);

% Scale-average between El Nino periods of 2--8 years
avg = find((scale >= 2) & (scale < 8));
Cdelta = 0.776;   % this is for the MORLET wavelet
scale_avg = (scale')*(ones(1,n));  % expand scale --> (J+1)x(N) array
scale_avg = power ./ scale_avg;   % [Eqn(24)]
scale_avg = variance*dj*dt/Cdelta*sum(scale_avg(avg,:));   % [Eqn(24)]
scaleavg_signif = wave_signif(variance,dt,scale,2,lag1,-1,[2,7.9],mother);

whos

%------------------------------------------------------ Plotting

%--- Plot time series
subplot('position',[0.1 0.75 0.65 0.2])
plot(time,sst)
set(gca,'XLim',xlim(:))
xlabel('Time (year)')
ylabel('NINO3.4 SST (°C)')
title('a) NINO3.4 Sea Surface Temperature (seasonal)')
hold off

%--- Contour plot wavelet power spectrum
subplot('position',[0.1 0.37 0.65 0.28])
levels = [0.0625,0.125,0.25,0.5,1,2,4,8,16] ;
Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
contour(time,log2(period),log2(power),log2(levels));  %*** or use 'contourfill'
%imagesc(time,log2(period),log2(power));  %*** uncomment for 'image' plot
xlabel('Time (year)')
ylabel('Period (years)')
title('b) NINO3.4 SST Wavelet Power Spectrum')
set(gca,'XLim',xlim(:))
set(gca,'YLim',log2([min(period),max(period)]), ...
	'YDir','reverse', ...
	'YTick',log2(Yticks(:)), ...
	'YTickLabel',Yticks)
% 95% significance contour, levels at -99 (fake) and 1 (95% signif)
hold on
contour(time,log2(period),sig95,[-99,1],'k');
hold on
% cone-of-influence, anything "below" is dubious
plot(time,log2(coi),'k')
hold off

%--- Plot global wavelet spectrum
subplot('position',[0.77 0.37 0.2 0.28])
plot(global_ws,log2(period))
hold on
plot(global_signif,log2(period),'--')
hold off
xlabel('Power (°C)')
title('c) Global Wavelet Spectrum')
set(gca,'YLim',log2([min(period),max(period)]), ...
	'YDir','reverse', ...
	'YTick',log2(Yticks(:)), ...
	'YTickLabel','')
set(gca,'XLim',[0,1.25*max(global_ws)])

%--- Plot 2--8 yr scale-average time series
subplot('position',[0.1 0.07 0.65 0.2])
plot(time,scale_avg,'b')
ylim=[0,1.5];
set(gca,'XLim',xlim(:),'YLim',ylim(:));
xlabel('Time (year)')
ylabel('Avg variance (°C)')
title('d) 2-8 yr Scale-average Time Series')
hold on
plot(xlim,scaleavg_signif+[0,0],'--')
hold off