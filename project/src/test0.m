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
T_noise = 1/8;  % [year] the cycle of noise
% Note[2]: In general, CDT[T2] assumes that a multi-year record of a variable sampled  at subannual resolution can described by
% y = y_trend + y_climatology + y_var + y_noise, where
% y_climatology = y_0 + y_season, such that mean(y_season) = 0.
y_base = 2;     % baseline
A_season = 1;   % amplitude of seasonal (aka annual) signal (climatology?)
A_var = .25;     % amplitude of interannual variability
A_noise = .0;    % amplitude of noise
% polynomial coefficients ordered by descending powers
y_trend_poly_coeff = [0.2*A_var/T_var,0];         % Case-1- slow linear trend, without noise
% y_trend_poly_coeff = [6e-4,0*A_var/T_var,0];      % Case-2- slow quadratic trend, without noise
% y_trend_poly_coeff = [3*A_var/T_var,0];           % Case 3- fast linear trend, without noise
% y_trend_poly_coeff = [5e-3,0*A_var/T_var,0];      % Case 4- fast quadratic trend, without noise
% y_trend_poly_coeff = [0.2*A_var/T_var,0];A_noise = .4;        % Case 5- slow linear trend, with noise added
y_trend_poly_coeff = [300*A_var/T_var,0];
trend_n = length(y_trend_poly_coeff) - 1;           % polynomial degree of trend

%% Simulation initiation

t = linspace(0,n_years-1/12,n_years*Fs).'+1/24;     % [year]
num_months = discretize(t,0:1/12:n_years+1/12);     % number of months.
name_months = mod(num_months,12);
name_months(name_months == 0) = 12;                 % name of month. 1 = Jan, ..., 12 = Dec.
y_trend = polyval(y_trend_poly_coeff,t);            % the long-term [trend](https://www.chadagreene.com/CDT/trend_documentation.html)
y_season = A_season*sin((2*pi/T_season)*(t-1/4));   % the typical seasonal anomaly, which the [season](https://www.chadagreene.com/CDT/season_documentation.html) function obtains after detrending and removing the mean
y_var = A_var*sin((2*pi/T_var)*t);                  % interannual variability (cycle > 1 year)
y_noise = A_noise*sin((2*pi/T_noise)*t);            % noise (cycle < 1 year)
y = y_base + y_trend + y_season + y_var + y_noise;  % original data

%% Simulation
% Scientific problem: Is the "variability" obtained by algorithm B, where
%   "climatology" is determined *before* detrending, the same as that
%   obtained by algorithm A, where "climatology" is determined *after*
%   detrending? If not, what are the factors that determine the difference
%   between them? Can a quantitative conclusion be drawn?

%% Simulation - Algorithm B ("climatology" determined *before* detrending)
% Step-1  Determines the "climatology" and "anomaly" directly, without
%   detrending.
%   Note: The term "climatology" is defined as the average values of the
%       *orginal* data for each of the 366 days (or 12 months) of the year.
%       The definition of "climatology" here is different from that in
%       Algorithm A.
%   Note: The term "anomaly" here is defined as the difference between
%       the *original* data and "climatology". The definition of "anomaly"
%       here is different from that in Algorithm A.
%   Note: It is expected that "anomaly" = "trend" + "variability" +
%       "noise".
%   Remark: The above definition leads to the fact that
%       "anomaly" (expected to be "trend" + "variability" + "noise") has an
%       arithmetic mean of 0.
% Step-2  Determines the "trend" of "anomaly".
%   Note: It is expected that, removing the "trend" from "anomaly"
%       results in "variability" + "noise".
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

%%% Step-1  Determines the "climatology" and "anomaly"

[climatology_B,anomalies_B,climatology_B_cat] = climatology_month(y,name_months);
% [2]: y_climatology = y_0 + y_season, where y_season always has a 0 mean
% value
y_0_B = mean(climatology_B_cat);            % the long-term mean
season_B = climatology_B - y_0_B;           % (entire series) seasonal anomaly for the entire time series

%%% Step-2  Determines the "trend" of "anomaly"

[trend_B_p_sc,S_B,mu_B] = polyfit(t,anomalies_B,trend_n);
trend_B_p = poly_sc2ori(trend_B_p_sc,mu_B);
trend_B = polyval(trend_B_p_sc,t,[],mu_B);

%%% Step-3  Determines the "variability" (with "noise", expected)

variability_plus_noise_B = anomalies_B - trend_B;

%% Simulation - Algorithm A ("climatology" determined *after* detrending)
% Step-1  Determines the "trend" of the orginal data.
%   Note: It is expected that removing the "trend" from the orginal data
%       results in "climatology" + "variability" + "noise".
% Step-2  Determines the "climatology" and "anomaly" ("variability") of the
%   *detrended* data. 
%   It is expected that this "anomaly" represents "variability" + "noise".
%   Note: The term "climatology" is defined as the average values of the
%       *detrended* data for each of the 366 days (or 12 months) of the
%       year. The definition of "climatology" here is different from that
%       in Algorithm B.
%   Note: The term "anomaly" here is defined as the difference between
%       the *detrended* data and "climatology". The definition of "anomaly"
%       here is different from that in Algorithm B.
%   Note: It is expected that "anomaly" = "variability" + "noise".
%   Remark: The above definition leads to the fact that
%       "anomaly" (expected to be "variability" + "noise") has an
%       arithmetic mean of 0.
% Question: Is the "variability" obtained by algorithm A the same as that
%   obtained by algorithm B? If not, what are the factors that determine
%   the difference between them? Can a quantitative conclusion be drawn?

%%% Step-1  Determines the "trend" of the orginal data.

[trend_A_p_sc,S_A,mu_A] = polyfit(t,y,trend_n);
trend_A_p = poly_sc2ori(trend_A_p_sc,mu_A);
trend_A = polyval(trend_A_p_sc,t,[],mu_A);

%%% Step-2  Determines the "climatology" and "anomaly" ("variability") of
% the *detrended* data.

[climatology_A,variability_plus_noise_A,climatology_A_cat] = climatology_month(y-trend_A,name_months);
y_0_A = mean(climatology_A_cat);            % the long-term mean
season_A = climatology_A - y_0_A;           % (entire series) seasonal anomaly for the entire time series

%% Create figure.

%% Fig.1 (orginal data)

t_fig = figure('Name',"Fig.1 (orginal data)");
t_TCL = tiledlayout(1,1,"TileSpacing","tight","Padding","tight");
t_axes = nexttile(t_TCL,1);
t_plot_y = plot(t_axes,t,y,'-',"DisplayName",'$y := \sum_i{y_i}$');
hold on
t_plot_y_trend = plot(t_axes,t,y_base+y_trend,'--', ...
    "DisplayName","$y_{\rm{base}} + y_{\rm{trend}} = [" + strjoin(string([y_trend_poly_coeff(1:end-1),y_base]),',')+"]$");
t_plot_y_season = plot(t_axes,t,y_season,'-', ...
    "DisplayName",sprintf("$y_{\\rm{season}} = (T = %g, A = %g)$",T_season,A_season));
t_plot_y_var = plot(t_axes,t,y_var,'-', ...
    "DisplayName",sprintf("$y_{\\rm{variability}} = (T = %g, A = %g)$",T_var,A_var));
t_plot_y_noise = plot(t_axes,t,y_noise,'-', ...
    "DisplayName",sprintf("$y_{\\rm{noise}} = (T = %g, A = %g)$",T_noise,A_noise));
hold off
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out');
legend(t_axes,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
xlabel(t_axes,"$t$ (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes,"$y$","FontSize",10,"Interpreter","latex");
title(t_axes,sprintf("\\bf original data $(f_{\\rm s} = %g,\\,N = %g)$",Fs,length(y)),"Interpreter","latex")
%
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_1_original_data.emf",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_1_original_data.png",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');

%% Fig.2(b) (Algorithm B: "climatology" determined *before* detrending)
% y = y_climatology + (y_trend + (y_varibility + noise))

t_fig = figure('Name',"Fig.2(b) (Algorithm B)");
t_TCL = tiledlayout(1,1,"TileSpacing","tight","Padding","tight");
t_axes = nexttile(t_TCL,1);
t_plot_y_B = plot(t_axes,t,y,'-',"DisplayName",'$y_{\rm{B}} := \sum_i{y_{{\rm B},i}} \equiv y$');
hold on
t_plot_y_B_trend = plot(t_axes,t,trend_B,'--', ...
    "DisplayName","$y_{\rm{B,trend}} = [" + strjoin(string(trend_B_p),',')+"]$");
t_plot_y_B_climatology = plot(t_axes,t,climatology_B,'-', ...
    "DisplayName",sprintf("$y_{\\rm{B,climatology}}$ $(\\rm{mean} = %g)$",mean(climatology_B,"omitnan")));
t_plot_y_B_var = plot(t_axes,t,variability_plus_noise_B,'-', ...
    "DisplayName",sprintf("$y_{\\rm{B,variability + noise}}$ $(\\rm{mean} = %g)$",mean(variability_plus_noise_B,"omitnan")));
hold off
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out');
legend(t_axes,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
xlabel(t_axes,"$t$ (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes,"$y_{\rm{B}}$","FontSize",10,"Interpreter","latex");
title(t_axes,'\bf Algorithm B: climatology determined {\it before} detrending',"Interpreter","latex")
%
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_2b_Algorithm_B.emf",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_2b_Algorithm_B.png",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');

%% Fig.2(a) (Algorithm A: "climatology" determined *after* detrending)
% y = y_trend + (y_climatology + (y_varibility + noise))

t_fig = figure('Name',"Fig.2(a) (Algorithm A)");
t_TCL = tiledlayout(1,1,"TileSpacing","tight","Padding","tight");
t_axes = nexttile(t_TCL,1);
t_plot_y_A = plot(t_axes,t,y,'-',"DisplayName",'$y_{\rm{A}} := \sum_i{y_{{\rm A},i}} \equiv y$');
hold on
t_plot_y_A_trend = plot(t_axes,t,trend_A,'--', ...
    "DisplayName","$y_{\rm{A,trend}} = [" + strjoin(string(trend_A_p),',')+"]$");
t_plot_y_A_climatology = plot(t_axes,t,climatology_A,'-', ...
    "DisplayName",sprintf("$y_{\\rm{A,climatology}}$ $(\\rm{mean} = %g)$",mean(climatology_A,"omitnan")));
t_plot_y_A_var = plot(t_axes,t,variability_plus_noise_A,'-', ...
    "DisplayName",sprintf("$y_{\\rm{A,variability + noise}}$ $(\\rm{mean} = %g)$",mean(variability_plus_noise_A,"omitnan")));
hold off
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out');
legend(t_axes,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
xlabel(t_axes,"$t$ (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes,"$y_{\rm{A}}$","FontSize",10,"Interpreter","latex");
title(t_axes,'\bf Algorithm A: climatology determined {\it after} detrending',"Interpreter","latex")
%
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_2a_Algorithm_A.emf",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_2a_Algorithm_A.png",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');

%% Fig.3 (difference between output and original)

t_fig = figure('Name',"Fig.3 (diff: output and original)");
t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");
%%% season
t_axes_diff_season = nexttile(t_TCL,1);
t_plot_diff_season_A = plot(t_axes_diff_season,t,(season_A-y_season)/A_season,'-', ...
    "DisplayName",'$(y_{\rm A,season} - y_{\rm season})/A_{\rm season}$');
hold on
t_plot_diff_season_B = plot(t_axes_diff_season,t,(season_B-y_season)/A_season,'-', ...
    "DisplayName",'$(y_{\rm B,season} - y_{\rm season})/A_{\rm season}$');
hold off
set(t_axes_diff_season,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out');
legend(t_axes_diff_season,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
% xlabel(t_axes_diff_season,"$t$ (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes_diff_season,"$y_{\rm{season}}$","FontSize",10,"Interpreter","latex");
title(t_axes_diff_season,'\bf season',"Interpreter","latex")
%%% variability
t_axes_diff_var = nexttile(t_TCL,2);
t_plot_diff_var_A = plot(t_axes_diff_var,t,(variability_plus_noise_A-y_var)/A_var,'-', ...
    "DisplayName",'$(y_{\rm{A,variability}} - y_{\rm{variability}})/A_{\rm var}$');
hold on
t_plot_diff_var_B = plot(t_axes_diff_var,t,(variability_plus_noise_B-y_var)/A_var,'-', ...
    "DisplayName",'$(y_{\rm{B,variability}} - y_{\rm{variability}})/A_{\rm var}$');
hold off
set(t_axes_diff_var,"YDir",'normal',"TickLabelInterpreter",'latex',"FontSize",10,'Box','off','TickDir','out');
legend(t_axes_diff_var,"Location",'best','Interpreter','latex',"Box","off",'FontSize',10);
% xlabel(t_TCL,"$t$ (year)",FontSize=10,Interpreter="latex");
ylabel(t_axes_diff_var,"$y_{\rm variability}$","FontSize",10,"Interpreter","latex");
title(t_axes_diff_var,'\bf variability',"Interpreter","latex")
%
title(t_TCL,"\bf difference between output and original","Interpreter","latex")
xlabel(t_TCL,"$t$ (year)",FontSize=10,Interpreter="latex");
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_3_diff_output_original.emf",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
exportgraphics(t_TCL,"..\\doc\\fig\\Fig_3_diff_output_original.png",'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');

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

%% convert scaled-and-centered polynomial coefficient to original ones.
function [p_ori] = poly_sc2ori(p_sc,mu)
% H1
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
end

%% climatology (monthly): average values for each of the 12 months of the year
function [climatology,anomalies,climatology_cat] = climatology_month(data,name_months)
% H1
% Details.
    arguments
        data
        name_months     % name of month. 1 = Jan, ..., 12 = Dec.
    end
    climatology_cat = nan(12,1);        % (12 months)
    climatology = nan(length(data),1);  % (entire series)
    for months_ = 1:12
        climatology_cat(months_) = mean(data(name_months == months_),"omitnan");
        climatology(name_months == months_) = climatology_cat(months_);
    end
    anomalies = data - climatology; % (entire series)
end
