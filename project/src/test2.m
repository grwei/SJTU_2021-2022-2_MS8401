%% test2.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-07-04
% Last modified: 2022-07-
% Reference: [1] Narapusetty, Balachandrudu, Timothy DelSole, and Michael K. Tippett. "Optimal Estimation of the Climatological Mean", Journal of Climate 22, 18 (2009): 4845-4859, accessed Jul 5, 2022, https://doi.org/10.1175/2009JCLI2944.1
%            [2] Pezzulli, S., D. B. Stephenson, and A. Hannachi. "The Variability of Seasonality", Journal of Climate 18, 1 (2005): 71-88, accessed Jul 5, 2022, https://doi.org/10.1175/JCLI-3256.1
% Toolbox:   [T1] 
% Data:      [D1] [NOAA Extended Reconstructed Sea Surface Temperature (SST) V5](https://psl.noaa.gov/data/gridded/data.noaa.ersst.v5.html)

%% Initialize project

clc; clear; close all
init_env();

%% simple test

simple_test();

%% Exp. 1 (ideal series)

export_fig_EN = true;
create_fig_EN = true;
ideal_solve_EN = true;

METHOD_DISP_NAME = ["M-1A","M-1B","M-2","M-2A","M-2P","M-3L","M-3Q","Ssa","Ssm"];
INDICES_IDEAL_NAME = ["res2res_RMSE","res2res_CC","cm2cm_RMSE","cm2cm_CC","cm2raw_RMSE","cm2raw_CC","cm2raw_EV","cm2cm_cvRMSE","cm2raw_cvRMSE","season_mean","res_mean"];
INDICES_VAR_TYPES = repmat("double",size(METHOD_DISP_NAME));
bin_folder_name = "ideal";

t = (1:122*12).';                       % [months] 1900-2021
span = [15*12,15*12-1];                 % [months]
lwlr_annual = 1;
h = 2;
trend_deg = 1;

cat_ind_cell = cell(12,1);
for i = 1:12
    cat_ind_cell{i,1} = i:12:length(t);
end

for indices_name = INDICES_IDEAL_NAME
    results_ideal.(indices_name) = table('Size',[0,length(METHOD_DISP_NAME)+1], ...
        'VariableTypes',["string",INDICES_VAR_TYPES], ...
        'VariableNames',["case_name",METHOD_DISP_NAME]);
    results_ideal.(indices_name).Properties.Description = indices_name;
end

cnt_case = 0;
x_1A = cell(10,1);
x_1B = x_1A;
x_2 = x_1A;
x_2A = x_1A;
x_2P = x_1A;
x_3L = x_1A;
x_3Q = x_1A;
x_Ssa = x_1A;
x_Ssm = x_1A;

if ~isfolder("..\bin\test2\" + bin_folder_name)
    mkdir("..\bin\test2\" + bin_folder_name)
end
if ~isfolder("..\doc\fig\test2\" + bin_folder_name)
    mkdir("..\doc\fig\test2\" + bin_folder_name)
end

tic_ideal = tic;

%% Exp. 1.1

T_annual = 12;                          % [month] annual cycle
A_annual = 7.5;                         % [deg C] amplitude
T_inter_an = 4.3 * 12;                  % [month] inter-annual cycle
A_inter_an = 2;                         % [deg C]
std_noise = 0.8;                        % [deg C]
x_trend{1,1} = 10 + 2/100/12 * t;       % [deg C]
x_trend{2,1} = 10 + 2/(1200)^2 * t.^2;  % [deg C]

x_annual = A_annual * sin(2*pi/T_annual*(t-4));
x_inter_an = A_inter_an * sin(2*pi/T_inter_an*(t-2.5));

rng(0);
x_noise = std_noise * randn(size(t));

%% Exp. 1.1.1 (noise)

case_name = "ideal_1";
x = cell(2,1);
for i = 1:length(x_trend)
    cnt_case = cnt_case + 1;
    mat_file_path = sprintf("%s\\%s_%d",bin_folder_name,case_name,i);
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_noise;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
    [x_1A{cnt_case},x_1B{cnt_case},x_2{cnt_case},x_2A{cnt_case},x_2P{cnt_case},x_3L{cnt_case},x_3Q{cnt_case},x_Ssa{cnt_case},x_Ssm{cnt_case}] = test2_ideal(t,x{i},span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell, ...
        @M1_A,@M1_B,@M2,@M2_A,@M2_P,@M3, ...
        @M1_A_cv,@M1_B_cv,@M2_cv,@M2_A_cv,@M2_P_cv,@M3_cv, ...
        mat_file_path,ideal_solve_EN);
    test2_ideal_plot(sprintf("%s_%d",case_name,i),mat_file_path, ...
        sprintf("\\bf Ideal Case %d",cnt_case),create_fig_EN,export_fig_EN);
    for indices_name = INDICES_IDEAL_NAME
        results_ideal.(indices_name)(end+1,:) = {sprintf("%s_%d",case_name,i),x_1A{cnt_case}.(indices_name),x_1B{cnt_case}.(indices_name),x_2{cnt_case}.(indices_name),x_2A{cnt_case}.(indices_name),x_2P{cnt_case}.(indices_name),x_3L{cnt_case}.(indices_name),x_3Q{cnt_case}.(indices_name),x_Ssa{cnt_case}.(indices_name),x_Ssm{cnt_case}.(indices_name)};
    end
    fprintf("\\bf Ideal Case %d: total time = %.1f secs.\n",cnt_case,toc(tic_ideal));
end

%% Exp. 1.1.2 (inter-annual)

case_name = "ideal_2";
x = cell(2,1);
for i = 1:length(x_trend)
    cnt_case = cnt_case + 1;
    mat_file_path = sprintf("%s\\%s_%d",bin_folder_name,case_name,i);
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_inter_an;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
    [x_1A{cnt_case},x_1B{cnt_case},x_2{cnt_case},x_2A{cnt_case},x_2P{cnt_case},x_3L{cnt_case},x_3Q{cnt_case},x_Ssa{cnt_case},x_Ssm{cnt_case}] = test2_ideal(t,x{i},span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell, ...
        @M1_A,@M1_B,@M2,@M2_A,@M2_P,@M3, ...
        @M1_A_cv,@M1_B_cv,@M2_cv,@M2_A_cv,@M2_P_cv,@M3_cv, ...
        mat_file_path,ideal_solve_EN);
    test2_ideal_plot(sprintf("%s_%d",case_name,i),mat_file_path, ...
        sprintf("\\bf Ideal Case %d",cnt_case),create_fig_EN,export_fig_EN);
    for indices_name = INDICES_IDEAL_NAME
        results_ideal.(indices_name)(end+1,:) = {sprintf("%s_%d",case_name,i),x_1A{cnt_case}.(indices_name),x_1B{cnt_case}.(indices_name),x_2{cnt_case}.(indices_name),x_2A{cnt_case}.(indices_name),x_2P{cnt_case}.(indices_name),x_3L{cnt_case}.(indices_name),x_3Q{cnt_case}.(indices_name),x_Ssa{cnt_case}.(indices_name),x_Ssm{cnt_case}.(indices_name)};
    end
    fprintf("\\bf Ideal Case %d: total time = %.1f secs.\n",cnt_case,toc(tic_ideal));
end

%% Exp. 1.1.3 (inter-annual + noise)

case_name = "ideal_3";
x = cell(2,1);
for i = 1:length(x_trend)
    cnt_case = cnt_case + 1;
    mat_file_path = sprintf("%s\\%s_%d",bin_folder_name,case_name,i);
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_inter_an + x_noise;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
    [x_1A{cnt_case},x_1B{cnt_case},x_2{cnt_case},x_2A{cnt_case},x_2P{cnt_case},x_3L{cnt_case},x_3Q{cnt_case},x_Ssa{cnt_case},x_Ssm{cnt_case}] = test2_ideal(t,x{i},span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell, ...
        @M1_A,@M1_B,@M2,@M2_A,@M2_P,@M3, ...
        @M1_A_cv,@M1_B_cv,@M2_cv,@M2_A_cv,@M2_P_cv,@M3_cv, ...
        mat_file_path,ideal_solve_EN);
    test2_ideal_plot(sprintf("%s_%d",case_name,i),mat_file_path, ...
        sprintf("\\bf Ideal Case %d",cnt_case),create_fig_EN,export_fig_EN);
    for indices_name = INDICES_IDEAL_NAME
        results_ideal.(indices_name)(end+1,:) = {sprintf("%s_%d",case_name,i),x_1A{cnt_case}.(indices_name),x_1B{cnt_case}.(indices_name),x_2{cnt_case}.(indices_name),x_2A{cnt_case}.(indices_name),x_2P{cnt_case}.(indices_name),x_3L{cnt_case}.(indices_name),x_3Q{cnt_case}.(indices_name),x_Ssa{cnt_case}.(indices_name),x_Ssm{cnt_case}.(indices_name)};
    end
    fprintf("\\bf Ideal Case %d: total time = %.1f secs.\n",cnt_case,toc(tic_ideal));
end

%% Exp. 1.2 (sensitivity to increment of trend)

case_name = "ideal_4";
T_annual = 12;                          % [month] annual cycle
A_annual = 7.5;                         % [deg C] amplitude
T_inter_an = 4.3 * 12;                  % [month] inter-annual cycle
A_inter_an = 2;                         % [deg C]
std_noise = 0.8;                        % [deg C]
x_trend{1,1} = 10 + 8*2/100/12 * t;       % [deg C]
x_trend{2,1} = 10 + 8*2/(1200)^2 * t.^2;  % [deg C]

x_annual = A_annual * sin(2*pi/T_annual*(t-4));
x_inter_an = A_inter_an * sin(2*pi/T_inter_an*(t-2.5));

rng(0);
x_noise = std_noise * randn(size(t));

%%%

x = cell(2,1);
for i = 1:length(x_trend)
    cnt_case = cnt_case + 1;
    mat_file_path = sprintf("%s\\%s_%d",bin_folder_name,case_name,i);
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_inter_an + x_noise;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
    [x_1A{cnt_case},x_1B{cnt_case},x_2{cnt_case},x_2A{cnt_case},x_2P{cnt_case},x_3L{cnt_case},x_3Q{cnt_case},x_Ssa{cnt_case},x_Ssm{cnt_case}] = test2_ideal(t,x{i},span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell, ...
        @M1_A,@M1_B,@M2,@M2_A,@M2_P,@M3, ...
        @M1_A_cv,@M1_B_cv,@M2_cv,@M2_A_cv,@M2_P_cv,@M3_cv, ...
        mat_file_path,ideal_solve_EN);
    test2_ideal_plot(sprintf("%s_%d",case_name,i),mat_file_path, ...
        sprintf("\\bf Ideal Case %d",cnt_case),create_fig_EN,export_fig_EN);
    for indices_name = INDICES_IDEAL_NAME
        results_ideal.(indices_name)(end+1,:) = {sprintf("%s_%d",case_name,i),x_1A{cnt_case}.(indices_name),x_1B{cnt_case}.(indices_name),x_2{cnt_case}.(indices_name),x_2A{cnt_case}.(indices_name),x_2P{cnt_case}.(indices_name),x_3L{cnt_case}.(indices_name),x_3Q{cnt_case}.(indices_name),x_Ssa{cnt_case}.(indices_name),x_Ssm{cnt_case}.(indices_name)};
    end
    fprintf("\\bf Ideal Case %d: total time = %.1f secs.\n",cnt_case,toc(tic_ideal));
end

%% Exp. 1.3 (sensitivity to Explained Variance (EV) of annual cycle)

case_name = "ideal_5";
T_annual = 12;                          % [month] annual cycle
A_annual = 0.5;                         % [deg C] amplitude
T_inter_an = 4.3 * 12;                  % [month] inter-annual cycle
A_inter_an = 2;                         % [deg C]
std_noise = 0.8;                        % [deg C]
x_trend{1,1} = 10 + 2/100/12 * t;       % [deg C]
x_trend{2,1} = 10 + 2/(1200)^2 * t.^2;  % [deg C]

x_annual = A_annual * sin(2*pi/T_annual*(t-4));
x_inter_an = A_inter_an * sin(2*pi/T_inter_an*(t-2.5));

rng(0);
x_noise = std_noise * randn(size(t));

%%%

x = cell(2,1);
for i = 1:length(x_trend)
    cnt_case = cnt_case + 1;
    mat_file_path = sprintf("%s\\%s_%d",bin_folder_name,case_name,i);
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_inter_an + x_noise;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
    [x_1A{cnt_case},x_1B{cnt_case},x_2{cnt_case},x_2A{cnt_case},x_2P{cnt_case},x_3L{cnt_case},x_3Q{cnt_case},x_Ssa{cnt_case},x_Ssm{cnt_case}] = test2_ideal(t,x{i},span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell, ...
        @M1_A,@M1_B,@M2,@M2_A,@M2_P,@M3, ...
        @M1_A_cv,@M1_B_cv,@M2_cv,@M2_A_cv,@M2_P_cv,@M3_cv, ...
        mat_file_path,ideal_solve_EN);
    test2_ideal_plot(sprintf("%s_%d",case_name,i),mat_file_path, ...
        sprintf("\\bf Ideal Case %d",cnt_case),create_fig_EN,export_fig_EN);
    for indices_name = INDICES_IDEAL_NAME
        results_ideal.(indices_name)(end+1,:) = {sprintf("%s_%d",case_name,i),x_1A{cnt_case}.(indices_name),x_1B{cnt_case}.(indices_name),x_2{cnt_case}.(indices_name),x_2A{cnt_case}.(indices_name),x_2P{cnt_case}.(indices_name),x_3L{cnt_case}.(indices_name),x_3Q{cnt_case}.(indices_name),x_Ssa{cnt_case}.(indices_name),x_Ssm{cnt_case}.(indices_name)};
    end
    fprintf("\\bf Ideal Case %d: total time = %.1f secs.\n",cnt_case,toc(tic_ideal));
end

%%

if isfile("../bin/test2/test2.mat")
    save("../bin/test2/test2.mat","results_ideal",'-append');
else
    save("../bin/test2/test2.mat","results_ideal");
end

%%

test2_plot1(create_fig_EN,export_fig_EN);

%% Exp. 2 (real time-indices)

clc; clear;

export_fig_EN = false;
create_fig_EN = false;
real_solve_EN = true;

METHOD_DISP_NAME = ["M-1A","M-1B","M-2","M-2A","M-2P","M-3L","M-3Q","Ssa","Ssm"];
INDICES_REAL_NAME = ["cm2raw_RMSE","cm2raw_CC","cm2raw_cvRMSE","cm2raw_EV","season_mean","res_mean"];
INDICES_VAR_TYPES = repmat("double",size(METHOD_DISP_NAME));

cnt_case = 0;

%% Exp. 2.1. (NOAA Extended Reconstructed SST V5) (1902-2021)

case_name = "ersst_v5";
bin_folder_name = "ersst_v5";
cnt_case = cnt_case + 1;
span = [15*12,15*12-1];                 % [months]
trend_deg = 1;
lwlr_annual = 1;
T_annual = 12;
h = 3;

if ~isfolder("..\bin\test2\" + bin_folder_name)
    mkdir("..\bin\test2\" + bin_folder_name)
end
if ~isfolder("..\doc\fig\test2\" + bin_folder_name)
    mkdir("..\doc\fig\test2\" + bin_folder_name)
end
tic_ersst = tic;

%%% Read data

nc_path = "..\data\sst.mnmean.nc";
nc_info = ncinfo(nc_path);
sst = double(ncread(nc_path,'sst')); % [deg C] sst(lon,lat,time_month)
sst(sst == ncreadatt(nc_path,'/sst','missing_value')) = NaN; % Monthly Means of Sea Surface Temperature (SST)
lon = double(ncread(nc_path,'lon')); % [deg E]
lat = double(ncread(nc_path,'lat')); % [deg N]
time_month = (datetime(1854,1,15) + calmonths(0:size(sst,3)-1)).';

%%% Parameters

start_time = datetime(1902,1,1);
end_time = datetime(2021,12,30);

TF_lon_range = lon > -Inf & lon < +Inf;
TF_lat_range = lat > -Inf & lat < +Inf;
% TF_lon_range = lon > 319 & lon < 321;
% TF_lat_range = lat > +47 & lat < +49;
TF_time_range = start_time < time_month & time_month < end_time; % 1902.01-2021.12

%%% Simulation

lon = lon(TF_lon_range);
lat = lat(TF_lat_range);
time_month = time_month(TF_time_range);
sst = sst(TF_lon_range,TF_lat_range,TF_time_range);

t = (1:length(time_month)).';  % [month]. 1 = Jan 1902; 2 = Feb 1902; ...
cat_ind_cell = cell(12,1);
for i = 1:12
    cat_ind_cell{i,1} = i:12:length(t);
end

x_1A = cell(size(sst,1),size(sst,2));
x_1B = x_1A;
x_2 = x_1A;
x_2A = x_1A;
x_2P = x_1A;
x_3L = x_1A;
x_3Q = x_1A;
x_Ssa = x_1A;
x_Ssm = x_1A;

for lon_ind = 1:size(sst,1)
    for lat_ind = 1:size(sst,2)
        x.raw = squeeze(sst(lon_ind,lat_ind,:));
        [x_1A{lon_ind,lat_ind},x_1B{lon_ind,lat_ind},x_2{lon_ind,lat_ind},x_2A{lon_ind,lat_ind},x_2P{lon_ind,lat_ind},x_3L{lon_ind,lat_ind},x_3Q{lon_ind,lat_ind},x_Ssa{lon_ind,lat_ind},x_Ssm{lon_ind,lat_ind}] = test2_real(t,x,span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell, ...
                @M1_A,@M1_B,@M2,@M2_A,@M2_P,@M3, ...
                @M1_A_cv,@M1_B_cv,@M2_cv,@M2_A_cv,@M2_P_cv,@M3_cv, ...
                sprintf("%s\\%s_%gN_%gE",bin_folder_name,case_name,lat(lat_ind),lon(lon_ind)),real_solve_EN);
        fprintf("%gN %gE, cm2raw_cvRMSE (EV): (total time = %.1f secs)\n" + ...
            "M-1A:\t %.3f (%.3f), \t M-1B:\t %.3f (%.3f),\n" + ...
            "M-2:\t %.3f (%.3f), \t M-2A:\t %.3f (%.3f), \n" + ...
            "M-2P:\t %.3f (%.3f),\n" + ...
            "M-3L:\t %.3f (%.3f), \t M-3Q:\t %.3f (%.3f),\n" + ...
            "Ssa:\t %.3f (%.3f), \t Ssm:\t %.3f (%.3f).\n", ...
            lat(lat_ind),lon(lon_ind),toc(tic_ersst), ...
            x_1A{lon_ind,lat_ind}.cm2raw_cvRMSE,x_1A{lon_ind,lat_ind}.cm2raw_EV,x_1B{lon_ind,lat_ind}.cm2raw_cvRMSE,x_1B{lon_ind,lat_ind}.cm2raw_EV, ...
            x_2{lon_ind,lat_ind}.cm2raw_cvRMSE,x_2{lon_ind,lat_ind}.cm2raw_EV,x_2A{lon_ind,lat_ind}.cm2raw_cvRMSE,x_2A{lon_ind,lat_ind}.cm2raw_EV, ...
            x_2P{lon_ind,lat_ind}.cm2raw_cvRMSE,x_2P{lon_ind,lat_ind}.cm2raw_EV, ...
            x_3L{lon_ind,lat_ind}.cm2raw_cvRMSE,x_3L{lon_ind,lat_ind}.cm2raw_EV,x_3Q{lon_ind,lat_ind}.cm2raw_cvRMSE,x_3Q{lon_ind,lat_ind}.cm2raw_EV, ...
            x_Ssa{lon_ind,lat_ind}.cm2raw_cvRMSE,x_Ssa{lon_ind,lat_ind}.cm2raw_EV,x_Ssm{lon_ind,lat_ind}.cm2raw_cvRMSE,x_Ssm{lon_ind,lat_ind}.cm2raw_EV);
    end
end

%%

%% local functions

%% Initialize environment

function [] = init_env()
% Initialize environment
%
    % set up project directory
    if ~isfolder("../doc/fig/test2/")
        mkdir ../doc/fig/test2/
    end
    if ~isfolder("../bin/test2/")
        mkdir ../bin/test2/
    end
    % configure searching path
    mfile_fullpath = mfilename('fullpath'); % the full path and name of the file in which the call occurs, not including the filename extension.
    mfile_fullpath_without_fname = mfile_fullpath(1:end-strlength(mfilename));
    addpath(genpath(mfile_fullpath_without_fname + "../data"), ...
            genpath(mfile_fullpath_without_fname + "../inc")); % adds the specified folders to the top of the search path for the current MATLAB® session.

    return;
end

%%

function [y_lwlr] = lwlr_period(x,y,span,trend_deg,lwlr_annual,x_test,weight_fun_handle)
%lwlr - Locally Weighted Linear Regression (LWLR) (polynomial)
%
% Syntax: [y_lwlr] = lwlr(x,y,span,trend_deg,lwlr_annual,x_test,weight_fun)
%
% Locally Weighted Linear Regression (LWLR) (polynomial)

    arguments
        x           % predictor
        y           % response
        span        % [6,6]
        trend_deg = 1;
        lwlr_annual = 1;
        x_test = x;
        weight_fun_handle = []; % column vector
    end

    if ~iscolumn(x)
        x = x.';
    end
    if ~iscolumn(y)
        y = y.';
    end
    if ~iscolumn(x_test)
        x_test = x_test.';
    end
    if isscalar(span)
        span = [span span];
    end
    if isempty(lwlr_annual)
        lwlr_annual = 1;
    end

    % Remove missing values, if any
    wasnan = (isnan(y) | isnan(x));
    if any(wasnan)
       y(wasnan) = [];
       x(wasnan) = [];
    end

    y_lwlr = nan(length(x_test),1);
    if length(y) < 2
        return;
    end

    if span(1) == +Inf && span(2) == +Inf
        X = x.^(0:trend_deg);
        if isa(weight_fun_handle,"function_handle")
            w = weight_fun_handle(x); % column vector
        else
            w = 1;
        end
        coeff = ((X.'*(w.*X))\(X.'*(w.*y)));
        y_lwlr = (x_test.^(0:trend_deg))*coeff;
        
        return;
    end

    for i = 1:length(x_test)
        % determine data range
        ind_left = find(x >= x_test(i) - span(1),1,'first');
        ind_right = find(x <= x_test(i) + span(2),1,'last');
        if (ind_left == 1)
%             ind_right = ind_right - mod(ind_right - ind_left + 1,lwlr_annual);
            ind_right = min([length(x),ind_left + span(2) + span(1)]);
        elseif (ind_right == length(x))
%             ind_left = ind_left + mod(ind_right - ind_left + 1,lwlr_annual);
            ind_left = max([1,ind_right - span(2) - span(1)]);
        end

        X = x(ind_left:ind_right,1).^(0:trend_deg);
        Y = y(ind_left:ind_right,1);
        if isa(weight_fun_handle,"function_handle")
            w = weight_fun_handle(x(ind_left:ind_right)); % column vector
        else
            w = 1;
        end
        coeff = ((X.'*(w.*X))\(X.'*(w.*Y)));
        y_lwlr(i) = (x_test(i).^(0:trend_deg))*coeff;
    end

    return;
end

%%

function [mu,season_series,season_main] = season_simple(x,cat_ind_cell)
%season_simple - annual cycle determined by simple averaging
%
% Syntax: [mu,season_series,season_main] = season_simple(x,cat_ind_cell)
%
% Simple averaging, is to average the state with respect to fixed phase of
% the annual and diurnal cycle. For instance, the climatological mean for 1
% January would be estimated as the average of all 1 January states in a
% historical record.

    arguments
        x
        cat_ind_cell
    end

    if ~iscolumn(x)
        x = x.';
    end
    
    season_main = cellfun(@(ind) mean(x(ind),"omitnan"),cat_ind_cell);
    mu = mean(season_main,"omitnan"); % note: this is NOT the mean of original series!
    season_main = season_main - mean(x,"omitnan");
    
    season_series = nan(size(x));
    for i = 1:length(cat_ind_cell)
        season_series(cat_ind_cell{i}) = season_main(i);
    end

    return;
end

%% (Narapusetty, 2009)

function [coeff,season_series] = season_spectral(t,x,T_annual,h,t_pred)
%season_spectral - annual cycle determined by spectral method
%
% Syntax: [coeff,season_series] = season_spectral(t,x,T_annual,h)
%
% The spectral method, is to fit the time series to a sum of sines and
% cosines that are periodic on specified time scales.

    arguments
        t
        x
        T_annual
        h
        t_pred = t;
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    if ~iscolumn(t_pred)
        t_pred = t_pred.';
    end

    % Remove missing values, if any
    wasnan = (isnan(x) | isnan(t));
    if any(wasnan)
       x(wasnan) = [];
       t(wasnan) = [];
    end

    if (length(x) < 2)
        coeff = nan(2*h+1,1);
        season_series = nan(length(t_pred),1);

        return;
    end

    omega_vec = 2*pi/T_annual*(1:h);
    T = [ones(length(t),1),cos(t*omega_vec),sin(t*omega_vec)]; % data matrix
    coeff = (T.'*T)\(T.'*x);
    
    T_pred = [ones(length(t_pred),1),cos(t_pred*omega_vec),sin(t_pred*omega_vec)]; % data matrix
    season_series = T_pred*coeff - coeff(1);

    return;
end

%% Determine linear trend and annual cycle simultaneously by LSM.

function [coeff,season_series,trend_series] = season_spectral_trend(t,x,T_annual,h,trend_deg,t_pred)
%season_spectral - determine polynomial trend and annual cycle simultaneously by LSM
%
% Syntax: [coeff,season_series,trend_series] = season_spectral_trend(t,x,T_annual,h,trend_deg,t_pred)
%
% The spectral method, is to fit the time series to a sum of sines and
% cosines that are periodic on specified time scales.

    arguments
        t
        x
        T_annual
        h
        trend_deg = 1;
        t_pred = t;
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    if ~iscolumn(t_pred)
        t_pred = t_pred.';
    end

    % Remove missing values, if any
    wasnan = (isnan(x) | isnan(t));
    if any(wasnan)
       x(wasnan) = [];
       t(wasnan) = [];
    end

    if length(x) < 2
        coeff = nan(trend_deg + 2*h + 1,1);
        trend_series = nan(length(t_pred),1);
        season_series = trend_series;
        return;
    end

    omega_vec = 2*pi/T_annual*(1:h);
    T = [t.^(0:trend_deg),cos(t*omega_vec),sin(t*omega_vec)]; % data matrix
    coeff = (T.'*T)\(T.'*x);
    
    trend_series = (t_pred.^(0:trend_deg))*coeff(1:trend_deg+1);
    season_series = [cos(t_pred*omega_vec),sin(t_pred*omega_vec)]*coeff(trend_deg+2:end);

    return;
end

%% Method-1A: trend (lwlr); annual cycle (simple average)

function [x_trend,x_season,x_res] = M1_A(t,x,span,trend_deg,lwlr_annual,cat_ind_cell)
%M1_A - classical decomposition method-1A
%
% Syntax: [x_trend,x_annual,x_res] = M1_A(t,x,span,trend_deg,lwlr_annual,cat_ind_cell)
%
% Estimate trend using local-weighted linear regression (LWLR), and then
% estimate annual cycle by simple averaging.
    
    arguments
        t
        x
        span
        trend_deg = 1;
        lwlr_annual = 1;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    if isscalar(span)
        span = [span, span];
    end
    
    if nargin < 4
        cat_ind_cell = cell(12,1);
        for i = 1:12
            cat_ind_cell{i,1} = i:12:length(t);
        end
    end
    
    %%% 1. Estimate trend using local-weighted linear regression (LWLR)
    
    x_trend = lwlr_period(t,x,span,trend_deg,lwlr_annual);

    %%% 2. Estimate annual cycle by simple averaging.

    [~,x_season,~] = season_simple(x - x_trend,cat_ind_cell);

    %%% 3. irregular estimates

    x_res = x - x_trend - x_season - mean(x - x_trend,"omitnan");

    return;
end

%% Method-1B: annual cycle (simple average); trend (lwlr)

function [x_trend,x_season,x_res] = M1_B(t,x,span,trend_deg,lwlr_annual,cat_ind_cell)
%M1_A - classical decomposition method-1B
%
% Syntax: [x_trend,x_annual,x_res] = M1_B(t,x,span,trend_deg,lwlr_annual,cat_ind_cell)
%
% Estimate annual cycle by simple averaging, and then Estimate trend using
% local-weighted linear regression (LWLR)

    arguments
        t
        x
        span
        trend_deg = 1;
        lwlr_annual = 1;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    if isscalar(span)
        span = [span, span];
    end

    if nargin < 4
        cat_ind_cell = cell(12,1);
        for i = 1:12
            cat_ind_cell{i,1} = i:12:length(t);
        end
    end

    %%% 1. Estimate annual cycle by simple averaging.

    [~,x_season,~] = season_simple(x,cat_ind_cell);

    %%% 2. Estimate trend using local-weighted linear regression (LWLR)
    
    x_trend = lwlr_period(t,x - x_season,span,trend_deg,lwlr_annual);

    %%% 3. irregular estimates

    x_res = x - x_trend - x_season;

    return;
end

%% Method-2: (Pezzulli, S., 2005)

function [x_trend,x_season,x_res] = M2(t,x,span,trend_deg,lwlr_annual,cat_ind_cell)
%M2 - classical decomposition method-2
%
% Syntax: [x_trend,x_annual,x_res] = M2(t,x,span,trend_deg,lwlr_annual,cat_ind_cell)
%
% The algorithm consists of an alternate trend estimation on seasonally
% adjusted series and seasonal estimation on the trend-adjusted one.
% Reference: Pezzulli, S., D. B. Stephenson, and A. Hannachi. "The Variability of Seasonality", Journal of Climate 18, 1 (2005): 71-88, accessed Jul 5, 2022, https://doi.org/10.1175/JCLI-3256.1
    
    arguments
        t
        x
        span
        trend_deg = 1;
        lwlr_annual = 1;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    if isscalar(span)
        span = [span, span];
    end

    if nargin < 4
        cat_ind_cell = cell(12,1);
        for i = 1:12
            cat_ind_cell{i,1} = i:12:length(t);
        end
    end

    %%% 1. Initial trend and seasonal estimates
    
    x_trend_init = lwlr_period(t,x,span,trend_deg,lwlr_annual);
    [~,x_season_init,~] = season_simple(x - x_trend_init,cat_ind_cell);
    
    %%% 2. Revised trend and seasonal estimates

    x_trend_rev = lwlr_period(t,x - x_season_init,span,trend_deg,lwlr_annual);
    [~,x_season,~] = season_simple(x - x_trend_rev,cat_ind_cell);

    %%% 3. Final trend and irregular estimates

    x_trend = lwlr_period(t,x - x_season,span,trend_deg,lwlr_annual);
    x_res = x - x_trend - x_season;

    return;
end

%% Method-2A: adapted from (Pezzulli, S., 2005)

function [x_trend,x_season,x_res] = M2_A(t,x,span,trend_deg,lwlr_annual,cat_ind_cell)
%M2 - classical decomposition method-2A
%
% Syntax: [x_trend,x_annual,x_res] = M2_A(t,x,span,trend_deg,lwlr_annual,cat_ind_cell)
%
% The algorithm consists of an alternate trend estimation on seasonally
% adjusted series and seasonal estimation on the trend-adjusted one.
% Reference: Pezzulli, S., D. B. Stephenson, and A. Hannachi. "The Variability of Seasonality", Journal of Climate 18, 1 (2005): 71-88, accessed Jul 5, 2022, https://doi.org/10.1175/JCLI-3256.1
    
    arguments
        t
        x
        span
        trend_deg = 1;
        lwlr_annual = 1;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    if isscalar(span)
        span = [span, span];
    end

    if nargin < 4
        cat_ind_cell = cell(12,1);
        for i = 1:12
            cat_ind_cell{i,1} = i:12:length(t);
        end
    end

    %%% 1. Initial seasonal and trend estimates
    
    [~,x_season_init,~] = season_simple(x,cat_ind_cell);
    x_trend_init = lwlr_period(t,x - x_season_init,span,trend_deg,lwlr_annual);
    
    %%% 2. Revised seasonal and trend estimates

    [~,x_season_rev,~] = season_simple(x - x_trend_init,cat_ind_cell);
    x_trend = lwlr_period(t,x - x_season_rev,span,trend_deg,lwlr_annual);

    %%% 3. Final seasonal and irregular estimates

    [~,x_season,~] = season_simple(x - x_trend,cat_ind_cell);
    x_res = x - x_trend - x_season - mean(x - x_trend,'omitnan');

    return;
end

%% Method-2P
% like method-2 (Pezzulli, S., 2005), but use spectral method (Narapusetty,
% 2009) to determine seasonal component.

function [x_trend,x_season,x_res] = M2_P(t,x,span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell)
%M2P - classical decomposition method-2P
%
% Syntax: [x_trend,x_annual,x_res] = M2_P(t,x,span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell)
%
% The algorithm consists of an alternate trend estimation on seasonally
% adjusted series and seasonal estimation on the trend-adjusted one.
% Reference: [1] Pezzulli, S., D. B. Stephenson, and A. Hannachi. "The Variability of Seasonality", Journal of Climate 18, 1 (2005): 71-88, accessed Jul 5, 2022, https://doi.org/10.1175/JCLI-3256.1
%            [2] Narapusetty, Balachandrudu, Timothy DelSole, and Michael K. Tippett. "Optimal Estimation of the Climatological Mean", Journal of Climate 22, 18 (2009): 4845-4859, accessed Jul 5, 2022, https://doi.org/10.1175/2009JCLI2944.1                          
    
    arguments
        t
        x
        span
        trend_deg = 1;
        lwlr_annual = 1;
        T_annual = 12;
        h = 2;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    if isscalar(span)
        span = [span, span];
    end

    if nargin < 4
        cat_ind_cell = cell(12,1);
        for i = 1:12
            cat_ind_cell{i,1} = i:12:length(t);
        end
    end

    %%% 1. Initial trend and seasonal estimates
    
    x_trend_init = lwlr_period(t,x,span,trend_deg,lwlr_annual);
    [~,x_season_init] = season_spectral(t,x-x_trend_init,T_annual,h);
    
    %%% 2. Revised trend and seasonal estimates

    x_trend_rev = lwlr_period(t,x - x_season_init,span,trend_deg,lwlr_annual);
    [~,x_season] = season_spectral(t,x-x_trend_rev,T_annual,h);

    %%% 3. Final trend and irregular estimates

    x_trend = lwlr_period(t,x - x_season,span,trend_deg,lwlr_annual);
    x_res = x - x_trend - x_season;

    return;
end

%% Method-3

function [x_trend,x_season,x_res] = M3(t,x,T_annual,h,trend_deg)
%M3 - classical decomposition method-3
%
% Syntax: [x_trend,x_annual,x_res] = M3(t,x,T_annual,h,trend_deg)
%
% Estimate polynomial trend and annual cycle simultaneously, by global linear
% regression.

    arguments
        t
        x
        T_annual
        h
        trend_deg = 1;
    end

    %%% 1. Estimate trend and annual cycle simultaneously, by global linear regression.

    [~,x_season,x_trend] = season_spectral_trend(t,x,T_annual,h,trend_deg);

    %%% 2. irregular estimates

    x_res = x - x_trend - x_season;

    return;
end

%% simple test

function [x_1A,x_1B,x_2,x_2A,x_3] = simple_test(t,x,span)
    arguments
        t = [1:6,7:1200].';
        x = 5*sin(2*pi/6*t) + 2 + t + 0.5*randn(size(t));
        span = 120;
    end
    
    cat_ind_cell = cell(12,1);
    for i = 1:12
        cat_ind_cell{i,1} = i:12:length(x);
    end
    
    [x_1A.trend,x_1A.season,x_1A.residue] = M1_A(t,x,span);
    [x_1B.trend,x_1B.season,x_1B.residue] = M1_B(t,x,span);
    [x_2.trend,x_2.season,x_2.residue] = M2(t,x,span);
    [x_2A.trend,x_2A.season,x_2A.residue] = M2_A(t,x,span);
    [x_3.trend,x_3.season,x_3.residue] = M3(t,x,12,2);
end

%% Cross-validation

function [x_fit] = M1_A_cv(t,x,t_istest,span,trend_deg,lwlr_annual,cat_ind_cell)
% M1_A_cv - cross validation for Method-1A
% description
    arguments
        t
        x
        t_istest
        span = [15*12,15*12-1];
        trend_deg = 1;
        lwlr_annual = 1;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    t_istest = logical(t_istest);
    if ~iscolumn(t_istest)
        t = t.';
    end
    if isscalar(span)
        span = [span, span];
    end
    
    if any(t_istest)
        x(t_istest) = NaN;
    end
    [x_trend,x_season,x_residue] = M1_A(t,x,span,trend_deg,lwlr_annual,cat_ind_cell);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

function [x_fit] = M1_B_cv(t,x,t_istest,span,trend_deg,lwlr_annual,cat_ind_cell)
% M1_B_cv - cross validation for Method-1B
% description
    arguments
        t
        x
        t_istest
        span = [15*12,15*12-1];
        trend_deg = 1;
        lwlr_annual = 1;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    t_istest = logical(t_istest);
    if ~iscolumn(t_istest)
        t = t.';
    end
    if isscalar(span)
        span = [span, span];
    end
    
    if any(t_istest)
        x(t_istest) = NaN;
    end
    [x_trend,x_season,x_residue] = M1_B(t,x,span,trend_deg,lwlr_annual,cat_ind_cell);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

function [x_fit] = M2_cv(t,x,t_istest,span,trend_deg,lwlr_annual,cat_ind_cell)
% M2_cv - cross validation for Method-2
% description
    arguments
        t
        x
        t_istest
        span = [15*12,15*12-1];
        trend_deg = 1;
        lwlr_annual = 1;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    t_istest = logical(t_istest);
    if ~iscolumn(t_istest)
        t = t.';
    end
    if isscalar(span)
        span = [span, span];
    end
    
    if any(t_istest)
        x(t_istest) = NaN;
    end
    [x_trend,x_season,x_residue] = M2(t,x,span,trend_deg,lwlr_annual,cat_ind_cell);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

function [x_fit] = M2_A_cv(t,x,t_istest,span,trend_deg,lwlr_annual,cat_ind_cell)
% M2_A_cv - cross validation for Method-2A
% description
    arguments
        t
        x
        t_istest
        span = [15*12,15*12-1];
        trend_deg = 1;
        lwlr_annual = 1;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    t_istest = logical(t_istest);
    if ~iscolumn(t_istest)
        t = t.';
    end
    if isscalar(span)
        span = [span, span];
    end
    
    if any(t_istest)
        x(t_istest) = NaN;
    end
    [x_trend,x_season,x_residue] = M2_A(t,x,span,trend_deg,lwlr_annual,cat_ind_cell);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

function [x_fit] = M2_P_cv(t,x,t_istest,span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell)
% M2_A_cv - cross validation for Method-2P
% description
    arguments
        t
        x
        t_istest
        span = [15*12,15*12-1];
        trend_deg = 1;
        lwlr_annual = 1;
        T_annual = 12;
        h = 2;
        cat_ind_cell = [];
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    t_istest = logical(t_istest);
    if ~iscolumn(t_istest)
        t = t.';
    end
    if isscalar(span)
        span = [span, span];
    end
    
    if any(t_istest)
        x(t_istest) = NaN;
    end
    [x_trend,x_season,x_residue] = M2_P(t,x,span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

function [x_fit] = M3_cv(t,x,t_istest,T_annual,h,trend_deg)
% M3_cv - cross validation for Method-3
% description
    arguments
        t
        x
        t_istest
        T_annual
        h
        trend_deg = 1;
    end

    if ~iscolumn(t)
        t = t.';
    end
    if ~iscolumn(x)
        x = x.';
    end
    t_istest = logical(t_istest);
    if ~iscolumn(t_istest)
        t = t.';
    end
    
    if any(t_istest)
        x(t_istest) = NaN;
    end
    [x_trend,x_season,x_residue] = M3(t,x,T_annual,h,trend_deg);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

%%

function M12_cv_handle = M12_cv_handle_gen(M12_HANDLE)
% H1
    M12_cv_handle = @M12_cv;
    return;
    
    function [x_fit] = M12_cv(t,x,t_istest,span,lwlr_annual,cat_ind_cell)
    % M12_cv - cross validation for Method-1A,1B,2,2A
    % description
        if ~iscolumn(t)
            t = t.';
        end
        if ~iscolumn(x)
            x = x.';
        end
        t_istest = logical(t_istest);
        if ~iscolumn(t_istest)
            t = t.';
        end
        if isscalar(span)
            span = [span, span];
        end
        
        if any(t_istest)
            x(t_istest) = NaN;
        end
        [x_trend,x_season,x_residue] = M12_HANDLE(t,x,span,lwlr_annual,cat_ind_cell);
        x_fit.trend = x_trend;
        x_fit.season = x_season;
        x_fit.residue = x_residue;
    
        return;
    end
end
