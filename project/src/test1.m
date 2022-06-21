%% test1.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-06-19
% Last modified: 2022-
% Reference: [1] [CDT::season::How this function works](https://www.chadagreene.com/CDT/season_documentation.html#16)
%            [2] [CDT::season::Seasons vs Climatology](https://www.chadagreene.com/CDT/season_documentation.html#17)
%            [3] [CDT::season::Other ways to define seasonality](https://www.chadagreene.com/CDT/season_documentation.html#19)
%            [4] [CDT::climatology::Description](https://www.chadagreene.com/CDT/climatology_documentation.html#2)
%            [5] [CDT::season::Description](https://www.chadagreene.com/CDT/season_documentation.html#2)
% Toolbox:   [T1] M_Map: [M_Map: A mapping package for Matlab](https://www.eoas.ubc.ca/~rich/map.html)
%            [T2] CDT: [Climate Data Tools for Matlab](https://github.com/chadagreene/CDT)
%            [T3] [SEA-MAT: Matlab Tools for Oceanographic Analysis](https://sea-mat.github.io/sea-mat/)
% Data:      [D1] [NOAA Extended Reconstructed Sea Surface Temperature (SST) V5](https://psl.noaa.gov/data/gridded/data.noaa.ersst.v5.html)

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

%% Parameters

TF_lon_range = lon > -Inf & lon < +Inf;
TF_lat_range = lat > -Inf & lat < +Inf;
TF_time_range = datetime(1900,1,1) < time_month & time_month < datetime(2020,12,30);

%% Simulation

%%% prepare

sst = sst(TF_lon_range,TF_lat_range,TF_time_range);
num_months = 1:size(sst,3);
name_months = mod(num_months,12);
name_months(name_months == 0) = 12; % name of month. 1 = Jan, ..., 12 = Dec.

%%% Algorithm A ("climatology" determined *after* detrending)

trend_A_coeff = zeros(size(sst,1,2));
season_A_cat = zeros([size(sst,1,2),12]);
vari_A = zeros(size(sst));

for i = 1:size(sst,1)
    for j = 1:size(sst,2)
        [trend_A_coeff(i,j),season_A_cat(i,j,:),vari_A(i,j,:)] = algo_A(num_months/12,sst(i,j,:),name_months);
    end
end

%%% Algorithm B ("climatology" determined *before* detrending)

trend_B_coeff = zeros(size(sst,1,2));
season_B_cat = zeros([size(sst,1,2),12]);
vari_B = zeros(size(sst));

for i = 1:size(sst,1)
    for j = 1:size(sst,2)
        [trend_B_coeff(i,j),season_B_cat(i,j,:),vari_B(i,j,:)] = algo_B(num_months/12,sst(i,j,:),name_months);
    end
end

%% compare algo A and B

vari_diff = vari_B-vari_A;
vari_diff_monthly_avg = zeros([size(vari_diff,1,2),12]);

for i = 1:size(vari_diff,1)
    for j = 1:size(vari_diff,2)
        [~,~,vari_diff_monthly_avg(i,j,:)] = climatology_month(vari_diff(i,j,:),name_months);
    end
end

%% Create figure.

global_map(lon,lat,trend_A_coeff,"trend (Algorithm A)","trend_A.png","($^{\circ}\rm{C}$) / year",1);
global_map(lon,lat,trend_B_coeff,"trend (Algorithm B)","trend_B.png","($^{\circ}\rm{C}$) / year",1);
global_map(lon,lat,trend_B_coeff - trend_A_coeff,"swap-error: trend","swap_error_trend.png","($^{\circ}\rm{C}$) / year",1);
global_map(lon,lat,sqrt(mean((vari_B-vari_A).^2,3,"omitnan")),"swap-error: variability (root-mean-square)","vari_err_RMS.png","$^{\circ}\rm{C}$",1);

for i = 1:12
    global_map(lon,lat,season_B_cat(:,:,i) - season_A_cat(:,:,i), ...
        sprintf("swap-error: season (month %d)",i), ...
        sprintf("swap_error_season_month%d.png",i),"$^{\circ}\rm{C}$",1);
    global_map(lon,lat,vari_diff_monthly_avg(:,:,i), ...
        sprintf("swap-error: variability (avg of month %d)",i), ...
        sprintf("swap_error_vari_month%d.png",i),"$^{\circ}\rm{C}$",1);
end

%% local functions

%% Initialize environment

function [] = init_env()
    % Initialize environment
    %
    % set up project directory
    if ~isfolder("../doc/fig/test1/")
        mkdir ../doc/fig/test1/
    end
    % configure searching path
    mfile_fullpath = mfilename('fullpath'); % the full path and name of the file in which the call occurs, not including the filename extension.
    mfile_fullpath_without_fname = mfile_fullpath(1:end-strlength(mfilename));
    addpath(genpath(mfile_fullpath_without_fname + "../data"), ...
            genpath(mfile_fullpath_without_fname + "../inc")); % adds the specified folders to the top of the search path for the current MATLAB® session.

    return;
end

%% Algorithm A: "climatology" determined *after* detrending

function [trend_A_coeff,season_A_cat,vari_A] = algo_A(t,y,name_months)
%algo_A - Algorithm A: "climatology" determined *after* detrending
%
% Syntax: [trend_A_coeff,season_A_cat,vari_A] = algo_A(t,y,name_months)
%
% Long description
    arguments
        t               % [year]
        y
        name_months     % name of month. 1 = Jan, ..., 12 = Dec.
    end
    
    t = squeeze(t);
    y = squeeze(y);

    if (~iscolumn(t))
        t = t.';
    end

    if (~iscolumn(y))
        y = y.';
    end

    %%% Step-1  Determines the "trend" of the orginal data.

    [trend_A_p_sc,~,mu_A] = polyfit(t,y,1);
    trend_A_p = poly_sc2ori(trend_A_p_sc,mu_A);
    trend_A_coeff = trend_A_p(1);
    trend_A = polyval(trend_A_p_sc,t,[],mu_A);

    %%% Step-2  Determines the "climatology" and "anomaly" ("variability") of
    % the *detrended* data.

    [~,vari_A,climatology_A_cat] = climatology_month(y-trend_A,name_months);
    y_0_A = mean(climatology_A_cat);            % the long-term mean
    season_A_cat = climatology_A_cat - y_0_A;   % seasonal anomaly for the entire time series

    return;
end

function [trend_B_coeff,season_B_cat,vari_B] = algo_B(t,y,name_months)
    %algo_B - Algorithm B: "climatology" determined *before* detrending
    %
    % Syntax: [trend_B_coeff,season_B_cat,vari_B] = algo_B(t,y,name_months)
    %
    % Long description
    arguments
        t               % [year]
        y
        name_months     % name of month. 1 = Jan, ..., 12 = Dec.
    end
    
    t = squeeze(t);
    y = squeeze(y);

    if (~iscolumn(t))
        t = t.';
    end

    if (~iscolumn(y))
        y = y.';
    end

    %%% Step-1  Determines the "climatology" and "anomaly"

    [~,anomalies_B,climatology_B_cat] = climatology_month(y,name_months);
    y_0_B = mean(climatology_B_cat);            % the long-term mean
    season_B_cat = climatology_B_cat - y_0_B;   % seasonal anomaly for the entire time series

    %%% Step-2  Determines the linear "trend" of "anomaly"

    [trend_B_p_sc,~,mu_B] = polyfit(t,anomalies_B,1);
    trend_B_p = poly_sc2ori(trend_B_p_sc,mu_B);
    trend_B_coeff = trend_B_p(1);
    trend_B = polyval(trend_B_p_sc,t,[],mu_B);

    %%% Step-3  Determines the "variability" (with "noise", expected)

    vari_B = anomalies_B - trend_B;

    return;
end    

%% convert scaled-and-centered polynomial coefficient to original ones.

function [p_ori] = poly_sc2ori(p_sc,mu)
% convert scaled-and-centered polynomial coefficient to original ones
% Details
    arguments
        p_sc % polynomial coefficients ordered by descending powers
        mu
    end
    poly_n = length(p_sc) - 1;
    p_ori = nan(size(p_sc));
    for i = 0:poly_n
        % coefficient of x^i-term 
        %   = \sum_i^n a_k/sigma^k \mathop{C}_k^i (-\bar{x})^(k-i)
        p_ori(poly_n+1-i) = sum(p_sc(poly_n+1-i:-1:1)./(mu(2).^(i:poly_n)).*arrayfun(@(k) nchoosek(k,i),i:poly_n).*(-mu(1)).^((0:poly_n-i)));
    end
    % verify
    thrs = 1e-8;
    x = 0:10;
    f_ori = polyval(p_ori,x);
    f_sc = polyval(p_sc,x,[],mu);
    [M,I] = max(abs((f_ori-f_sc)./f_sc),[],"omitnan");
    if (M > thrs)
        warning("ERROR (poly_sc2ori): f_ori(%d) = %d \neq f_sc(%d) = %d!",x(I),f_ori(I),x(I),f_sc(I));
    end

    return;
end

%% climatology (monthly): average values for each of the 12 months of the year

function [climatology,anomalies,climatology_cat] = climatology_month(data,name_months)
% average values for each of the 12 months of the year
% Details.
    arguments
        data
        name_months     % name of month. 1 = Jan, ..., 12 = Dec.
    end

    data = squeeze(data);
    if (~iscolumn(data))
        data = data.';
    end

    climatology_cat = nan(12,1);        % (12 months)
    climatology = nan(length(data),1);  % (entire series)
    for months_ = 1:12
        climatology_cat(months_) = mean(data(name_months == months_),"omitnan");
        climatology(name_months == months_) = climatology_cat(months_);
    end
    anomalies = data - climatology; % (entire series)

    return;
end

%% global contour

%% Fig.1(a) global trend: Algorithm A

function [] = global_map(lon,lat,data,fig_title,filename,unit_name,export_enable)
    arguments
        lon
        lat
        data
        fig_title
        filename
        unit_name = "$^{\circ}\rm{C}$"
        export_enable = 0;
    end
    
    figure('Name',fig_title)
    t_TCL = tiledlayout(1,1,"TileSpacing","tight","Padding","tight");
    t_axes = nexttile(t_TCL,1);
    pcolor(t_axes,lon,lat,data.');
    shading(t_axes,"interp");
    hold on
    [C,h] = contour(t_axes,lon,lat,data.','LineWidth',0.2,'LineColor','black','ShowText','off');
    borders('countries','center',180,'color',rgb('gray'))
    hold off
    clabel(C,h,"Interpreter",'latex','FontSize',6)
    % BEGIN patch
    cl = caxis;
    if (cl(1) >= 0)
    cl(1) = -cl(2)/10;
    caxis(t_axes,cl)
    end
    % END patch
    colormap(t_axes,cmocean('balance','pivot',0))
    cb = colorbar(t_axes,"eastoutside","TickLabelInterpreter","latex");
    set(cb.Label,"String",unit_name,"Interpreter","latex")
    set(t_axes,"TickLabelInterpreter","latex","TickDir","out",'YDir','normal','Box','off');
    xticks(t_axes,-180:45:360)
    xtickformat(t_axes,'%g$^{\\circ}\\rm{E}$')
    yticks(-90:30:90)
    ytickformat(t_axes,'%g$^{\\circ}\\rm{N}$')
    %
    title(t_TCL,sprintf("\\bf %s",fig_title),'Interpreter','latex');
%     set(t_title_s,'FontSize',8);
    %
    if export_enable
        exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test1\\%s",filename),'Resolution',1000,'ContentType','auto','BackgroundColor','none','Colorspace','rgb') 
    end
    
    return;
end
