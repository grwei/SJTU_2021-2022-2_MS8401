%% test2_ersst_v5_postproc.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-07-14
% Last modified: 2022-07-

%% Initialize project

clc; clear; close all
init_env();

%%
mat_file_path = "../bin/test2/ersst_v5.mat";
% mat_file = matfile(mat_file_path);
% ersst_v5 = mat_file.ersst_v5;
load(mat_file_path,'ersst_v5');

%%
create_fig_EN = false;
export_fig_EN = false;
METHOD_NAME = ersst_v5.METHOD_NAME;
METHOD_DISP_NAME = ersst_v5.METHOD_DISP_NAME;
INDICES_REAL_NAME = ersst_v5.INDICES_NAME;
INDICES_VAR_TYPES = ersst_v5.INDICES_VAR_TYPES;
t = ersst_v5.t;
lon = ersst_v5.lon;
lat = ersst_v5.lat;

%% mean of annual cycle and residual

season_mean.method_name = METHOD_NAME;
residual_mean.method_name = METHOD_NAME;
season_mean.lon = lon;
season_mean.lat = lat;
residual_mean.lon = lon;
residual_mean.lat = lat;
for k = 1:length(season_mean.method_name)
    method_name = season_mean.method_name(k);
    %
    season_mean.(method_name) = nan(length(lon),length(lat));
    residual_mean.(method_name) = nan(length(lon),length(lat));
    for i = 1:length(lon)
        for j = 1:length(lat)
            season_mean.(method_name)(i,j) = mean(ersst_v5.(method_name).season{i,j},"omitnan");
            residual_mean.(method_name)(i,j) = mean(ersst_v5.(method_name).residue{i,j},"omitnan");
        end
    end
end

%% Max. Diff.

ref_method_name = repmat("M2",[1,length(METHOD_NAME)]);
n_max = 10; % find n_max largest elements
%
season_diff.lon = lon;
season_diff.lat = lat;
residual_diff.lon = lon;
residual_diff.lat = lat;
season_diff.ref_method_name = ref_method_name;
residual_diff.ref_method_name = ref_method_name;
season_diff.method_name = METHOD_NAME;
residual_diff.method_name = METHOD_NAME;
season_diff.field_name = METHOD_NAME + "_" + ref_method_name;
residual_diff.field_name = METHOD_NAME + "_" + ref_method_name;
for k = 1:length(season_diff.method_name)
    method_name = season_diff.method_name(k);
    ref_method_name = season_diff.ref_method_name(k);
    field_name = method_name + "_" + ref_method_name;
    %
    season_diff.(field_name).max = nan(length(lon),length(lat));
    season_diff.(field_name).min = season_diff.(field_name).max;
    residual_diff.(field_name).max = season_diff.(field_name).max;
    residual_diff.(field_name).min = season_diff.(field_name).max;
    for i = 1:length(lon)
        for j = 1:length(lat)
            season_diff.(field_name).max(i,j) = max(ersst_v5.(method_name).season{i,j} - ersst_v5.(ref_method_name).season{i,j},[],"omitnan");
            season_diff.(field_name).min(i,j) = min(ersst_v5.(method_name).season{i,j} - ersst_v5.(ref_method_name).season{i,j},[],"omitnan");
            residual_diff.(field_name).max(i,j) = max(ersst_v5.(method_name).residue{i,j} - ersst_v5.(ref_method_name).residue{i,j},[],"omitnan");
            residual_diff.(field_name).min(i,j) = min(ersst_v5.(method_name).residue{i,j} - ersst_v5.(ref_method_name).residue{i,j},[],"omitnan");
        end
    end
    [season_diff.(field_name).max_diff_value,season_diff.(field_name).max_diff_linear_ind] = maxk(max(season_diff.(field_name).max(:),season_diff.(field_name).min(:), ...
        "omitnan","ComparisonMethod","abs"), ...
        n_max,"ComparisonMethod","abs");
    [season_diff.(field_name).max_diff_lon_ind,season_diff.(field_name).max_diff_lat_ind] = ind2sub(size(season_diff.(field_name).max),season_diff.(field_name).max_diff_linear_ind);
    [residual_diff.(field_name).max_diff_value,residual_diff.(field_name).max_diff_linear_ind] = maxk(max(residual_diff.(field_name).max(:),residual_diff.(field_name).min(:), ...
        "omitnan","ComparisonMethod","abs"), ...
        n_max,"ComparisonMethod","abs");
    [residual_diff.(field_name).max_diff_lon_ind,residual_diff.(field_name).max_diff_lat_ind] = ind2sub(size(residual_diff.(field_name).max),residual_diff.(field_name).max_diff_linear_ind);
end

%% additional

method_name = ["M1B","M1A","M1B","M1A","M1B","M2S"];
ref_method_name = ["M1A","M2S","M2S","M2A","M2A","M2A"];
n_max = 10; % find n_max largest elements
%
season_diff_ad.lon = lon;
season_diff_ad.lat = lat;
residual_diff_ad.lon = lon;
residual_diff_ad.lat = lat;
season_diff_ad.method_name = method_name;
season_diff_ad.ref_method_name = ref_method_name;
season_diff_ad.field_name = method_name + "_" + ref_method_name;
residual_diff_ad.method_name = method_name;
residual_diff_ad.ref_method_name = ref_method_name;
residual_diff_ad.field_name = method_name + "_" + ref_method_name;
%
for k = 1:length(season_diff_ad.method_name)
    method_name = season_diff_ad.method_name(k);
    ref_method_name = season_diff_ad.ref_method_name(k);
    field_name = method_name + "_" + ref_method_name;
    %
    season_diff_ad.(field_name).max = nan(length(lon),length(lat));
    season_diff_ad.(field_name).min = season_diff_ad.(field_name).max;
    residual_diff_ad.(field_name).max = season_diff_ad.(field_name).max;
    residual_diff_ad.(field_name).min = season_diff_ad.(field_name).max;
    for i = 1:length(lon)
        for j = 1:length(lat)
            season_diff_ad.(field_name).max(i,j) = max(ersst_v5.(method_name).season{i,j} - ersst_v5.(ref_method_name).season{i,j},[],"omitnan");
            season_diff_ad.(field_name).min(i,j) = min(ersst_v5.(method_name).season{i,j} - ersst_v5.(ref_method_name).season{i,j},[],"omitnan");
            residual_diff_ad.(field_name).max(i,j) = max(ersst_v5.(method_name).residue{i,j} - ersst_v5.(ref_method_name).residue{i,j},[],"omitnan");
            residual_diff_ad.(field_name).min(i,j) = min(ersst_v5.(method_name).residue{i,j} - ersst_v5.(ref_method_name).residue{i,j},[],"omitnan");
        end
    end
    %%% find max. diff. index
    [season_diff_ad.(field_name).max_diff_value,season_diff_ad.(field_name).max_diff_linear_ind] = maxk(max(season_diff_ad.(field_name).max(:),season_diff_ad.(field_name).min(:), ...
        "omitnan","ComparisonMethod","abs"), ...
        n_max,"ComparisonMethod","abs");
    [season_diff_ad.(field_name).max_diff_lon_ind,season_diff_ad.(field_name).max_diff_lat_ind] = ind2sub(size(season_diff_ad.(field_name).max),season_diff_ad.(field_name).max_diff_linear_ind);
    [residual_diff_ad.(field_name).max_diff_value,residual_diff_ad.(field_name).max_diff_linear_ind] = maxk(max(residual_diff_ad.(field_name).max(:),residual_diff_ad.(field_name).min(:), ...
        "omitnan","ComparisonMethod","abs"), ...
        n_max,"ComparisonMethod","abs");
    [residual_diff_ad.(field_name).max_diff_lon_ind,residual_diff_ad.(field_name).max_diff_lat_ind] = ind2sub(size(residual_diff_ad.(field_name).max),residual_diff_ad.(field_name).max_diff_linear_ind);
end

%% Create graph.

if ~create_fig_EN
    return;
end

%% Create figure: single station

[output_diff] = ersst_single_station_graph(ersst_v5,residual_diff,create_fig_EN,export_fig_EN);
[output_diff_ad] = ersst_single_station_graph(ersst_v5,residual_diff_ad,create_fig_EN,export_fig_EN);

%% Create figure: mean of annual cycle (season) and residual

for method_name = season_mean.method_name
    lon = season_mean.lon;
    lat = season_mean.lat;
    data1 = season_mean.(method_name);
    data2 = residual_mean.(method_name);
    title1 = sprintf("\\bf %s: Mean of annual cycle (seasonal component) and residual",METHOD_DISP_NAME(METHOD_NAME == method_name));
    title2 = title1;
    unit_name1 = "Mean of seasonal component (°C)";
    unit_name2 = "Mean of residual (°C)";
    filename = sprintf("ersst_v5\\ersst_v5_%s_mean_season_residual",METHOD_DISP_NAME(METHOD_NAME == method_name));
%     global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
    m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
end

%% Create figure: CVE, EV, RMSE, CC

for i = 1:length(METHOD_NAME)
    method_name = METHOD_NAME(i);
    % cross-validated root-mean-square error (CVE) (climatological mean to
    % raw data); variance explained (EV) by extracted climatological mean
    % of raw data.
    data1 = cell2mat(ersst_v5.(method_name).cm2raw_cvRMSE);
    data2 = cell2mat(ersst_v5.(method_name).cm2raw_EV)*100;
    title1 = sprintf("\\bf %s: Climatological mean to raw series",METHOD_DISP_NAME(i));
    title2 = title1;
    unit_name1 = "Cross-validated RMSE (°C)";
    unit_name2 = "Variance Explained (%)";
    filename = sprintf("ersst_v5\\ersst_v5_%s_cm2raw_CVE_EV",METHOD_DISP_NAME(i));
%     global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
    m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);

    % root-mean-square error (RMSE) of climatological mean to raw series;
    % Pearson linear correlation coefficient of climatological mean to raw
    % series.
    data1 = cell2mat(ersst_v5.(method_name).cm2raw_RMSE);
    data2 = cell2mat(ersst_v5.(method_name).cm2raw_CC);
    title1 = sprintf("\\bf %s: Climatological mean to raw series", METHOD_DISP_NAME(i));
    title2 = title1;
    unit_name1 = "RMSE (°C)";
    unit_name2 = "Corr. Coeff.";
    filename = sprintf("ersst_v5\\ersst_v5_%s_cm2raw_RMSE_CC",METHOD_DISP_NAME(i));
%     global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
    m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
end

%% Create figure: Diff. between method: aunnal cycle, residual

for i = 1:length(season_diff.method_name)
    method_name = season_diff.method_name(i);
    ref_method_name = season_diff.ref_method_name(i);
    field_name = season_diff_ad.field_name(i);
    if method_name == ref_method_name
        continue;
    end
    % seasonality difference from method * to reference method
    data1 = season_diff.(field_name).max;
    data2 = season_diff.(field_name).min;
    title1 = sprintf("\\bf Annual cycle: %s minus %s",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
    title2 = title1;
    unit_name1 = "Max. (°C)";
    unit_name2 = "Min. (°C)";
    filename = sprintf("ersst_v5\\ersst_v5_%s_minus_%s_season",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
%     global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
    m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);

    % residual difference from method * to reference method
    data1 = residual_diff.(field_name).max;
    data2 = residual_diff.(field_name).min;
    title1 = sprintf("\\bf Residual: %s minus %s",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
    title2 = title1;
    unit_name1 = "Max. (°C)";
    unit_name2 = "Min. (°C)";
    filename = sprintf("ersst_v5\\ersst_v5_%s_minus_%s_residual",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
%     global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
    m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
end

%% additional

for i = 1:length(season_diff_ad.method_name)
    method_name = season_diff_ad.method_name(i);
    ref_method_name = season_diff_ad.ref_method_name(i);
    field_name = season_diff_ad.field_name(i);
    if method_name == ref_method_name
        continue;
    end
    % seasonality difference from method * to reference method
    data1 = season_diff_ad.(field_name).max;
    data2 = season_diff_ad.(field_name).min;
    title1 = sprintf("\\bf Annual cycle: %s minus %s",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
    title2 = title1;
    unit_name1 = "Max. (°C)";
    unit_name2 = "Min. (°C)";
    filename = sprintf("ersst_v5\\ersst_v5_%s_minus_%s_season",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
%     global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
    m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);

    % residual difference from method * to reference method
    data1 = residual_diff_ad.(field_name).max;
    data2 = residual_diff_ad.(field_name).min;
    title1 = sprintf("\\bf Residual: %s minus %s",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
    title2 = title1;
    unit_name1 = "Max. (°C)";
    unit_name2 = "Min. (°C)";
    filename = sprintf("ersst_v5\\ersst_v5_%s_minus_%s_residual",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
%     global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
    m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
end

%% local functions

%% Initialize environment

function [] = init_env()
% Initialize environment
%
    % set up project directory
    if ~isfolder("..\doc\fig\test2\ersst_v5\")
        mkdir("..\doc\fig\test2\ersst_v5\");
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

%% global contour

function [] = global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_EN)
    arguments
        lon
        lat
        data1
        data2 = [];
        title1 = "\bf title1"
        title2 = "\bf title2"
        unit_name1 = "°C"
        unit_name2 = "°C"
        filename = "filename"
        export_EN = false;
    end
    
    %%%
    graph_res = 1000;
    
    figure('Name',title1)
    t_TCL = tiledlayout(1+~isempty(data2),1,"TileSpacing","compact","Padding","compact");
    % 1.
    t_axes = nexttile(t_TCL,1);
    pcolor(t_axes,lon,lat,data1.');
    shading(t_axes,"interp");
    hold on
    [C,h] = contour(t_axes,lon,lat,data1.','LineWidth',0.2,'LineColor','black','ShowText','off');
%     borders('countries','center',180,'color',rgb('gray'))
    hold off
    set(t_axes,"TickLabelInterpreter","tex",'XAxisLocation','top',"TickDir","out",'YDir','normal','Box','off','FontName','Times New Roman','FontSize',9);
    clabel(C,h,"Interpreter",'tex','FontSize',6,'FontName','Times New Roman')
    % BEGIN patch
    cl = prctile(data1,[1,99],"all");
    caxis(t_axes,cl);
    cl = caxis;
    pivot_ = 0;
    if (cl(1)*cl(2)>=0)
        pivot_ = prctile(data1,50,"all");
    end
    % END patch
    colormap(t_axes,cmocean('balance','pivot',pivot_))
    cb = colorbar(t_axes,"eastoutside","TickLabelInterpreter","tex",'FontName','Times New Roman');
    set(cb.Label,"String",unit_name1,"Interpreter","tex",'FontName','Times New Roman')
    xticks(t_axes,-180:45:360)
    xticklabels(t_axes,[string(180:-45:45)+"°W","0°",string(45:45:135)+"°E","180°",string(135:-45:0)+"°W"])
    yticks(t_axes,-90:30:90)
    yticklabels(t_axes,[string(90:-30:30)+"°S","0°",string(30:30:90)+"°N"])
    %
    title(t_axes,sprintf("%s",title1),'Interpreter','tex','FontSize',10,'FontName','Times New Roman');
    %
    if isempty(data2)
        if export_EN
            exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",filename),'Resolution',1000,'ContentType','auto','BackgroundColor','none','Colorspace','rgb') 
        end
        return;
    end

    % 2.
    t_axes = nexttile(t_TCL,2);
    pcolor(t_axes,lon,lat,data2.');
    shading(t_axes,"interp");
    hold on
    [C,h] = contour(t_axes,lon,lat,data2.','LineWidth',0.2,'LineColor','black','ShowText','off');
%     borders('countries','center',180,'color',rgb('gray'))
    hold off
    set(t_axes,"TickLabelInterpreter","tex",'XAxisLocation','top',"TickDir","out",'YDir','normal','Box','off','FontName','Times New Roman','FontSize',9);
    clabel(C,h,"Interpreter",'tex','FontSize',6,'FontName','Times New Roman')
    % BEGIN patch
    cl = prctile(data2,[1,99],"all");
    caxis(t_axes,cl);
    cl = caxis;
    pivot_ = 0;
    if (cl(1)*cl(2)>=0)
        pivot_ = prctile(data2,50,"all");
    end
    % END patch
    colormap(t_axes,cmocean('balance','pivot',pivot_))
    cb = colorbar(t_axes,"eastoutside","TickLabelInterpreter","tex",'FontName','Times New Roman');
    set(cb.Label,"String",unit_name2,"Interpreter","tex",'FontName','Times New Roman')
    xticks(t_axes,-180:45:360)
    xticklabels(t_axes,{})
    yticks(t_axes,-90:30:90)
    yticklabels(t_axes,[string(90:-30:30)+"°S","0°",string(30:30:90)+"°N"])
    %
    title(t_axes,sprintf("%s",title2),'Interpreter','tex','FontSize',10,'FontName','Times New Roman');
    
    if export_EN
        exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",filename),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb') 
    end
    return;
end

%% M_Map global contour

function [] = m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN)
    arguments
        lon
        lat
        data1
        data2 = [];
        title1 = "\bf title1"
        title2 = "\bf title2"
        unit_name1 = "°C"
        unit_name2 = "°C"
        filename = sprintf("ersst_v5\\untitled");
        export_fig_EN = false;
    end
    
    %%%
    graph_res = 1000;
    
    %%%
    persistent gshhs_init
    if isempty(gshhs_init)
        gshhs_init = false;
        m_proj('Miller','lon',[0,360],'lat',[-90,90])  % set up projection parameters

        % This command does not draw anything - it merely processes the 
        % high-resolution database using the current projection parameters 
        % to generate a smaller coastline file called "gumby"
        if gshhs_init
            gsshs_global_path = '..\bin\test2\global';
            m_gshhs('lc','save',gsshs_global_path);
        end
        if ~isfolder("..\doc\fig\test2\ersst_v5\")
            mkdir("..\doc\fig\test2\ersst_v5\");
        end
        fprintf("gshhs_init = %d\n",gshhs_init);
    end
    
    figure('Name',title1)
    t_TCL = tiledlayout(1,1+~isempty(data2),"TileSpacing","tight","Padding","compact");
    % 1.
    t_axes = nexttile(t_TCL,1);
    m_pcolor(lon,lat,data1.');
%     m_pcolor(lon-360,lat,data1.');
    shading(t_axes,"interp");
    m_coast('patch',[0.98 0.98 0.98],'EdgeColor',[0.2 0.2 0.2]);
%     m_grid('XTick',-180:45:180,'YTick',-90:30:90);
    m_grid('XAxisLocation','top','FontName','Times New Roman','FontSize',9);
    hold on
    [C,h] = m_contour(lon,lat,data1.','LineWidth',0.2,'LineColor','black','ShowText','off');
    hold off
    clabel(C,h,"Interpreter",'tex','FontSize',6,'FontName','Times New Roman');
    set(t_axes,"TickLabelInterpreter","tex",'XAxisLocation','top',"TickDir","out",'YDir','normal','Box','off','FontName','Times New Roman','FontSize',9);
    % BEGIN patch
    cl = prctile(data1,[1,99],"all");
    caxis(t_axes,cl);
    cl = caxis;
    pivot_ = 0;
    if (cl(1)*cl(2)>=0)
        pivot_ = prctile(data1,50,"all");
    end
    % END patch
    colormap(t_axes,cmocean('balance','pivot',pivot_))
    cb = colorbar(t_axes,"southoutside","TickLabelInterpreter","tex",'FontName','Times New Roman');
    set(cb.Label,"String",unit_name1,"Interpreter","tex",'FontName','Times New Roman')
    %
    if title1 == title2
        title(t_TCL,sprintf("%s\n",title1),'Interpreter','tex','FontSize',10,'FontName','Times New Roman');
    else
        title(t_axes,sprintf("%s",title1),'Interpreter','tex','FontSize',10,'FontName','Times New Roman');
    end
    %
    if isempty(data2)
        if export_fig_EN
            exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",filename),'Resolution',1000,'ContentType','auto','BackgroundColor','none','Colorspace','rgb') 
        end
        return;
    end

    % 2.
    t_axes = nexttile(t_TCL,2);
    m_pcolor(lon,lat,data2.');
%     m_pcolor(lon-360,lat,data2.');
    shading(t_axes,"interp");
    m_coast('patch',[0.98 0.98 0.98],'EdgeColor',[0.2 0.2 0.2]);
%     m_grid('XTick',-180:45:180,'YTick',-90:30:90);
    m_grid('XAxisLocation','top','YTickLabels',[],'FontName','Times New Roman','FontSize',9);
    hold on
    [C,h] = m_contour(lon,lat,data2.','LineWidth',0.2,'LineColor','black','ShowText','off');
    hold off
    set(t_axes,"TickLabelInterpreter","tex",'XAxisLocation','top',"TickDir","out",'YDir','normal','Box','off','FontName','Times New Roman','FontSize',9);
    clabel(C,h,"Interpreter",'tex','FontSize',6,'FontName','Times New Roman')
    % BEGIN patch
    cl = prctile(data2,[1,99],"all");
    caxis(t_axes,cl);
    cl = caxis;
    pivot_ = 0;
    if (cl(1)*cl(2)>=0)
        pivot_ = prctile(data2,50,"all");
    end
    % END patch
    colormap(t_axes,cmocean('balance','pivot',pivot_))
    cb = colorbar(t_axes,"southoutside","TickLabelInterpreter","tex",'FontName','Times New Roman');
    set(cb.Label,"String",unit_name2,"Interpreter","tex",'FontName','Times New Roman')
    %
    if title2 ~= title1
        title(t_axes,sprintf("%s",title2),'Interpreter','tex','FontSize',10,'FontName','Times New Roman');
    end
    if export_fig_EN
        exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",filename),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb') 
    end
    return;
end

%% Single station summary and plot

function [output_diff] = ersst_single_station(ersst_v5,lon,lat,m_1_name,m_ref_name,method_disp_set,fig_name,title_str,file_name,create_fig_EN,export_fig_EN)
%ersst_single_station - For single station data, solve for the differences between methods and plot
%
% Syntax: 
%
% For single station data, solve for the differences between methods and
% plot them. Calculate the difference between two of all methods, and show
% the output of the two methods specified in the plot.
    arguments
        ersst_v5
        lon = 0;
        lat = 0;
        m_1_name = "M1A";   % method-1 show in the plot
        m_ref_name = "M1B"; % method-ref show in the plot
        method_disp_set = [m_1_name,m_ref_name];
        fig_name = sprintf("ersst_v5_%gN_%gE_%s_%s",lat,lon,m_1_name,m_ref_name);
        title_str = sprintf("\\bf ERSST v5 (1902-2021) %g°N %g°E",lat,lon);
        file_name = sprintf("ersst_v5\\%s",fig_name);
        create_fig_EN = true;
        export_fig_EN = false;
    end

    %% prepare
    
    [~,lon_ind] = min(lon - ersst_v5.lon,[],'omitnan','ComparisonMethod','abs');
    [~,lat_ind] = min(lat - ersst_v5.lat,[],'omitnan','ComparisonMethod','abs');
    t = ersst_v5.t;
    x.raw = squeeze(ersst_v5.raw(lon_ind,lat_ind,:));
    for method_name = ersst_v5.METHOD_NAME
        for component_name = ["trend","season","residue"]
            output.(method_name).(component_name) = ersst_v5.(method_name).(component_name){lon_ind,lat_ind};
        end
    end
    M_1_DISP_NAME = ersst_v5.METHOD_DISP_NAME(ersst_v5.METHOD_NAME == m_1_name);
    M_REF_DISP_NAME = ersst_v5.METHOD_DISP_NAME(ersst_v5.METHOD_NAME == m_ref_name);
    output_diff.lat = ersst_v5.lat(lat_ind);
    output_diff.lon = ersst_v5.lon(lon_ind);
    [output_diff.lat_str,output_diff.lon_str] = lat_lon2str(output_diff.lon,output_diff.lat);

    %%% diff: summary
    k_max = 10; % Find k largest (smallest) elements of array
    for i = 1:length(ersst_v5.METHOD_NAME)
        method_name = ersst_v5.METHOD_NAME(i);
        for j = i+1:length(ersst_v5.METHOD_NAME)
            ref_method_name = ersst_v5.METHOD_NAME(j);
            for component_name = ["trend","season","residue"]
                field_name = method_name + "_" + ref_method_name + "_" + component_name;
                m_minus_mref = ersst_v5.(method_name).(component_name){lon_ind,lat_ind} - ersst_v5.(ref_method_name).(component_name){lon_ind,lat_ind};
                [output_diff.(field_name).maxk,output_diff.(field_name).maxk_ind] = maxk(m_minus_mref,k_max);
                [output_diff.(field_name).mink,output_diff.(field_name).mink_ind] = mink(m_minus_mref,k_max);
                output_diff.(field_name).RMSE = sqrt(mean(m_minus_mref.^2,"omitnan"));
                output_diff.(field_name).MAE = mean(abs(m_minus_mref),"omitnan");
            end
        end
    end
    M_FIELD_NAME = m_1_name + "_" + m_ref_name;
    if ~isfield(output_diff, M_FIELD_NAME+"_trend")
        % swap m_1 and m_ref, update M_FIELD_NAME
        m_1_name_old = m_1_name;
        m_1_name = m_ref_name;
        m_ref_name = m_1_name_old;
        M_FIELD_NAME = m_1_name + "_" + m_ref_name;
    end

    %% create figure

    if ~create_fig_EN
        return;
    end

    marker_size = 0.58;
    graph_res = 1000;

    ticks_x = t(1:240:end);
    label_x = floor(ticks_x/12) + str2double(extractBetween(ersst_v5.start_month,1,4));

    figure('Name',fig_name)
    t_TCL = tiledlayout(4,1,"TileSpacing","tight","Padding","compact");
    
    method_name_set = ["M1A","M1B","M2","M2A","M2S","M3L","M3Q"];
    line_spec_set = ["-","-",":","--","-.","x","+"];
    
    % 1. raw & extracted trend (selected)
    t_axes = nexttile(t_TCL,1);
    plot(t_axes,t,x.raw,'-',"DisplayName",'raw SST');
    hold on
    for i = 1:length(method_name_set)
        method_name = method_name_set(i);
        if ismember(method_name,method_disp_set)
            plot(t_axes,t,output.(method_name).trend,line_spec_set(i),"DisplayName",ersst_v5.METHOD_DISP_NAME(ersst_v5.METHOD_NAME==method_name),'MarkerSize',marker_size);
        end
    end
    hold off
    set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','in','XTickLabel',{},'XLimitMethod','tight');
    xticks(t_axes,ticks_x);
    xticklabels(t_axes,{})
    ylabel(t_axes,"SST (℃)","FontSize",10)

    % 2. extracted trend (selected)
    
    output_diff_field_name = M_FIELD_NAME+"_trend";
    t_axes = nexttile(t_TCL,2);
    % plot(t_axes,t,x.raw-x.season,'-',"DisplayName",'ideal deseason');
    hold on
    for i = 1:length(method_name_set)
        method_name = method_name_set(i);
        if ismember(method_name,method_disp_set)
            plot(t_axes,t,output.(method_name).trend,line_spec_set(i),"DisplayName",ersst_v5.METHOD_DISP_NAME(ersst_v5.METHOD_NAME==method_name),'MarkerSize',marker_size);
        end
    end
    set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','in','XTickLabel',{},'XLimitMethod','tight');
    legend(t_axes,'box','off','Orientation','vertical','NumColumns',4,'Location','best');
    xticks(t_axes,ticks_x);
    xticklabels(t_axes,{});
    ylabel(t_axes,"Trend (℃)","FontSize",10);
    title(sprintf("\\bf Trend. \\rm (%s minus %s: %.2e @ {\\it t} = %d, %.2e @ {\\it t} = %d)", ...
        M_1_DISP_NAME,M_REF_DISP_NAME, ...
        output_diff.(output_diff_field_name).maxk(1),output_diff.(output_diff_field_name).maxk_ind(1), ...
        output_diff.(output_diff_field_name).mink(1),output_diff.(output_diff_field_name).mink_ind(1)), ...
        "FontSize",10,'FontName','Times New Roman');

    % 3. extracted residue (selected)

    output_diff_field_name = M_FIELD_NAME+"_residue";
    t_axes = nexttile(t_TCL,3);
    % plot(t_axes,t,x.residue,'-',"DisplayName",'ideal deseason');
    hold on
    for i = 1:length(method_name_set)
        method_name = method_name_set(i);
        if ismember(method_name,method_disp_set)
            plot(t_axes,t,output.(method_name).residue,line_spec_set(i),"DisplayName",ersst_v5.METHOD_DISP_NAME(ersst_v5.METHOD_NAME==method_name),'MarkerSize',marker_size);
        end
    end
    set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','in','XLimitMethod','tight');
    % legend(t_axes,'boxoff');
    xticks(t_axes,ticks_x);
    xticklabels(t_axes,label_x)
    % xlabel(t_axes,"year","FontSize",10)
    ylabel(t_axes,"Residual (℃)","FontSize",10)
    title(sprintf("\\bf Residual. \\rm (%s minus %s: %.2e @ {\\it t} = %d, %.2e @ {\\it t} = %d)", ...
        M_1_DISP_NAME,M_REF_DISP_NAME, ...
        output_diff.(output_diff_field_name).maxk(1),output_diff.(output_diff_field_name).maxk_ind(1), ...
        output_diff.(output_diff_field_name).mink(1),output_diff.(output_diff_field_name).mink_ind(1)), ...
        "FontSize",10,'FontName','Times New Roman');

    % 4. extracted annual cycle (seasonal component) (several)

    output_diff_field_name = M_FIELD_NAME+"_season";
    t_axes = nexttile(t_TCL,4);
    % plot(t_axes,t,x.raw-x.trend,'-',"DisplayName",'ideal detrended');
    hold on
    for i = 1:length(method_name_set)
        method_name = method_name_set(i);
        if ismember(method_name,method_disp_set)
            plot(t_axes,t,output.(method_name).season,line_spec_set(i),"DisplayName",ersst_v5.METHOD_DISP_NAME(ersst_v5.METHOD_NAME==method_name),'MarkerSize',marker_size);
        end
    end
    set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','in','XLimitMethod','tight');
    xlim(t_axes,[1,24])
    legend(t_axes,'boxoff');
    xlabel(t_axes,"Months","FontSize",10)
    ylabel(t_axes,"Annual Cycle (℃)","FontSize",10)
    title(sprintf("\\bf Annual Cycle. \\rm (%s minus %s: %.2e @ {\\it t} = %d, %.2e @ {\\it t} = %d)", ...
        M_1_DISP_NAME,M_REF_DISP_NAME, ...
        output_diff.(output_diff_field_name).maxk(1),output_diff.(output_diff_field_name).maxk_ind(1), ...
        output_diff.(output_diff_field_name).mink(1),output_diff.(output_diff_field_name).mink_ind(1)), ...
        "FontSize",10,'FontName','Times New Roman');
    %
    title(t_TCL,title_str,"FontSize",10,'FontName','Times New Roman')

    if export_fig_EN
        exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",file_name),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb') 
    end

    return;
end

%% 

function [output_diff] = ersst_single_station_graph(ersst_v5,diff_struct,create_fig_EN,export_fig_EN)
%ersst_single_station_graph - Draw, iterating through all "method pairs" in the struct. 
%
% Syntax: 
%
% Will call function `ersst_single_station`.
    arguments
        ersst_v5
        diff_struct
        create_fig_EN = true;
        export_fig_EN = false;
    end
    output_diff = cell(length(diff_struct.method_name),1);
    for i = 1:length(diff_struct.method_name)
        m_1_name = diff_struct.method_name(i);
        m_ref_name = diff_struct.ref_method_name(i);
        field_name = m_1_name + "_" + m_ref_name;
        method_disp_set = [m_1_name,m_ref_name];
        lon_ss = diff_struct.lon(diff_struct.(field_name).max_diff_lon_ind);
        lat_ss = diff_struct.lat(diff_struct.(field_name).max_diff_lat_ind);
        fig_name = sprintf("ersst_v5_%gN_%gE_%s_%s",lat_ss(1),lon_ss(1),m_1_name,m_ref_name);
        [lat_str,lon_str] = lat_lon2str(lat_ss(1),lon_ss(1));
        title_str = sprintf("\\bf ERSST v5 (1902-2021) %s %s",lat_str,lon_str);
        file_name = sprintf("ersst_v5\\%s",fig_name);
        [output_diff{i}] = ersst_single_station(ersst_v5,lon_ss(1),lat_ss(1),m_1_name,m_ref_name,method_disp_set,fig_name,title_str,file_name,create_fig_EN,export_fig_EN);
    end

    return;
end

%% lat (deg N), lon (deg E) -> lat str (xx °N/S), lon str (xx °E/W)
function [lat_str,lon_str] = lat_lon2str(lat,lon)
%lat_lon2str - Description
%
% Syntax: 
%
% Long description
    arguments
        lat = -16; % [deg N]
        lon = 190; % [deg E]
    end

    if lat > 0 && lat <= 90
        lat_str = num2str(lat)+"°N";
    elseif lat < 0
        lat_str = num2str(-lat)+"°S";
    elseif lat == 0
        lat_str = "0°";
    else
        lat_str = "INVALID LAT!";
    end

    if lon > 180
        lon_str = num2str(360 - lon) + "°W";
    elseif lon == 180
        lon_str = "180°";
    elseif lon < 180 && lon > 0
        lon_str = num2str(lon) + "°E";
    elseif lon == 0
        lon_str = "0°";
    elseif lon < 0
        lon_str = num2str(-lon) + "°W";
    else
        lat_str = "INVALID LON!";
    end

    return;
end
    