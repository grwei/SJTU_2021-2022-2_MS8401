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

[x_1A,x_1B,x_2,x_2A,x_3] = simple_test();

%% Exp. 1

export_fig_EN = 1;
create_fig_EN = 0;

t = (1:122*12).';                       % [months] 1900-2021
span = [15*12,15*12-1];                 % [months]
lwlr_annual = 1;
h = 2;

cat_ind_cell = cell(12,1);
for i = 1:12
    cat_ind_cell{i,1} = i:12:length(t);
end

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

x = cell(2,1);
for i = 1:length(x_trend)
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_noise;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
    [x_1A,x_1B,x_2,x_2A,x_3] = test2_plot1(t,x{i},span,lwlr_annual,T_annual,h,cat_ind_cell, ...
        @M1_A,@M1_B,@M2,@M2_A,@M3, ...
        @M1_A_cv,@M1_B_cv,@M2_A_cv,@M2_cv,@M3_cv, ...
        sprintf("ideal_1_%d",i),sprintf("ideal_1_%d",i),create_fig_EN,export_fig_EN);
end

%% Exp. 1.1.2 (inter-annual)

x = cell(2,1);
for i = 1:length(x_trend)
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_inter_an;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
     [x_1A,x_1B,x_2,x_2A,x_3] = test2_plot1(t,x{i},span,lwlr_annual,T_annual,2,cat_ind_cell,@M1_A,@M1_B,@M2,@M2_A,@M3,sprintf("ideal_2_%d",i),sprintf("ideal_2_%d",i),create_fig_EN,export_fig_EN);
end

%% Exp. 1.1.3 (inter-annual + noise)

x = cell(2,1);
for i = 1:length(x_trend)
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_inter_an + x_noise;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
    [x_1A,x_1B,x_2,x_2A,x_3] = test2_plot1(t,x{i},span,lwlr_annual,T_annual,2,cat_ind_cell,@M1_A,@M1_B,@M2,@M2_A,@M3,sprintf("ideal_3_%d",i),sprintf("ideal_3_%d",i),create_fig_EN,export_fig_EN);
end

%% Exp. 1.2 (sensitivity to increment of trend)

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
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_inter_an + x_noise;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
    [x_1A,x_1B,x_2,x_2A,x_3] = test2_plot1(t,x{i},span,lwlr_annual,T_annual,2,cat_ind_cell,@M1_A,@M1_B,@M2,@M2_A,@M3,sprintf("ideal_4_%d",i),sprintf("ideal_4_%d",i),create_fig_EN,export_fig_EN);
end

%% Exp. 1.3 (sensitivity to Explained Variance (EV) of annual cycle)

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
    x{i}.season = x_annual;
    x{i}.trend = x_trend{i};
    x{i}.raw = x_trend{i} + x_annual + x_inter_an + x_noise;
    x{i}.residue = x{i}.raw - x{i}.trend - x{i}.season;
    [x_1A,x_1B,x_2,x_2A,x_3] = test2_plot1(t,x{i},span,lwlr_annual,T_annual,2,cat_ind_cell,@M1_A,@M1_B,@M2,@M2_A,@M3,sprintf("ideal_5_%d",i),sprintf("ideal_5_%d",i),create_fig_EN,export_fig_EN);
end

%% local functions

%% Initialize environment

function [] = init_env()
    % Initialize environment
    %
    % set up project directory
    if ~isfolder("../doc/fig/test2/")
        mkdir ../doc/fig/test2/
    end
    % configure searching path
    mfile_fullpath = mfilename('fullpath'); % the full path and name of the file in which the call occurs, not including the filename extension.
    mfile_fullpath_without_fname = mfile_fullpath(1:end-strlength(mfilename));
    addpath(genpath(mfile_fullpath_without_fname + "../data"), ...
            genpath(mfile_fullpath_without_fname + "../inc")); % adds the specified folders to the top of the search path for the current MATLAB® session.

    return;
end

%%

function [y_lwlr] = lwlr_period(x,y,span,lwlr_annual,x_pred,weight_fun)
%lwlr - Locally Weighted Linear Regression (LWLR)
%
% Syntax: [y_lwlr] = lwlr(x,y,span,lwlr_annual,x_pred,weight_fun)
%
% Locally Weighted Linear Regression (LWLR)

    arguments
        x           % predictor
        y           % response
        span        % [6,6]
        lwlr_annual = 1;
        x_pred = x;
        weight_fun = @(x) ones(length(x),1); % column vector
    end

    if ~iscolumn(x)
        x = x.';
    end
    if ~iscolumn(y)
        y = y.';
    end
    if ~iscolumn(x_pred)
        x_pred = x_pred.';
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

    y_lwlr = nan(size(y));
    for i = 1:length(x_pred)
        % determine data range
        ind_left = find(x >= x_pred(i) - span(1),1,'first');
        ind_right = find(x <= x_pred(i) + span(2),1,'last');
        if (ind_left == 1)
%             ind_right = ind_right - mod(ind_right - ind_left + 1,lwlr_annual);
            ind_right = ind_left + span(2) + span(1);
        elseif (ind_right == length(x))
%             ind_left = ind_left + mod(ind_right - ind_left + 1,lwlr_annual);
            ind_left = ind_right - span(2) - span(1);
        end

        X = [ones(ind_right-ind_left+1,1),x(ind_left:ind_right)];
        Y = y(ind_left:ind_right);
        w = weight_fun(ind_left:ind_right); % column vector
        coeff = ((X.'*(w.*X))\(X.'*(w.*Y)));
        y_lwlr(i) = [1,x_pred(i)]*coeff;
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
    season_main = season_main - mu;
    
    season_series = nan(size(x));
    for i = 1:length(cat_ind_cell)
        season_series(cat_ind_cell{i}) = season_main(i);
    end

    return;
end

%% (Narapusetty, 2009)

function [coeff,season_series] = season_spectral(t,x,period,h,t_pred)
%season_spectral - annual cycle determined by spectral method
%
% Syntax: [coeff,season_series] = season_spectral(t,x,period,h)
%
% The spectral method, is to fit the time series to a sum of sines and
% cosines that are periodic on specified time scales.

    arguments
        t
        x
        period
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

    omega_vec = 2*pi/period*(1:h);
    T = [ones(length(t),1),cos(t*omega_vec),sin(t*omega_vec)]; % data matrix
    coeff = (T.'*T)\(T.'*x);
    
    T_pred = [ones(length(t_pred),1),cos(t_pred*omega_vec),sin(t_pred*omega_vec)]; % data matrix
    season_series = T_pred*coeff - coeff(1);

    return;
end

%% Determine linear trend and annual cycle simultaneously by LSM.

function [coeff,season_series,trend_series] = season_spectral_trend(t,x,period,h,t_pred)
%season_spectral - determine linear trend and annual cycle simultaneously by LSM
%
% Syntax: [coeff,season_series,trend_series] = season_spectral_trend(t,x,period,h)
%
% The spectral method, is to fit the time series to a sum of sines and
% cosines that are periodic on specified time scales.

    arguments
        t
        x
        period
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

    omega_vec = 2*pi/period*(1:h);
    T = [ones(length(t),1),t,cos(t*omega_vec),sin(t*omega_vec)]; % data matrix
    coeff = (T.'*T)\(T.'*x);
    
    trend_series = [ones(length(t_pred),1),t_pred]*coeff(1:2);
    season_series = [cos(t_pred*omega_vec),sin(t_pred*omega_vec)]*coeff(3:end);

    return;
end

%% Method-1A: trend (lwlr); annual cycle (simple average)

function [x_trend,x_annual,x_res] = M1_A(t,x,span,lwlr_annual,cat_ind_cell)
%M1_A - classical decomposition method-1A
%
% Syntax: [x_trend,x_annual,x_res] = M1_A(t,x,span,lwlr_annual,cat_ind_cell)
%
% Estimate trend using local-weighted linear regression (LWLR), and then
% estimate annual cycle by simple averaging.
    
    arguments
        t
        x
        span
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
    
    x_trend = lwlr_period(t,x,span,lwlr_annual);

    %%% 2. Estimate annual cycle by simple averaging.

    [~,x_annual,~] = season_simple(x - x_trend,cat_ind_cell);

    %%% 3. irregular estimates

    x_res = x - x_trend - x_annual;

    return;
end

%% Method-1B: annual cycle (simple average); trend (lwlr)

function [x_trend,x_annual,x_res] = M1_B(t,x,span,lwlr_annual,cat_ind_cell)
%M1_A - classical decomposition method-1B
%
% Syntax: [x_trend,x_annual,x_res] = M1_B(t,x,span,lwlr_annual,cat_ind_cell)
%
% Estimate annual cycle by simple averaging, and then Estimate trend using
% local-weighted linear regression (LWLR)

    arguments
        t
        x
        span
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

    [~,x_annual,~] = season_simple(x,cat_ind_cell);

    %%% 2. Estimate trend using local-weighted linear regression (LWLR)
    
    x_trend = lwlr_period(t,x - x_annual,span,lwlr_annual);

    %%% 3. irregular estimates

    x_res = x - x_trend - x_annual;

    return;
end

%% Method-2: (Pezzulli, S., 2005)

function [x_trend,x_annual,x_res] = M2(t,x,span,lwlr_annual,cat_ind_cell)
%M2 - classical decomposition method-2
%
% Syntax: [x_trend,x_annual,x_res] = M2(t,x,span,lwlr_annual,cat_ind_cell)
%
% The algorithm consists of an alternate trend estimation on seasonally
% adjusted series and seasonal estimation on the trend-adjusted one.
% Reference: Pezzulli, S., D. B. Stephenson, and A. Hannachi. "The Variability of Seasonality", Journal of Climate 18, 1 (2005): 71-88, accessed Jul 5, 2022, https://doi.org/10.1175/JCLI-3256.1
    
    arguments
        t
        x
        span
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
    
    x_trend_init = lwlr_period(t,x,span,lwlr_annual);
    [~,x_annual_init,~] = season_simple(x - x_trend_init,cat_ind_cell);
    
    %%% 2. Revised trend and seasonal estimates

    x_trend_rev = lwlr_period(t,x - x_annual_init,span,lwlr_annual);
    [~,x_annual,~] = season_simple(x - x_trend_rev,cat_ind_cell);

    %%% 3. Final trend and irregular estimates

    x_trend = lwlr_period(t,x - x_annual,span,lwlr_annual);
    x_res = x - x_trend - x_annual;

    return;
end

%% Method-2A: adapted from (Pezzulli, S., 2005)

function [x_trend,x_annual,x_res] = M2_A(t,x,span,lwlr_annual,cat_ind_cell)
%M2 - classical decomposition method-2A
%
% Syntax: [x_trend,x_annual,x_res] = M2_A(t,x,span,lwlr_annual,cat_ind_cell)
%
% The algorithm consists of an alternate trend estimation on seasonally
% adjusted series and seasonal estimation on the trend-adjusted one.
% Reference: Pezzulli, S., D. B. Stephenson, and A. Hannachi. "The Variability of Seasonality", Journal of Climate 18, 1 (2005): 71-88, accessed Jul 5, 2022, https://doi.org/10.1175/JCLI-3256.1
    
    arguments
        t
        x
        span
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
    
    [~,x_annual_init,~] = season_simple(x,cat_ind_cell);
    x_trend_init = lwlr_period(t,x - x_annual_init,span,lwlr_annual);
    
    %%% 2. Revised seasonal and trend estimates

    [~,x_annual_rev,~] = season_simple(x - x_trend_init,cat_ind_cell);
    x_trend = lwlr_period(t,x - x_annual_rev,span,lwlr_annual);

    %%% 3. Final seasonal and irregular estimates

    [~,x_annual,~] = season_simple(x - x_trend,cat_ind_cell);
    x_res = x - x_trend - x_annual;

    return;
end

%% Method-3

function [x_trend,x_annual,x_res] = M3(t,x,T_annual,h)
%M3 - classical decomposition method-3
%
% Syntax: [x_trend,x_annual,x_res] = M3(t,x,T_annual,h)
%
% Estimate linear trend and annual cycle simultaneously, by global linear
% regression.

    arguments
        t
        x
        T_annual
        h
    end

    %%% 1. Estimate trend and annual cycle simultaneously, by global linear regression.

    [~,x_annual,x_trend] = season_spectral_trend(t,x,T_annual,h);
    
    %%% 2. irregular estimates

    x_res = x - x_trend - x_annual;

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

function [x_fit] = M1_A_cv(t,x,t_istest,span,lwlr_annual,cat_ind_cell)
% M1_A_cv - cross validation for Method-1A
% description
    arguments
        t
        x
        t_istest
        span = [15*12,15*12-1];
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
    [x_trend,x_season,x_residue] = M1_A(t,x,span,lwlr_annual,cat_ind_cell);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

function [x_fit] = M1_B_cv(t,x,t_istest,span,lwlr_annual,cat_ind_cell)
% M1_B_cv - cross validation for Method-1B
% description
    arguments
        t
        x
        t_istest
        span = [15*12,15*12-1];
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
    [x_trend,x_season,x_residue] = M1_B(t,x,span,lwlr_annual,cat_ind_cell);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

function [x_fit] = M2_A_cv(t,x,t_istest,span,lwlr_annual,cat_ind_cell)
% M2_A_cv - cross validation for Method-2A
% description
    arguments
        t
        x
        t_istest
        span = [15*12,15*12-1];
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
    [x_trend,x_season,x_residue] = M2_A(t,x,span,lwlr_annual,cat_ind_cell);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

function [x_fit] = M2_cv(t,x,t_istest,span,lwlr_annual,cat_ind_cell)
% M2_cv - cross validation for Method-2
% description
    arguments
        t
        x
        t_istest
        span = [15*12,15*12-1];
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
    [x_trend,x_season,x_residue] = M2(t,x,span,lwlr_annual,cat_ind_cell);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

function [x_fit] = M3_cv(t,x,t_istest,T_annual,h)
% M3_cv - cross validation for Method-3
% description
    arguments
        t
        x
        t_istest
        T_annual
        h
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
    [x_trend,x_season,x_residue] = M3(t,x,T_annual,h);
    x_fit.trend = x_trend;
    x_fit.season = x_season;
    x_fit.residue = x_residue;

    return;
end

%%

function M12_cv_handler = M12_cv_handler_gen(M12_HANDLER)
% H1
    M12_cv_handler = @M12_cv;
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
        [x_trend,x_season,x_residue] = M12_HANDLER(t,x,span,lwlr_annual,cat_ind_cell);
        x_fit.trend = x_trend;
        x_fit.season = x_season;
        x_fit.residue = x_residue;
    
        return;
    end
end
