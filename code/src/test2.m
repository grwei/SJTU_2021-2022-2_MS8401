%% test2.m
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
sst = double(ncread(nc_path,'sst')); % [deg C] sst(lon,lat,time_month)
sst(sst == ncreadatt(nc_path,'/sst','missing_value')) = NaN; % Monthly Means of Sea Surface Temperature (SST)
lon = double(ncread(nc_path,'lon')); % [deg E]
lat = double(ncread(nc_path,'lat')); % [deg N]
time_month = (datetime(1854,1,15) + calmonths(0:size(sst,3)-1)).';

%%

Fs = 12;

sst_series = squeeze(sst(lon==180,lat==0,:));
DFT = fft(sst_series);
freq = (0:length(sst_series)-1)/Fs;
power = abs(DFT).^2;

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
