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

%%
mat_file_path = "../bin/test2/ersst_v5.mat";
% mat_file = matfile(mat_file_path);
% ersst_v5 = mat_file.ersst_v5;
load(mat_file_path,'ersst_v5');

%%
export_EN = true;
METHOD_NAME = ersst_v5.METHOD_NAME;
METHOD_DISP_NAME = ersst_v5.METHOD_DISP_NAME;
INDICES_REAL_NAME = ersst_v5.INDICES_NAME;
INDICES_VAR_TYPES = ersst_v5.INDICES_VAR_TYPES;
t = ersst_v5.t;
lon = ersst_v5.lon;
lat = ersst_v5.lat;

%% Max. Diff.

season_diff = struct;
residual_diff = season_diff;
REF_METHOD_NAME = "M1A";
for method_name = METHOD_NAME
    season_diff.(method_name).max = nan(length(lon),length(lat));
    season_diff.(method_name).min = season_diff.(method_name).max;
    residual_diff.(method_name).min = season_diff.(method_name).max;
    residual_diff.(method_name).min = season_diff.(method_name).max;
    for i = 1:length(lon)
        for j = 1:length(lat)
            season_diff.(method_name).max(i,j) = max(ersst_v5.(method_name).season{i,j} - ersst_v5.(REF_METHOD_NAME).season{i,j},[],"omitnan");
            season_diff.(method_name).min(i,j) = min(ersst_v5.(method_name).season{i,j} - ersst_v5.(REF_METHOD_NAME).season{i,j},[],"omitnan");
            residual_diff.(method_name).max(i,j) = max(ersst_v5.(method_name).residue{i,j} - ersst_v5.(REF_METHOD_NAME).residue{i,j},[],"omitnan");
            residual_diff.(method_name).min(i,j) = min(ersst_v5.(method_name).residue{i,j} - ersst_v5.(REF_METHOD_NAME).residue{i,j},[],"omitnan");
        end
    end
end

%% Create figure: CVE, EV, RMSE, CC

for i = 1:length(METHOD_NAME)
    % cross-validated root-mean-square error (CVE) (climatological mean to
    % raw data); variance explained (EV) by extracted climatological mean
    % of raw data.
    method_name = METHOD_NAME(i);
    data1 = cell2mat(ersst_v5.(method_name).cm2raw_cvRMSE);
    data2 = cell2mat(ersst_v5.(method_name).cm2raw_EV);
    title1 = sprintf("\\bf %s: Climatological mean to raw series",METHOD_DISP_NAME(i));
    title2 = "";
    unit_name1 = "Cross-validated RMSE (°C)";
    unit_name2 = "Variance Explained";
    filename = sprintf("ersst_v5\\ersst_v5_%s_cm2raw_CVE_EV",METHOD_DISP_NAME(i));
    global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,1);

    % root-mean-square error (RMSE) of climatological mean to raw series;
    % Pearson linear correlation coefficient of climatological mean to raw
    % series.
    method_name = METHOD_NAME(i);
    data1 = cell2mat(ersst_v5.(method_name).cm2raw_RMSE);
    data2 = cell2mat(ersst_v5.(method_name).cm2raw_CC);
    title1 = sprintf("\\bf %s: Climatological mean to raw series", METHOD_DISP_NAME(i));
    title2 = "";
    unit_name1 = "RMSE (°C)";
    unit_name2 = "Corr. Coeff.";
    filename = sprintf("ersst_v5\\ersst_v5_%s_cm2raw_RMSE_CC",METHOD_DISP_NAME(i));
    global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,1);
end

%% Create figure: Diff. between method: aunnal cycle, residual

for i = 1:length(METHOD_NAME)
    if METHOD_NAME(i) == REF_METHOD_NAME
        continue;
    end
    % seasonality difference from method * to reference method
    method_name = METHOD_NAME(i);
    data1 = season_diff.(method_name).max;
    data2 = season_diff.(method_name).min;
    title1 = sprintf("\\bf Annual cycle: %s minus %s",METHOD_DISP_NAME(i),METHOD_DISP_NAME(METHOD_NAME==REF_METHOD_NAME));
    title2 = "";
    unit_name1 = "Max. (°C)";
    unit_name2 = "Min. (°C)";
    filename = sprintf("ersst_v5\\ersst_v5_%s_diff_season",METHOD_DISP_NAME(i));
    global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,1);

    % residual difference from method * to reference method
    method_name = METHOD_NAME(i);
    data1 = residual_diff.(method_name).max;
    data2 = residual_diff.(method_name).min;
    title1 = sprintf("\\bf Residual: %s minus %s",METHOD_DISP_NAME(i),METHOD_DISP_NAME(METHOD_NAME==REF_METHOD_NAME));
    title2 = "";
    unit_name1 = "Max. (°C)";
    unit_name2 = "Min. (°C)";
    filename = sprintf("ersst_v5\\ersst_v5_%s_diff_residual",METHOD_DISP_NAME(i));
    global_map(lon,lat,data1,data2,title1,title2,unit_name1,unit_name2,filename,1);
end

%% global contour

%% Fig.1(a) global trend: Algorithm A

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
    
    %%%
    persistent gshhs_init
    if isempty(gshhs_init)
        gshhs_init = 1;
        m_proj('Equidistant Cylindrical','lat',[-90 90],'long',[-180 180])  % set up projection parameters

        % This command does not draw anything - it merely processes the 
        % high-resolution database using the current projection parameters 
        % to generate a smaller coastline file called "gumby"
        m_gshhs('lc','save','global');
        fprintf("gshhs_init = %d\n",gshhs_init);
    end
    
    figure('Name',title1)
    t_TCL = tiledlayout(1+~isempty(data2),1,"TileSpacing","compact","Padding","tight");
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
%     m_proj('Equidistant Cylindrical','lat',[-90 90],'long',[0 360]); %投影方式及绘图范围设定
%     m_gshhs('lc','patch',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]); %线条及色块颜色设定
%     m_usercoast('global','patch',[0.98 0.98 0.98],'EdgeColor',[0.2 0.2 0.2]);
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
