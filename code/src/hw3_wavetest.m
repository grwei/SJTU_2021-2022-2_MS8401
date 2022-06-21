%% hw3_wavetest.m
% Modified 2022-06-19 by Wei Guorui (313017602@qq.com): change sst data

function [] = hw3_wavetest()

%WAVETEST Example Matlab script for WAVELET, using Nino3.4 SST dataset
%
% See "http://paos.colorado.edu/research/wavelets/"
% Written January 1998 by C. Torrence
%
% Modified Oct 1999, changed Global Wavelet Spectrum (GWS) to be sideways,
%   changed all "log" to "log2", changed logarithmic axis on GWS to
%   a normal axis.

%------------------------------------------------------ Computation

% normalize by standard deviation (not necessary, but makes it easier
% to compare with plot on Interactive Wavelet page, at
% "http://paos.colorado.edu/research/wavelets/plot/"

nc_path = "..\data\sst.mnmean.nc";
sst = double(ncread(nc_path,'sst')); % [deg C] sst(lon,lat,time_month)
sst(sst == ncreadatt(nc_path,'/sst','missing_value')) = NaN; % Monthly Means of Sea Surface Temperature (SST)
lon = double(ncread(nc_path,'lon')); % [deg E]
lat = double(ncread(nc_path,'lat')); % [deg N]
time_month = (datetime(1854,1,15) + calmonths(0:size(sst,3)-1)).';
sst_dtr = detrend3(sst,'omitnan'); % Remove the global warming signal (detrended)
sst_var = deseason(sst_dtr,time_month); % Remove seasonal cycles (detrended and seasonal cycle removed -> variability)

%%% Nino3.4.4: 170°W - 120°W, 5°S - 5°N
% Niño3.4 SST anomaly index: SST anomalies averaged in the box 170°W - 120°W, 5°S - 5°N

TF_lon_range = lon >= 190 & lon <= 240;
TF_lat_range = lat >= -5 & lat <= 5;
TF_time_range = datetime(1900,1,1) < time_month & time_month < datetime(2020,12,30);
sst = squeeze(mean(sst_var(TF_lon_range,TF_lat_range,TF_time_range),[1 2],"omitnan"));

variance = std(sst)^2;
sst = (sst - mean(sst))/sqrt(variance) ;

n = length(sst);
dt = 1/12 ;
time = (0:length(sst)-1)*dt + 1900 ;  % construct time array
xlim = [1900,2021-1/12];  % plotting range
pad = 1;      % pad the time series with zeroes (recommended)
dj = 0.25;    % this will do 4 sub-octaves per octave
s0 = 2*dt;    % this says start at a scale of 2 months
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
set(gca,'XLim',xlim(:),"FontName","Times New Roman")
xlabel('Time (year)',"FontName","Times New Roman")
ylabel('Nino3.4 SST (degC)',"FontName","Times New Roman")
title('a) Nino3.4 Sea Surface Temperature (seasonal)',"FontName","Times New Roman")
hold off

%--- Contour plot wavelet power spectrum
subplot('position',[0.1 0.37 0.65 0.28])
levels = [0.0625,0.125,0.25,0.5,1,2,4,8,16] ;
Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
contour(time,log2(period),log2(power),log2(levels));  %*** or use 'contourfill'
%imagesc(time,log2(period),log2(power));  %*** uncomment for 'image' plot
xlabel('Time (year)',"FontName","Times New Roman")
ylabel('Period (years)',"FontName","Times New Roman")
title('b) Nino3.4 SST Wavelet Power Spectrum',"FontName","Times New Roman")
set(gca,'XLim',xlim(:),"FontName","Times New Roman")
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
xlabel('Power (degC^2)',"FontName","Times New Roman")
title('c) Global Wavelet Spectrum',"FontName","Times New Roman")
set(gca,'YLim',log2([min(period),max(period)]), ...
	'YDir','reverse', ...
	'YTick',log2(Yticks(:)), ...
	'YTickLabel','')
set(gca,'XLim',[0,1.25*max(global_ws)],"FontName","Times New Roman")

%--- Plot 2--8 yr scale-average time series
subplot('position',[0.1 0.07 0.65 0.2])
plot(time,scale_avg)
set(gca,'XLim',xlim(:),"FontName","Times New Roman")
xlabel('Time (year)',"FontName","Times New Roman")
ylabel('Avg variance (degC^2)',"FontName","Times New Roman")
title('d) 2-8 yr Scale-average Time Series',"FontName","Times New Roman")
hold on
plot(xlim,scaleavg_signif+[0,0],'--')
hold off

% end of code

end
