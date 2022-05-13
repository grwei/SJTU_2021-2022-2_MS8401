%% hw1.m
% Description: MATLAB code for Homework 1 (MS8401, 2022 Spring)
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-04-29
% Last modified: 2022-05-13
% Toolbox: [T1] [M_Map: A mapping package for Matlab](https://www.eoas.ubc.ca/~rich/map.html)
%          [T2] [Climate Data Tools for Matlab](https://github.com/chadagreene/CDT)
% Data:    [D1] [NOAA Extended Reconstructed Sea Surface Temperature (SST) V5](https://psl.noaa.gov/data/gridded/data.noaa.ersst.v5.html)

%% Initialize project

clc; clear; close all
init_env();

%% Read data

nc_path = "..\data\sst.mnmean.nc";
nc_info = ncinfo(nc_path);
sst = ncread(nc_path,'sst'); % [deg C] sst(lon,lat,time_month)
sst(sst == ncreadatt(nc_path,'/sst','missing_value')) = NaN; % Monthly Means of Sea Surface Temperature (SST)
lon = ncread(nc_path,'lon'); % [deg E]
lat = ncread(nc_path,'lat'); % [deg N]
time_month = (datetime(1854,1,15) + calmonths(0:size(sst,3)-1)).';

%% Fig.1

%%% Fig.1(a) SST

figure('Name',"Fig.1")
t_TCL = tiledlayout(1,2,"TileSpacing","tight","Padding","tight");

%
TF_lon_range = lon > 135 & lon < 265;
TF_lat_range = lat <= 2 & lat >= -2;
TF_time_range = datetime(1980,1,1) < time_month & time_month < datetime(2019,12,30);
SST_lat_mean = squeeze(mean(sst(TF_lon_range,TF_lat_range,TF_time_range),2,"omitnan"));
time_tick = datetime(1980,1,15) + calyears(0:3:2019-1980);

% plot
t_axis_SST = nexttile(t_TCL,1);
pcolor(t_axis_SST,lon(TF_lon_range),datenum(time_month(TF_time_range)),SST_lat_mean.');
shading(t_axis_SST,"interp");
hold on
[C,h] = contour(t_axis_SST,lon(TF_lon_range),datenum(time_month(TF_time_range)),SST_lat_mean.',20:30,'LineWidth',0.2,'LineColor','black','ShowText','off',"TextList",22:2:30);
hold off
clabel(C,h,26:2:30,"Interpreter",'latex','FontSize',6)
colormap(t_axis_SST,'jet')
% caxis(t_axis_SST,[20,30]);
cb = colorbar(t_axis_SST,"southoutside","TickLabelInterpreter","latex");
% set(cb.Label,'String',"degree Celsius",'Interpreter','latex');
set(t_axis_SST,"TickLabelInterpreter","latex","YTick",datenum(time_tick),"XTick",140:40:260,"XTickLabel",{'$140^{\circ}\rm{E}$','$180^{\circ}$','$140^{\circ}\rm{W}$','$100^{\circ}\rm{W}$'},"TickDir","out",'YDir','reverse');
datetick(t_axis_SST,'y','yy','keepticks');
title(t_axis_SST,"SST ($^{\circ}\rm{C}$)",'Interpreter','latex');

%%% Fig.1(b) SST anomaly
% y = y_0 + y_tr + y_season + y_var + y_noise
% [CDT/season_documentation/How this function works](https://www.chadagreene.com/CDT/season_documentation.html#16)

%
Fs = 12; % tr = trend(y,Fs) specifies a sampling rate Fs. For example, to obtain a trend per year from data collected at monthly resolution, set Fs equal to 12. This syntax assumes all values in y are equally spaced in time.
SST_lat_mean_tr = trend(SST_lat_mean,Fs,'dim',2,'omitnan') * 1/Fs * (0:size(SST_lat_mean,2)-1);
SST_lat_mean_climatology = climatology(SST_lat_mean,time_month(TF_time_range),'monthly','dim',2,'detrend','linear','full'); % y_climatology = y_0 + y_season
SST_lat_mean_var = SST_lat_mean - SST_lat_mean_tr - SST_lat_mean_climatology; % interannual variability (+ noise)

% plot
t_axis_SST_anomaly = nexttile(t_TCL,2);
pcolor(t_axis_SST_anomaly,lon(TF_lon_range),datenum(time_month(TF_time_range)),SST_lat_mean_var.');
shading(t_axis_SST_anomaly,"interp");
hold on
[C,h] = contour(t_axis_SST_anomaly,lon(TF_lon_range),datenum(time_month(TF_time_range)),SST_lat_mean_var.',-3:3,'LineWidth',0.2,'LineColor','black','ShowText','off');
hold off
clabel(C,h,"Interpreter",'latex','FontSize',6)
colormap(t_axis_SST_anomaly,'jet')
cb = colorbar(t_axis_SST_anomaly,"southoutside","TickLabelInterpreter","latex");
set(t_axis_SST_anomaly,"TickLabelInterpreter","latex","YTick",datenum(time_tick),"YTickLabel",{},"XTick",140:40:260,"XTickLabel",{'$140^{\circ}\rm{E}$','$180^{\circ}$','$140^{\circ}\rm{W}$','$100^{\circ}\rm{W}$'},"TickDir","out",'YDir','reverse');
datetick(t_axis_SST_anomaly,'y','yy','keepticks');
set(t_axis_SST_anomaly,"YTickLabel",{});
title(t_axis_SST_anomaly,"SST Anomalies ($^{\circ}\rm{C}$)",'Interpreter','latex');

%
ylabel(t_TCL,"year","Interpreter",'latex')
[~,t_title_s] = title(t_TCL,"\bf Monthly Mean SST $2^{\circ}\rm{S}$ to $2^{\circ}\rm{N}$ Average","Guorui Wei 120034910021",'Interpreter','latex');
set(t_title_s,'FontSize',8);
%
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_1.emf",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_1.png",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

%% Fig.2 & 3

%
TF_lon_range = lon > 135 & lon < 265;
TF_lat_range = lat <= 10 & lat >= -10;
TF_time_range = datetime(1980,1,1) < time_month & time_month < datetime(2019,12,30);
TF_time_El_nino = time_month == datetime(1997,12,15);
TF_time_La_nina = time_month == datetime(1998,12,15);

%%%

sst_tr_coeff = trend(sst,Fs,'dim',3,'omitnan') * 1/Fs;
sst_tr = zeros(size(sst));
for k = 1:size(sst,3)
    sst_tr(:,:,k) = sst_tr_coeff * k;
end
sst_climatology = climatology(sst,time_month,'monthly','dim',3,'detrend','linear','full'); % y_climatology = y_0 + y_season
sst_var = deseason(detrend3(sst,'omitnan'),time_month); % interannual variability (+ noise)

% Fig.2
figure('Name',"Fig.2 (El_nino)")
t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");
t_TCL = fig2(t_TCL,TF_lon_range,TF_lat_range,TF_time_El_nino,sst_var,sst,lon,lat,28:30,"Dec 1997");
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_2.emf",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_2.png",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

% Fig.3
figure('Name',"Fig.3 (La_nina)")
t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");
t_TCL = fig2(t_TCL,TF_lon_range,TF_lat_range,TF_time_La_nina,sst_var,sst,lon,lat,28:30,"Dec 1998");
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_3.emf",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_3.png",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

%% Fig.4

%
TF_lon_range = lon > 119 & lon < 285;
TF_lat_range = lat <= 30 & lat >= -30;
%
sst_var_Va = var(sst_var(TF_lon_range,TF_lat_range,:),0,3,"omitnan");
sst_var_Sk = skewness(sst_var(TF_lon_range,TF_lat_range,:),0,3);

%%% Fig.4(a)
figure('Name',"Fig.4(a) (variance)")
t_TCL = tiledlayout(1,1,"TileSpacing","tight","Padding","tight");
t_TCL = fig4(t_TCL,lon,lat,TF_lon_range,TF_lat_range,sst_var_Va,[-0.2,2.5],"\bf Fig.4(a) Variance");
%
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_4a.emf",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_4a.png",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

%%% Fig.4(b)
figure('Name',"Fig.4(b) (skewness)")
t_TCL = tiledlayout(1,1,"TileSpacing","tight","Padding","tight");
t_TCL = fig4(t_TCL,lon,lat,TF_lon_range,TF_lat_range,sst_var_Sk,[-1.5,1.5],"\bf Fig.4(b) Skewness");
%
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_4b.emf",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_TCL,"..\\doc\\fig\\hw1\\hw1_Fig_4b.png",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

%% local functions

%% Initialize environment

function [] = init_env()
% Initialize environment
%
    % set up project directory
    if ~isfolder("../doc/fig/hw1")
        mkdir ../doc/fig/hw1
    end
    % configure searching path
    mfile_fullpath = mfilename('fullpath'); % the full path and name of the file in which the call occurs, not including the filename extension.
    mfile_fullpath_without_fname = mfile_fullpath(1:end-strlength(mfilename));
    addpath(genpath(mfile_fullpath_without_fname + "../data"), ...
            genpath(mfile_fullpath_without_fname + "../inc")); % adds the specified folders to the top of the search path for the current MATLAB® session.

    return;
end

%% 

function [t_TCL] = fig2(t_TCL,TF_lon_range,TF_lat_range,TF_time_target,sst_var,sst,lon,lat,SST_contour_label_v,month_name_str,main_title_str)
    arguments
        t_TCL
        TF_lon_range
        TF_lat_range
        TF_time_target
        sst_var
        sst
        lon
        lat
        SST_contour_label_v = 28:30
        month_name_str = "Dec 1997"
        main_title_str = "\bf TAO Monthly Mean SST $(^{\circ} \rm{C})$"
    end

    %
    SST_mean = sst(TF_lon_range,TF_lat_range,TF_time_target);
    SST_var = sst_var(TF_lon_range,TF_lat_range,TF_time_target);
    
    % plot mean SST
    t_axis_SST = nexttile(t_TCL,1);
    pcolor(t_axis_SST,lon(TF_lon_range),lat(TF_lat_range),SST_mean.');
    shading(t_axis_SST,"interp");
    hold on
    [C,h] = contour(t_axis_SST,lon(TF_lon_range),lat(TF_lat_range),SST_mean.','LineWidth',0.2,'LineColor','black','ShowText','off');
    hold off
    clabel(C,h,SST_contour_label_v,"Interpreter",'latex','FontSize',6)
    colormap(t_axis_SST,'jet')
    cb = colorbar(t_axis_SST,"eastoutside","TickLabelInterpreter","latex");
    set(t_axis_SST,"TickLabelInterpreter","latex","YTick",-10:5:10,"YTickLabel",{'$10^{\circ}\rm{S}$','$5^{\circ}\rm{S}$','$0^{\circ}$','$5^{\circ}\rm{N}$','$10^{\circ}\rm{N}$'},"XTick",140:20:260,"XTickLabel",{'$140^{\circ}\rm{E}$','$160^{\circ}\rm{E}$','$180^{\circ}$','$160^{\circ}\rm{W}$','$140^{\circ}\rm{W}$','$120^{\circ}\rm{W}$','$100^{\circ}\rm{W}$'},"TickDir","out",'YDir','normal');
    title(t_axis_SST,"\bf " + month_name_str + " Means","Interpreter","latex")
    
    % plot SST varibility
    t_axis_var = nexttile(t_TCL,2);
    pcolor(t_axis_var,lon(TF_lon_range),lat(TF_lat_range),SST_var.');
    shading(t_axis_var,"interp");
    hold on
    [C,h] = contour(t_axis_var,lon(TF_lon_range),lat(TF_lat_range),SST_var.','LineWidth',0.2,'LineColor','black','ShowText','off');
    hold off
    clabel(C,h,"Interpreter",'latex','FontSize',6)
    colormap(t_axis_var,'jet')
    cb = colorbar(t_axis_var,"eastoutside","TickLabelInterpreter","latex");
    set(t_axis_var,"TickLabelInterpreter","latex","YTick",-10:5:10,"YTickLabel",{'$10^{\circ}\rm{S}$','$5^{\circ}\rm{S}$','$0^{\circ}$','$5^{\circ}\rm{N}$','$10^{\circ}\rm{N}$'},"XTick",140:20:260,"XTickLabel",{},"TickDir","out",'YDir','normal');
    title(t_axis_var,"\bf " + month_name_str + " Anomalies","Interpreter","latex")
    
    %
    [~,t_title_s] = title(t_TCL,main_title_str,"Guorui Wei 120034910021",'Interpreter','latex');
    set(t_title_s,'FontSize',8);
end

%% 

function [t_TCL] = fig4(t_TCL,lon,lat,TF_lon_range,TF_lat_range,sst_var_Va,caxis_limits,main_title_str)
    arguments
        t_TCL
        lon
        lat
        TF_lon_range
        TF_lat_range
        sst_var_Va
        caxis_limits = [-0.5,3]
        main_title_str = "\bf Fig.4(a) Variance"
    end

    t_axis = nexttile(t_TCL,1);
    pcolor(t_axis,lon(TF_lon_range),lat(TF_lat_range),sst_var_Va.');
    shading(t_axis,"interp");
    hold on
    [C,h] = contour(t_axis,lon(TF_lon_range),lat(TF_lat_range),sst_var_Va.','LineWidth',0.2,'LineColor','black','ShowText','off');
    hold off
    clabel(C,h,"Interpreter",'latex','FontSize',6)
    caxis(t_axis,caxis_limits)
    colormap(t_axis,'jet')
    cb = colorbar(t_axis,"eastoutside","TickLabelInterpreter","latex");
    set(t_axis,"TickLabelInterpreter","latex","YTick",-30:5:30,"YTickLabel","$"+[string(30:-5:5)+"^{\circ}\rm{S}","0^{\circ}",string(5:5:30)+"^{\circ}\rm{N}"]+"$","XTick",120:30:270,"XTickLabel",{'$120^{\circ}\rm{E}$','$150^{\circ}\rm{E}$','$180^{\circ}$','$150^{\circ}\rm{W}$','$120^{\circ}\rm{W}$','$90^{\circ}\rm{W}$'},"TickDir","out",'YDir','normal');
    %
    [~,t_title_s] = title(t_TCL,main_title_str,"Guorui Wei 120034910021",'Interpreter','latex');
    set(t_title_s,'FontSize',8);
end
