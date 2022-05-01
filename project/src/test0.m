%% test0.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-05-01
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

%% Parameters definition

%
Fs = 12*1;      % sampling rate Fs. For example, to obtain a trend per year from data collected at monthly resolution, set Fs equal to 12. This syntax assumes all values in y are equally spaced in time. [CDT:trend documentation](https://www.chadagreene.com/CDT/trend_documentation.html#2)
n_years = 60;   % total number of years
T_season = 1;   % [year] the cycle of anomalies associated with the typical seasonal (aka annual) cycle or of a time series.
T_var = 3;      % [year] the cycle of interannual variability
T_noise = 1/4;  % [year] the cycle of noise
% Note[2]: In general, CDT[T2] assumes that a multi-year record of a variable sampled  at subannual resolution can described by
% y = y_trend + y_climatology + y_var + y_noise, where
% y_climatology = y_0 + y_season, such that mean(y_season) = 0.
y_base = 2;     % baseline
A_season = 1;   % amplitude of seasonal (aka annual) signal (climatology?)
A_var = .2;     % amplitude of interannual variability
A_noise = 0;    % amplitude of noise
y_trend_poly_coeff = [5e-4,A_var/(3*T_var),0]; % polynomial coefficients ordered by descending powers

%% Simulation initiation

t = linspace(0,n_years,n_years*Fs+1).';             % [year]
num_months = discretize(t,0:1/12:n_years+1/12);     % number of months.
name_months = mod(num_months,12);
name_months(name_months == 0) = 12;                 % name of month. 1 = Jan, ..., Dec = 12.
y_trend = polyval(y_trend_poly_coeff,t);            % the long-term [trend](https://www.chadagreene.com/CDT/trend_documentation.html)
y_season = A_season*sin((2*pi/T_season)*t);         % the typical seasonal anomaly, which the [season](https://www.chadagreene.com/CDT/season_documentation.html) function obtains after detrending and removing the mean
y_var = A_var*sin((2*pi/T_var)*t);                  % interannual variability (cycle > 1 year)
y_noise = A_noise*sin((2*pi/T_noise)*t);            % noise (cycle < 1 year)
y = y_base + y_trend + y_season + y_var + y_noise;  % original data

%% Simulation
% Scientific question: Is the "variability" obtained by algorithm A, where
%   "climatology" is determined *before* detrending, the same as that
%   obtained by algorithm B, where "climatology" is determined *after*
%   detrending? If not, what are the factors that determine the difference
%   between them? Can a quantitative conclusion be drawn?

%% Simulation - algorithm B ("climatology" determined *before* detrending)
% Step-1  Determines the "climatology" and "anomaly" directly, without detrending.
%   Note: The term "climatology" is defined as the average values *of the
%   orginal data* for each of the 366 days (or 12 months) of the year.
%       The definition of "climatology" here is different from that in Algorithm A. 
%   Note: The term "anomaly" here is defined as the difference between
%       the *original* data and "climatology".
%       The definition of "anomaly" here is different from that in Algorithm A. 
%   Note: It is expected that "anomaly" = "trend" + "variability" + "noise".
%   Remark: The above definition leads to the fact that
%       "anomaly" (expected to be "trend" + "variability" + "noise") has an
%       arithmetic mean of 0.
% Step-2  Determines the "trend" of "anomaly".
%   Note: It is expected that, removing the "trend" from "anomaly"
%       will result in "variability" + "noise".
%   Note: We can choose a linear (or other forms of polynomial, of course)
%       least squares trend.
% Step-3  Determines the "variability" (with "noise", expected) by removing
%   the "trend" of "anomaly".
%   Note[5]: By default, anomalies (of "anomaly", here) are calculated
%       after removing the linear least squares trend, but if, for example,
%       warming is strongly nonlinear, you may prefer the 'quadratic' option.
%       Default is 'linear'.
%   Remark: If a linear least squares trend is chosen, the "variability"
%       (with "noise") also has zero arithmetic mean, since "anomaly" is
%       zero arithmetic mean, and the fact that linear regression model
%       pass the mean point of sample.
% Question: What would happen if a non-linear trend is chosen?

%% Simulation - algorithm A ("climatology" determined *after* detrending)
% Step-1  Determines the "trend" of the orginal data.
%   Note: It is expected that removing the "trend" from the orginal data
%       will result in "climatology" + "variability" + "noise".
% Step-2  Determines the "climatology" and "anomaly" of the detrended data.
% It is expected that this "anomaly" represents "variability" + "noise".
%   Note: The term "climatology" is defined as the average values *of the
%       detrended data* for each of the 366 days (or 12 months) of the year.
%       The definition of "climatology" here is different from that in Algorithm B. 
%   Note: The term "anomaly" here is defined as the difference between
%       the *detrended* data and "climatology".
%       The definition of "anomaly" here is different from that in Algorithm B. 
%   Note: It is expected that "anomaly" = "variability" + "noise".
%   Remark: The above definition leads to the fact that
%       "anomaly" (expected to be "variability" + "noise") has an
%       arithmetic mean of 0.
% Question: Is the "variability" obtained by algorithm A the same as that
%   obtained by algorithm B? If not, what are the factors that determine
%   the difference between them? Can a quantitative conclusion be drawn?

%% Create figure.

%% Fig.1 (title)

t_fig = figure('Name',"Fig.1 (orginal data)");
t_TCL = tiledlayout(1,1,"TileSpacing","tight","Padding","tight");
t_axes = nexttile(t_TCL,1);
t_plot_y = plot(t_axes,t,y,'-',"DisplayName",'$y := \sum_i{y_i}$');
hold on
t_plot_y_trend = plot(t_axes,t,y_base+y_trend,'--', ...
    "DisplayName","$y_{\rm{base}} + y_{\rm{trend}} = [" + strjoin(string([y_trend_poly_coeff(1:end-1),y_base]),',')+"]$");
t_plot_y_season = plot(t_axes,t,y_season,'-', ...
    "DisplayName",sprintf("$y_{\\rm{season}} = (T = %.2g, A = %.2g)$",T_season,A_season));
t_plot_y_var = plot(t_axes,t,y_var,'-', ...
    "DisplayName",sprintf("$y_{\\rm{variability}} = (T = %.2g, A = %.2g)$",T_var,A_var));
t_plot_y_noise = plot(t_axes,t,y_noise,'-', ...
    "DisplayName",sprintf("$y_{\\rm{noise}} = (T = %.2g, A = %.2g)$",T_noise,A_noise));
hold off
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off');
legend(t_axes,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
xlabel(t_axes,"$t$ (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes,"$y$","FontSize",10,"Interpreter","latex");
title(t_axes,"\bf original data","Interpreter","latex")
%
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_1_data.emf",'Resolution',600,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_1_data.png",'Resolution',600,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');

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
