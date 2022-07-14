%% test2_ersst_v5_postproc.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-07-14
% Last modified: 2022-07-

% function [] = test2_ersst_v5_postproc(mat_file_path)
% %test2_ersst_v5_postproc - Description
% %
% % Syntax: output = test2_ersst_v5_postproc(mat_file_path)
% %
% % Long description
% arguments
%     mat_file_path = "../bin/test2/ersst_v5.mat"
% end

mat_file_path = "../bin/test2/ersst_v5.mat";
load(mat_file_path,'ersst_v5');

METHOD_NAME = ersst_v5.METHOD_NAME;
METHOD_DISP_NAME = ersst_v5.METHOD_DISP_NAME;
INDICES_REAL_NAME = ersst_v5.INDICES_NAME;
INDICES_VAR_TYPES = ersst_v5.INDICES_VAR_TYPES;
t = ersst_v5.t;
lon = ersst_v5.lon;
lat = ersst_v5.lat;

tt = cell2mat(ersst_v5.M1A.cm2raw_EV);
