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
export_fig_EN = true;
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
%
season_diff.ref_method_name = ref_method_name;
residual_diff.ref_method_name = ref_method_name;
season_diff.method_name = METHOD_NAME;
residual_diff.method_name = METHOD_NAME;
for k = 1:length(season_diff.method_name)
    method_name = season_diff.method_name(k);
    ref_method_name = season_diff.ref_method_name(k);
    %
    season_diff.(method_name).max = nan(length(lon),length(lat));
    season_diff.(method_name).min = season_diff.(method_name).max;
    residual_diff.(method_name).max = season_diff.(method_name).max;
    residual_diff.(method_name).min = season_diff.(method_name).max;
    for i = 1:length(lon)
        for j = 1:length(lat)
            season_diff.(method_name).max(i,j) = max(ersst_v5.(method_name).season{i,j} - ersst_v5.(ref_method_name).season{i,j},[],"omitnan");
            season_diff.(method_name).min(i,j) = min(ersst_v5.(method_name).season{i,j} - ersst_v5.(ref_method_name).season{i,j},[],"omitnan");
            residual_diff.(method_name).max(i,j) = max(ersst_v5.(method_name).residue{i,j} - ersst_v5.(ref_method_name).residue{i,j},[],"omitnan");
            residual_diff.(method_name).min(i,j) = min(ersst_v5.(method_name).residue{i,j} - ersst_v5.(ref_method_name).residue{i,j},[],"omitnan");
        end
    end
end

%% additional

method_name = ["M1B","M1A","M1B","M1A","M1B","M2S"];
ref_method_name = ["M1A","M2S","M2S","M2A","M2A","M2A"];
%
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
end

%% Create graph.

if ~create_fig_EN
    return;
end

%% Create figure: mean of annual cycle (season) and residual

for method_name = season_mean.method_name
    lon = season_mean.lon;
    lat = season_mean.lat;
    data1 = season_mean.(method_name);
    data2 = residual_mean.(method_name);
    title1 = sprintf("\\bf %s: Mean of annual cycle (season component) and residual",METHOD_DISP_NAME(METHOD_NAME == method_name));
    title2 = title1;
    unit_name1 = "Mean of season component (°C)";
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
    if method_name == ref_method_name
        continue;
    end
    % seasonality difference from method * to reference method
    data1 = season_diff.(method_name).max;
    data2 = season_diff.(method_name).min;
    title1 = sprintf("\\bf Annual cycle: %s minus %s",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
    title2 = title1;
    unit_name1 = "Max. (°C)";
    unit_name2 = "Min. (°C)";
    filename = sprintf("ersst_v5\\ersst_v5_%s_minus_%s_season",METHOD_DISP_NAME(METHOD_NAME==method_name),METHOD_DISP_NAME(METHOD_NAME==ref_method_name));
%     global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);
    m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_fig_EN);

    % residual difference from method * to reference method
    data1 = residual_diff.(method_name).max;
    data2 = residual_diff.(method_name).min;
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

function [] = m_global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,export_EN)
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
        if export_EN
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
    if export_EN
        exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",filename),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb') 
    end
    return;
end
