%% helloworld.m
% Description: MATLAB code for MS8401 (2022 Spring)
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-04-19
% Last modified: 2022-04-
% Toolbox: [1] [M_Map: A mapping package for Matlab](https://www.eoas.ubc.ca/~rich/map.html)

%% Initialize project

clc; clear; close all
init_env();

%%

x = linspace(0,2*pi,1000);
y = sin(x);
z = cos(x);
figure('Name',"fig.1")
hold on;
plot(x,y,'b');
plot(x,z,'g');
xlabel 'X values';
ylabel 'Y values';
title 'Sample Plot';
legend ('Y data','Z data');
hold off;
grid on

%%

figure('Name',"fig.2")
t1 = linspace(0,1,1000);
t2 = linspace(1,6,1000);
y1 = t1;
y2 = 1./ t2;
t = [t1,t2];
y = [y1,y2];
plot(t,y);
xlabel 't values', ylabel 'y values';

%%

figure("Name","m_map fig.3")
m_proj('oblique mercator');
m_coast;
m_grid;

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
