%% hw3.m
% Description: MATLAB code for Homework 3 (MS8401, 2022 Spring)
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-06-18
% Last modified: 2022-06-21
% References: [1] https://paos.colorado.edu/research/wavelets/
% Toolbox:    [T2] [Climate Data Tools for Matlab](https://github.com/chadagreene/CDT)
%             [T3] https://github.com/chris-torrence/wavelets
% Data:       [D1] [NOAA Extended Reconstructed Sea Surface Temperature (SST) V5](https://psl.noaa.gov/data/gridded/data.noaa.ersst.v5.html)

%% Initialize project

clc; clear; close all
init_env();

%% Read data

nc_path = "..\data\sst.mnmean.nc";
nc_info = ncinfo(nc_path);
sst = double(ncread(nc_path,'sst')); % [deg C] sst(lon,lat,time_month)
sst(sst == ncreadatt(nc_path,'/sst','missing_value')) = NaN; % Monthly Means of Sea Surface Temperature (SST)
lon = double(ncread(nc_path,'lon')); % [deg E]
lat = double(ncread(nc_path,'lat')); % [deg N]
time_month = (datetime(1854,1,15) + calmonths(0:size(sst,3)-1)).';

%% pre-processing

sst_dtr = detrend3(sst,'omitnan'); % Remove the global warming signal (detrended)
sst_var = deseason(sst_dtr,time_month); % Remove seasonal cycles (detrended and seasonal cycle removed -> variability)

%%% Nino3.4: 170°W - 120°W, 5°S - 5°N
% Niño3.4 SST anomaly index: SST anomalies averaged in the box 170°W - 120°W, 5°S - 5°N

TF_lon_range = lon >= 190 & lon <= 240;
TF_lat_range = lat >= -5 & lat <= 5;
TF_time_range = datetime(1900,1,1) < time_month & time_month < datetime(2020,12,30);

T_s = 1/12; % [year]
Nino3_4_index = squeeze(mean(sst_var(TF_lon_range,TF_lat_range,TF_time_range),[1 2],"omitnan"));

%% 0. 

var_Nino3_4_index = var(Nino3_4_index);
[ac,lags] = xcorr(Nino3_4_index,Nino3_4_index,2,"normalized");
alpha_ = (ac(lags == 1) + sqrt(ac(lags == 2)))/2;
% alpha_ = 0.72;
P_k = (1-alpha_^2)./(1+alpha_^2-2*alpha_*cos(2*pi*(0:length(Nino3_4_index)-1).'/length(Nino3_4_index)));

%% 1. Perform spectrum analysis on the Niño3.4 SST anomaly index

Nino3_4_DFT = fft(Nino3_4_index)/length(Nino3_4_index);
Nino3_4_freq = (0:length(Nino3_4_DFT)-1)/length(Nino3_4_DFT)/T_s; % [1/year]
Nino3_4_cycle = 1./Nino3_4_freq;
TF_freq_avail = Nino3_4_cycle > -Inf;

%%% create figure

figure('Name',"Fig.1 Nino3.4 index and its DFT");
t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");

% Nino3.4 index

t_axes = nexttile(t_TCL,1);
plot(t_axes,time_month(TF_time_range),Nino3_4_index,'-',"DisplayName",'Nino3.4 index');
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out','XLimitMethod','tight');
xticks(t_axes,datetime(1900,1,15) + calyears(0:20:120))
xtickformat(t_axes,'yyyy')
xlabel(t_axes,"$t$ (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes,"SST anomaly ($^{\circ}\rm{C}$)","FontSize",10,"Interpreter","latex");
title(t_axes,sprintf("\\bf Nino3.4 index"),"Interpreter","latex");

% DFT of Nino3.4 index

xtick_cycle = [50,10,7:-1:1];
t_axes = nexttile(t_TCL,2);
plot(t_axes,Nino3_4_freq(TF_freq_avail),abs(Nino3_4_DFT(TF_freq_avail)).^2, ...
    '-',"DisplayName",'$|\hat{x}(k)|^2$');
hold on
plot(t_axes,Nino3_4_freq(TF_freq_avail),P_k*var_Nino3_4_index/length(Nino3_4_index), ...
    '--',"DisplayName",sprintf("$\\sigma^2 P_k/N, \\, \\alpha = %.2g$",alpha_))
yl = ylim(t_axes);
plot(t_axes,Nino3_4_freq(TF_freq_avail),P_k*var_Nino3_4_index/length(Nino3_4_index)/2*chi2inv(0.95,2), ...
    '--',"DisplayName",sprintf("$\\sigma^2 \\chi^2_2(0.95) P_k/(2N)$"))
hold off
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out','XLimitMethod','tight')
xlim(t_axes,[-Inf,1/0.9]);
ylim(t_axes,yl);
xticks(t_axes,1./xtick_cycle);
xticklabels(t_axes,string(xtick_cycle));
xlabel(t_axes,"cycle (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes,"magnitude","FontSize",10,"Interpreter","latex");
legend(t_axes,"Interpreter","latex","Box","off",'Location','best');
title(t_axes,sprintf("\\bf DFT of Nino3.4 index"),"Interpreter","latex");

%
exportgraphics(t_TCL,sprintf("..\\doc\\fig\\hw3\\hw3_DFT_Nino3_4.png"),'Resolution',1000,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_TCL,sprintf("..\\doc\\fig\\hw3\\hw3_DFT_Nino3_4.emf"),'Resolution',1000,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

%% 2. Perform wavelet analysis on the Niño3.4 SST anomaly index

t_fig = figure('Name',"Fig.2 wavelet analysis of the Niño3.4 SST anomaly index");
hw3_wavetest;
%
exportgraphics(t_fig,sprintf("..\\doc\\fig\\hw3\\hw3_wavelet_Nino3_4.png"),'Resolution',1000,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_fig,sprintf("..\\doc\\fig\\hw3\\hw3_wavelet_Nino3_4.emf"),'Resolution',1000,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

%% local functions

%% Initialize environment

function [] = init_env()
% Initialize environment
%
    % set up project directory
    if ~isfolder("../doc/fig/hw3")
        mkdir ../doc/fig/hw3
    end
    % configure searching path
    mfile_fullpath = mfilename('fullpath'); % the full path and name of the file in which the call occurs, not including the filename extension.
    mfile_fullpath_without_fname = mfile_fullpath(1:end-strlength(mfilename));
    addpath(genpath(mfile_fullpath_without_fname + "../data"), ...
            genpath(mfile_fullpath_without_fname + "../inc")); % adds the specified folders to the top of the search path for the current MATLAB® session.

    return;
end
