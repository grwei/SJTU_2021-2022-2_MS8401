%% hw2.m
% Description: MATLAB code for Homework 2 (MS8401, 2022 Spring)
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-05-12
% Last modified: 2022-05-14
% References: [1] [CDT::eof documentation](https://www.chadagreene.com/CDT/eof_documentation.html)
%             [2] [Pacific Decadal Oscillation (PDO)](https://psl.noaa.gov/pdo/)
%             [3] [AMO] Trenberth, Kevin, Zhang, Rong & National Center for Atmospheric Research Staff (Eds). Last modified 05 Jun 2021. "The Climate Data Guide: Atlantic Multi-decadal Oscillation (AMO)." Retrieved from https://climatedataguide.ucar.edu/climate-data/atlantic-multi-decadal-oscillation-amo.
%             [4] [PDO] Deser, Clara, Trenberth, Kevin & National Center for Atmospheric Research Staff (Eds). Last modified 06 Jan 2016. "The Climate Data Guide: Pacific Decadal Oscillation (PDO): Definition and Indices." Retrieved from https://climatedataguide.ucar.edu/climate-data/pacific-decadal-oscillation-pdo-definition-and-indices.
%             [5] [NAO] National Center for Atmospheric Research Staff (Eds). Last modified 17 Apr 2022. "The Climate Data Guide: Hurrell North Atlantic Oscillation (NAO) Index (PC-based)." Retrieved from https://climatedataguide.ucar.edu/climate-data/hurrell-north-atlantic-oscillation-nao-index-pc-based.
%             [6] [ENSO] [El Niño Southern Oscillation (ENSO)](https://psl.noaa.gov/enso/)
% Toolbox:    [T1] [M_Map: A mapping package for Matlab](https://www.eoas.ubc.ca/~rich/map.html)
%             [T2] [Climate Data Tools for Matlab](https://github.com/chadagreene/CDT)
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

%% 1. global

TF_lon_range = lon > -Inf & lon < +Inf;
TF_lat_range = lat > -Inf & lat < +Inf;
TF_time_range = datetime(1900,1,1) < time_month & time_month < datetime(2020,12,30);

%%% eof

n_eof = 3; % only calculates the first n modes of variability
[eof_maps,pc,expvar] = eof(sst_var(TF_lon_range,TF_lat_range,TF_time_range),n_eof);
% Optional scaling of Principal Components and EOF maps
for k = 1:size(pc,1)
   % Find the the maximum value in the time series of each principal component:
   maxval = max(abs(pc(k,:)));
   % Divide the time series by its maximum value:
   pc(k,:) = pc(k,:)/maxval;
   % Multiply the corresponding EOF map:
   eof_maps(:,:,k) = eof_maps(:,:,k)*maxval;
end

%%% Create figure.
for num_EOF = 1:3
    EOF_fig(num_EOF,"Global",lon(TF_lon_range),lat(TF_lat_range),time_month(TF_time_range),eof_maps,pc,expvar,1)
end

%% 2. the Pacific Ocean (85°33'S ~ 65°44'N, 99°10'E -> 180°+78°08'E)

TF_lon_range = lon > 134 & lon < 276;
TF_lat_range = lat > -67 & lat < 67;
TF_time_range = datetime(1900,1,1) < time_month & time_month < datetime(2020,12,30);

%%% eof

n_eof = 3; % only calculates the first n modes of variability
[eof_maps,pc,expvar] = eof(sst_var(TF_lon_range,TF_lat_range,TF_time_range),n_eof);
% Optional scaling of Principal Components and EOF maps
for k = 1:size(pc,1)
   % Find the the maximum value in the time series of each principal component:
   maxval = max(abs(pc(k,:)));
   % Divide the time series by its maximum value:
   pc(k,:) = pc(k,:)/maxval;
   % Multiply the corresponding EOF map:
   eof_maps(:,:,k) = eof_maps(:,:,k)*maxval;
end

%%% Create figure.
for num_EOF = 1:3
    EOF_fig(num_EOF,"Pacific",lon(TF_lon_range),lat(TF_lat_range),time_month(TF_time_range),eof_maps,pc,expvar,1)
end

%% 3. the Atlantic Ocean

%%% prepare

% convert longitute from 0~360 deg E to -180~180 deg E
n_lon_W = sum(lon >= 180);
lon_0 = circshift(lon,n_lon_W);
lon_0(lon_0 >= 180) = lon_0(lon_0 >= 180) - 360;
sst_var_0 = circshift(sst_var,n_lon_W,1);
%
TF_lon_range = (lon_0 > -65 & lon_0 < 41);
TF_lat_range = lat > -101 & lat < 67;
TF_time_range = datetime(1900,1,1) < time_month & time_month < datetime(2020,12,30);

%%% eof

n_eof = 3; % only calculates the first n modes of variability
[eof_maps,pc,expvar] = eof(sst_var_0(TF_lon_range,TF_lat_range,TF_time_range),n_eof);
% Optional scaling of Principal Components and EOF maps
for k = 1:size(pc,1)
   % Find the the maximum value in the time series of each principal component:
   maxval = max(abs(pc(k,:)));
   % Divide the time series by its maximum value:
   pc(k,:) = pc(k,:)/maxval;
   % Multiply the corresponding EOF map:
   eof_maps(:,:,k) = eof_maps(:,:,k)*maxval;
end

%%% Create figure.
for num_EOF = 1:3
    EOF_fig(num_EOF,"Atlantic",lon_0(TF_lon_range),lat(TF_lat_range),time_month(TF_time_range),eof_maps,pc,expvar,1)
end

%% 4. the North Atlantic Ocean

%%% prepare

% convert longitute from 0~360 deg E to -180~180 deg E
n_lon_W = sum(lon >= 180);
lon_0 = circshift(lon,n_lon_W);
lon_0(lon_0 >= 180) = lon_0(lon_0 >= 180) - 360;
sst_var_0 = circshift(sst_var,n_lon_W,1);
%
TF_lon_range = (lon_0 > -81 & lon_0 < 1);
TF_lat_range = lat > -1 & lat < 67;
TF_time_range = datetime(1900,1,1) < time_month & time_month < datetime(2020,12,30);

%%% eof

n_eof = 3; % only calculates the first n modes of variability
[eof_maps,pc,expvar] = eof(sst_var_0(TF_lon_range,TF_lat_range,TF_time_range),n_eof);
% Optional scaling of Principal Components and EOF maps
for k = 1:size(pc,1)
   % Find the the maximum value in the time series of each principal component:
   maxval = max(abs(pc(k,:)));
   % Divide the time series by its maximum value:
   pc(k,:) = pc(k,:)/maxval;
   % Multiply the corresponding EOF map:
   eof_maps(:,:,k) = eof_maps(:,:,k)*maxval;
end

%%% Create figure.
for num_EOF = 1:3
    EOF_fig(num_EOF,"North Atlantic",lon_0(TF_lon_range),lat(TF_lat_range),time_month(TF_time_range),eof_maps,pc,expvar,1)
end

%% 5. the North Pacific Ocean (20°N ~ 65°44'N, 99°10'E -> 180°+78°08'E)

TF_lon_range = lon > 134 & lon < 261;
TF_lat_range = lat > 20 & lat < 67;
TF_time_range = datetime(1900,1,1) < time_month & time_month < datetime(2020,12,30);

%%% eof

n_eof = 3; % only calculates the first n modes of variability
[eof_maps,pc,expvar] = eof(sst_var(TF_lon_range,TF_lat_range,TF_time_range),n_eof);
% Optional scaling of Principal Components and EOF maps
for k = 1:size(pc,1)
   % Find the the maximum value in the time series of each principal component:
   maxval = max(abs(pc(k,:)));
   % Divide the time series by its maximum value:
   pc(k,:) = pc(k,:)/maxval;
   % Multiply the corresponding EOF map:
   eof_maps(:,:,k) = eof_maps(:,:,k)*maxval;
end

%%% Create figure.
for num_EOF = 1:3
    EOF_fig(num_EOF,"North Pacific",lon(TF_lon_range),lat(TF_lat_range),time_month(TF_time_range),eof_maps,pc,expvar,1)
end

%% local functions

%% Initialize environment

function [] = init_env()
% Initialize environment
%
    % set up project directory
    if ~isfolder("../doc/fig/hw2")
        mkdir ../doc/fig/hw2
    end
    % configure searching path
    mfile_fullpath = mfilename('fullpath'); % the full path and name of the file in which the call occurs, not including the filename extension.
    mfile_fullpath_without_fname = mfile_fullpath(1:end-strlength(mfilename));
    addpath(genpath(mfile_fullpath_without_fname + "../data"), ...
            genpath(mfile_fullpath_without_fname + "../inc")); % adds the specified folders to the top of the search path for the current MATLAB® session.

    return;
end

%% Create EOF figure.

function [] = EOF_fig(num_EOF,title_str,lon,lat,time_month,eof_maps,pc,expvar,TF_export)
    arguments
        num_EOF
        title_str
        lon
        lat
        time_month
        eof_maps
        pc
        expvar
        TF_export
    end

    figure('Name',sprintf("EOF-%d (%s)",num_EOF,title_str))
    t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");
    
    %%% EOF
    
    t_axes = nexttile(t_TCL,1);
    pcolor(t_axes,lon,lat,eof_maps(:,:,num_EOF).');
    shading(t_axes,"interp");
    hold on
    [C,h] = contour(t_axes,lon,lat,eof_maps(:,:,num_EOF).','LineWidth',0.2,'LineColor','black','ShowText','off');
    borders('countries','center',180,'color',rgb('gray'))
    hold off
    clabel(C,h,"Interpreter",'latex','FontSize',6)
    % BEGIN patch
    cl = caxis;
    if (cl(1) >= 0)
       cl(1) = -0.1;
       caxis(t_axes,cl)
    end
    % END patch
    colormap(t_axes,cmocean('balance','pivot',0))
    cb = colorbar(t_axes,"eastoutside","TickLabelInterpreter","latex");
    set(cb.Label,"String","Temperature ($^{\circ}\rm{C}$)","Interpreter","latex")
    set(t_axes,"TickLabelInterpreter","latex","TickDir","out",'YDir','normal','Box','off');
    xticks(t_axes,-180:45:360)
    xtickformat(t_axes,'%g$^{\\circ}\\rm{E}$')
    yticks(-90:30:90)
    ytickformat(t_axes,'%g$^{\\circ}\\rm{N}$')
    % xlabel(t_axes,"longitude (deg E)",'Interpreter','latex')
    % ylabel(t_axes,"latitude (deg N)",'Interpreter','latex')
    %
    [~,t_title_s] = title(t_TCL,sprintf("\\bf EOF-%d (%s)",num_EOF,title_str),"Guorui Wei 120034910021",'Interpreter','latex');
    set(t_title_s,'FontSize',8);
    
    %%% pc

    t_axes = nexttile(t_TCL,2);
    plot(t_axes,time_month,pc(num_EOF,:),'-',"DisplayName",'pc');
    set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out','XLimitMethod','tight');
    % legend(t_axes,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
    xticks(t_axes,datetime(1900,1,15) + calyears(0:20:120))
    xtickformat(t_axes,'yyyy')
    xlabel(t_axes,"$t$ (year)",FontSize=10,Interpreter="latex");
    ylabel(t_axes,"pc","FontSize",10,"Interpreter","latex");
    title(t_axes,sprintf("\\bf principal component (EOF-%d), expvar = %.1f \\%%",num_EOF,expvar(num_EOF)),"Interpreter","latex");

    %%% export
    
    if (TF_export)
        exportgraphics(t_TCL,sprintf("..\\doc\\fig\\hw2\\hw2_EOF-%d_%s.emf",num_EOF,title_str),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
        exportgraphics(t_TCL,sprintf("..\\doc\\fig\\hw2\\hw2_EOF-%d_%s.png",num_EOF,title_str),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb')
    end
     
    return;
end
