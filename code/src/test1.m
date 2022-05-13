%% test1.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-05-12
% Last modified: 2022-
% Reference: [1] [CDT::season::How this function works](https://www.chadagreene.com/CDT/season_documentation.html#16)
%            [2] [CDT::season::Seasons vs Climatology](https://www.chadagreene.com/CDT/season_documentation.html#17)
%            [3] [CDT::season::Other ways to define seasonality](https://www.chadagreene.com/CDT/season_documentation.html#19)
%            [4] [CDT::climatology::Description](https://www.chadagreene.com/CDT/climatology_documentation.html#2)
%            [5] [CDT::season::Description](https://www.chadagreene.com/CDT/season_documentation.html#2)
% Toolbox:   [T1] M_Map: [M_Map: A mapping package for Matlab](https://www.eoas.ubc.ca/~rich/map.html)
%            [T2] CDT: [Climate Data Tools for Matlab](https://github.com/chadagreene/CDT)
%            [T3] [SEA-MAT: Matlab Tools for Oceanographic Analysis](https://sea-mat.github.io/sea-mat/)

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

%% data

Fs = 12;
sst_tr_coeff = trend(sst,Fs,'dim',3,'omitnan') * 1/Fs;
sst_tr = zeros(size(sst));
for k = 1:size(sst,3)
    sst_tr(:,:,k) = sst_tr_coeff * k;
end
sst_climatology = climatology(sst,time_month,'monthly','dim',3,'detrend','linear','full'); % y_climatology = y_0 + y_season
sst_var = sst - sst_tr - sst_climatology; % interannual variability (+ noise)
sst_detrend = sst_var + sst_climatology;

%% EOF

%
TF_lon_range = lon > -Inf & lon < +Inf;
TF_lat_range = lat > -Inf & lat < +Inf;
TF_time_range = datetime(1900,1,1) < time_month & time_month < datetime(2019,12,30);
[eof_maps_ori,pc_ori,expvar_ori] = eof(double(sst(:,:,TF_time_range)),3);
[eof_maps_var,pc_var,expvar_var] = eof(double(sst_var(:,:,TF_time_range)),3);
[eof_maps_detr,pc_detr,expvar_detr] = eof(double(sst_detrend(:,:,TF_time_range)),3);

%% plot

num_EOF = 3;

%% Fig.1 original

figure('Name',"Fig.1 (EOF original)")
t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");
%%% EOF
t_axes = nexttile(t_TCL,1);
pcolor(t_axes,lon(TF_lon_range),lat(TF_lat_range),eof_maps_ori(:,:,num_EOF).');
shading(t_axes,"interp");
hold on
[C,h] = contour(t_axes,lon(TF_lon_range),lat(TF_lat_range),eof_maps_ori(:,:,num_EOF).','LineWidth',0.2,'LineColor','black','ShowText','off');
hold off
clabel(C,h,"Interpreter",'latex','FontSize',6)
% caxis(t_axis,caxis_limits)
colormap(t_axes,cmocean('balance'))
cb = colorbar(t_axes,"eastoutside","TickLabelInterpreter","latex");
set(t_axes,"TickLabelInterpreter","latex","YTick",-30:5:30,"YTickLabel","$"+[string(30:-5:5)+"^{\circ}\rm{S}","0^{\circ}",string(5:5:30)+"^{\circ}\rm{N}"]+"$","XTick",120:30:270,"XTickLabel",{'$120^{\circ}\rm{E}$','$150^{\circ}\rm{E}$','$180^{\circ}$','$150^{\circ}\rm{W}$','$120^{\circ}\rm{W}$','$90^{\circ}\rm{W}$'},"TickDir","out",'YDir','normal');
%
[~,t_title_s] = title(t_TCL,sprintf("\\bf EOF-%d (original)",num_EOF),"Guorui Wei 120034910021",'Interpreter','latex');
set(t_title_s,'FontSize',8);

%%% pc
t_axes = nexttile(t_TCL,2);
t_plot_pc = plot(t_axes,datenum(time_month(TF_time_range)),pc_ori(num_EOF,:),'-', ...
    "DisplayName",'pc');
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out','XLimitMethod','tight');
legend(t_axes,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
datetick(t_axes,'x','yyyy','keepticks');
xlabel(t_axes,"$t$ (?)",FontSize=10,Interpreter="latex");
ylabel(t_axes,"pc","FontSize",10,"Interpreter","latex");
title(t_axes,sprintf("\\bf pc (original) (EOF-%d), expvar = %g",num_EOF,expvar_ori(num_EOF)),"Interpreter","latex");
exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test1_EOF-%d-ori.emf",num_EOF),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test1_EOF-%d-ori.png",num_EOF),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

%% Fig.2 variability

figure('Name',"Fig.2 (EOF variability)")
t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");
%%% EOF
t_axes = nexttile(t_TCL,1);
pcolor(t_axes,lon(TF_lon_range),lat(TF_lat_range),eof_maps_var(:,:,num_EOF).');
shading(t_axes,"interp");
hold on
[C,h] = contour(t_axes,lon(TF_lon_range),lat(TF_lat_range),eof_maps_var(:,:,num_EOF).','LineWidth',0.2,'LineColor','black','ShowText','off');
hold off
clabel(C,h,"Interpreter",'latex','FontSize',6)
% caxis(t_axis,caxis_limits)
colormap(t_axes,cmocean('balance'))
cb = colorbar(t_axes,"eastoutside","TickLabelInterpreter","latex");
set(t_axes,"TickLabelInterpreter","latex","YTick",-30:5:30,"YTickLabel","$"+[string(30:-5:5)+"^{\circ}\rm{S}","0^{\circ}",string(5:5:30)+"^{\circ}\rm{N}"]+"$","XTick",120:30:270,"XTickLabel",{'$120^{\circ}\rm{E}$','$150^{\circ}\rm{E}$','$180^{\circ}$','$150^{\circ}\rm{W}$','$120^{\circ}\rm{W}$','$90^{\circ}\rm{W}$'},"TickDir","out",'YDir','normal');
%
[~,t_title_s] = title(t_TCL,sprintf("\\bf EOF-%d (variability)",num_EOF),"Guorui Wei 120034910021",'Interpreter','latex');
set(t_title_s,'FontSize',8);

%%% pc
t_axes = nexttile(t_TCL,2);
t_plot_pc = plot(t_axes,datenum(time_month(TF_time_range)),pc_var(num_EOF,:),'-', ...
    "DisplayName",'pc');
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out','XLimitMethod','tight');
legend(t_axes,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
datetick(t_axes,'x','yyyy','keepticks');
xlabel(t_axes,"$t$ (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes,"pc","FontSize",10,"Interpreter","latex");
title(t_axes,sprintf("\\bf pc (variability) (EOF-%d), expvar = %g",num_EOF,expvar_var(num_EOF)),"Interpreter","latex");
exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test1_EOF-%d-var.emf",num_EOF),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test1_EOF-%d-var.png",num_EOF),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

%% Fig.3 detrend only

figure('Name',"Fig.3 (EOF detrend only)")
t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");
%%% EOF
t_axes = nexttile(t_TCL,1);
pcolor(t_axes,lon(TF_lon_range),lat(TF_lat_range),eof_maps_detr(:,:,num_EOF).');
shading(t_axes,"interp");
hold on
[C,h] = contour(t_axes,lon(TF_lon_range),lat(TF_lat_range),eof_maps_detr(:,:,num_EOF).','LineWidth',0.2,'LineColor','black','ShowText','off');
hold off
clabel(C,h,"Interpreter",'latex','FontSize',6)
% caxis(t_axis,caxis_limits)
colormap(t_axes,cmocean('balance'))
cb = colorbar(t_axes,"eastoutside","TickLabelInterpreter","latex");
set(t_axes,"TickLabelInterpreter","latex",'XLimitMethod','tight', ...
    "YTick",-30:5:30,"YTickLabel","$"+[string(30:-5:5)+"^{\circ}\rm{S}","0^{\circ}",string(5:5:30)+"^{\circ}\rm{N}"]+"$","XTick",120:30:270,"XTickLabel",{'$120^{\circ}\rm{E}$','$150^{\circ}\rm{E}$','$180^{\circ}$','$150^{\circ}\rm{W}$','$120^{\circ}\rm{W}$','$90^{\circ}\rm{W}$'},"TickDir","out",'YDir','normal');
%
[~,t_title_s] = title(t_TCL,sprintf("\\bf EOF-%d (detrend only)",num_EOF),"Guorui Wei 120034910021",'Interpreter','latex');
set(t_title_s,'FontSize',8);

%%% pc
t_axes = nexttile(t_TCL,2);
t_plot_pc = plot(t_axes,datenum(time_month(TF_time_range)),pc_detr(num_EOF,:),'-', ...
    "DisplayName",'pc');
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out','XLimitMethod','tight');
legend(t_axes,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
datetick(t_axes,'x','yyyy','keepticks');
xlabel(t_axes,"$t$ (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes,"pc","FontSize",10,"Interpreter","latex");
title(t_axes,sprintf("\\bf pc (detrend only) (EOF-%d), expvar = %g",num_EOF,expvar_detr(num_EOF)),"Interpreter","latex");
exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test1_EOF-%d-detr.emf",num_EOF),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test1_EOF-%d-detr.png",num_EOF),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')

%% local functions

%% Initialize environment

function [] = init_env()
    % Initialize environment
    %
    % set up project directory
    if ~isfolder("../doc/fig/")
        mkdir ../doc/fig/
    end
    % configure searching path
    mfile_fullpath = mfilename('fullpath'); % the full path and name of the file in which the call occurs, not including the filename extension.
    mfile_fullpath_without_fname = mfile_fullpath(1:end-strlength(mfilename));
    addpath(genpath(mfile_fullpath_without_fname + "../data"), ...
            genpath(mfile_fullpath_without_fname + "../inc")); % adds the specified folders to the top of the search path for the current MATLAB® session.

    return;
end
