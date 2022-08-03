%% test2_ideal_postproc.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-07-28
% Last modified: 2022-08-

%% Initialize project

clc; clear; close all
init_env();

%%
mat_file_path = "../bin/test2/ideal_summary.mat";
load(mat_file_path,'ideal_summary');

%%
create_fig_EN = false;
export_fig_EN = true;
METHOD_NAME = ideal_summary.METHOD_NAME;
METHOD_DISP_NAME = ideal_summary.METHOD_DISP_NAME;
INDICES_REAL_NAME = ideal_summary.INDICES_NAME;
INDICES_VAR_TYPES = ideal_summary.INDICES_VAR_TYPES;
t = ideal_summary.t;
case_num = ideal_summary.case_num;

%% Max. Diff.

season_diff.method_name = [METHOD_NAME, ...
                   "M1B","M1A","M1B","M1A","M1B","M2S","Ssa"];
season_diff.ref_method_name = [repmat("M2",[1,length(METHOD_NAME)]), ...
                   "M1A","M2S","M2S","M2A","M2A","M2A","Ssm"];
season_diff.indices_name = ["max","min","MaxAbs","RMSE","MAE","ME"];
season_diff.indices_disp_name_short = ["Max.Err.","Min.Err.","Max.Abs.Err.","RMSE","Mean.Abs.Err.","Mean.Err."];
season_diff.indices_unit_name = repmat("°C",size(season_diff.indices_name));
n_max = 10; % find n_max largest elements
%
season_diff.case_num = case_num;
season_diff.field_name = season_diff.method_name + "_" + season_diff.ref_method_name;
residual_diff = season_diff;
trend_diff = season_diff;
for k = 1:length(season_diff.method_name)
    method_name = season_diff.method_name(k);
    ref_method_name = season_diff.ref_method_name(k);
    field_name = method_name + "_" + ref_method_name;
    % pre-allocate memory
    season_diff.(field_name).max = nan(length(season_diff.case_num),1);
    season_diff.(field_name).min = season_diff.(field_name).max;
    season_diff.(field_name).MaxAbs = season_diff.(field_name).max;
    season_diff.(field_name).RMSE = season_diff.(field_name).max;
    season_diff.(field_name).MAE = season_diff.(field_name).max;
    season_diff.(field_name).ME = season_diff.(field_name).max;
    residual_diff.(field_name) = season_diff.(field_name);
    trend_diff.(field_name) = season_diff.(field_name);
    for i = 1:length(residual_diff.case_num)
        % season
        season_error = ideal_summary.(method_name).season{i,1} - ideal_summary.(ref_method_name).season{i,1};
        season_diff.(field_name).max(i,1) = max(season_error,[],"omitnan");
        season_diff.(field_name).min(i,1) = min(season_error,[],"omitnan");
        season_diff.(field_name).MaxAbs(i,1) = max(abs(season_error),[],"omitnan");
        season_diff.(field_name).RMSE(i,1) = sqrt(mean(season_error.^2,"omitnan"));
        season_diff.(field_name).MAE(i,1) = mean(abs(season_error),"omitnan");
        season_diff.(field_name).ME(i,1) = mean(season_error,"omitnan");
        % residual
        residual_error = ideal_summary.(method_name).residual{i,1} - ideal_summary.(ref_method_name).residual{i,1};
        residual_diff.(field_name).max(i,1) = max(residual_error,[],"omitnan");
        residual_diff.(field_name).min(i,1) = min(residual_error,[],"omitnan");
        residual_diff.(field_name).MaxAbs(i,1) = max(abs(residual_error),[],"omitnan");
        residual_diff.(field_name).RMSE(i,1) = sqrt(mean(residual_error.^2,"omitnan"));
        residual_diff.(field_name).MAE(i,1) = mean(abs(residual_error),"omitnan");
        residual_diff.(field_name).ME(i,1) = mean(residual_error,"omitnan");
        % trend
        trend_error = ideal_summary.(method_name).trend{i,1} - ideal_summary.(ref_method_name).trend{i,1};
        trend_diff.(field_name).max(i,1) = max(trend_error,[],"omitnan");
        trend_diff.(field_name).min(i,1) = min(trend_error,[],"omitnan");
        trend_diff.(field_name).MaxAbs(i,1) = max(abs(trend_error),[],"omitnan");
        trend_diff.(field_name).RMSE(i,1) = sqrt(mean(trend_error.^2,"omitnan"));
        trend_diff.(field_name).MAE(i,1) = mean(abs(trend_error),"omitnan");
        trend_diff.(field_name).ME(i,1) = mean(trend_error,"omitnan");
    end
    [season_diff.(field_name).max_diff_value,season_diff.(field_name).max_diff_linear_ind] = maxk(max(season_diff.(field_name).max(:),season_diff.(field_name).min(:), ...
        "omitnan","ComparisonMethod","abs"), ...
        n_max,"ComparisonMethod","abs");
    [season_diff.(field_name).max_diff_case_num,season_diff.(field_name).ShouldBeOnes] = ind2sub(size(season_diff.(field_name).max),season_diff.(field_name).max_diff_linear_ind);
    [residual_diff.(field_name).max_diff_value,residual_diff.(field_name).max_diff_linear_ind] = maxk(max(residual_diff.(field_name).max(:),residual_diff.(field_name).min(:), ...
        "omitnan","ComparisonMethod","abs"), ...
        n_max,"ComparisonMethod","abs");
    [residual_diff.(field_name).max_diff_case_num,residual_diff.(field_name).ShouldBeOnes] = ind2sub(size(residual_diff.(field_name).max),residual_diff.(field_name).max_diff_linear_ind);
    [trend_diff.(field_name).max_diff_value,trend_diff.(field_name).max_diff_linear_ind] = maxk(max(trend_diff.(field_name).max(:),trend_diff.(field_name).min(:), ...
        "omitnan","ComparisonMethod","abs"), ...
        n_max,"ComparisonMethod","abs");
    [trend_diff.(field_name).max_diff_case_num,trend_diff.(field_name).ShouldBeOnes] = ind2sub(size(trend_diff.(field_name).max),trend_diff.(field_name).max_diff_linear_ind);
end

%% Create graph.

if ~create_fig_EN
    return;
end

%% Create figure: single station

[output_diff_residual] = ideal_single_case_graph(ideal_summary,residual_diff,"residual",create_fig_EN,export_fig_EN);
[output_diff_season] = ideal_single_case_graph(ideal_summary,season_diff,"season",create_fig_EN,export_fig_EN);
[output_diff_trend] = ideal_single_case_graph(ideal_summary,season_diff,"trend",create_fig_EN,export_fig_EN);

%%

ideal_single_case(ideal_summary,8,"M1A","M2A",["M1A","M2A"],"none");

%% Create text: Diff. between method: aunnal cycle, residual

date_str = datetime('now','TimeZone','local','Format','yyyyMMdd_HHmm');
file_name = sprintf("..\\doc\\fig\\test2\\ideal_methods_compare_%s.txt",date_str);
fileID = fopen(file_name,'a');
fprintf(fileID,"Create time: %s\n",date_str);
% season
descrip_str = "Difference between extracted seasonal component (annual cycle).";
component_disp_name = "season";
ideal_diff_txt_gen(season_diff,fileID,descrip_str,component_disp_name,METHOD_NAME,METHOD_DISP_NAME);
% residual
descrip_str = "Difference between extracted residual component.";
component_disp_name = "residual";
ideal_diff_txt_gen(residual_diff,fileID,descrip_str,component_disp_name,METHOD_NAME,METHOD_DISP_NAME);
% trend
descrip_str = "Difference between extracted trend component.";
component_disp_name = "trend";
ideal_diff_txt_gen(trend_diff,fileID,descrip_str,component_disp_name,METHOD_NAME,METHOD_DISP_NAME);
%
fclose(fileID);

%% local functions

%% Initialize environment

function [] = init_env()
% Initialize environment
%
    % set up project directory
    if ~isfolder("..\doc\fig\test2\ideal\")
        mkdir("..\doc\fig\test2\ideal\");
    end
    if ~isfolder("../bin/test2/ideal/")
        mkdir ../bin/test2/ideal/
    end
    % configure searching path
    mfile_fullpath = mfilename('fullpath'); % the full path and name of the file in which the call occurs, not including the filename extension.
    mfile_fullpath_without_fname = mfile_fullpath(1:end-strlength(mfilename));
    addpath(genpath(mfile_fullpath_without_fname + "../data"), ...
            genpath(mfile_fullpath_without_fname + "../inc")); % adds the specified folders to the top of the search path for the current MATLAB® session.

    return;
end

%% Single station summary and plot

function [output_diff] = ideal_single_case(ideal_summary,case_num,m_1_name,m_ref_name,method_disp_set,star_component_name,fig_name,title_str,file_name,create_fig_EN,export_fig_EN)
%ideal_single_case - For single ideal case, solve for the differences between methods and plot
%
% Syntax: 
%
% For single ideal case, solve for the differences between methods and plot
% them. Calculate the difference between two of all methods, and show the
% output of the two specified methods in the graph.
    arguments
        ideal_summary
        case_num = 1;
        m_1_name = "M1A";   % method-1 show in the plot
        m_ref_name = "M1B"; % method-ref show in the plot
        method_disp_set = [m_1_name,m_ref_name];
        star_component_name = "Residual";
        fig_name = sprintf("ideal_C%u_%s_%s",case_num,m_1_name,m_ref_name);
        title_str = sprintf("\\bf Ideal Case %u",case_num);
        file_name = sprintf("ideal\\%s",fig_name);
        create_fig_EN = true;
        export_fig_EN = true;
    end

    %% prepare
    
    t = ideal_summary.t;
    x.raw = squeeze(ideal_summary.sst_ideal(case_num,:));
    if ~iscolumn(x.raw)
        x.raw = x.raw.';
    end
    raw_minus_mean_square = sum((x.raw - mean(x.raw,"omitnan")).^2,"omitnan");
    for method_name = ideal_summary.METHOD_NAME
        for component_name = ["trend","season","residual"]
            % summary
            output.(method_name).(component_name) = ideal_summary.(method_name).(component_name){case_num,1};
            if ~iscolumn(output.(method_name).(component_name))
                output.(method_name).(component_name) = output.(method_name).(component_name).';
            end
            % compute adjusted Explained Variance (aEV) of each component
            % (plus trend). "adjusted" means that, when determining the EV,
            % the output trend is added to this component unless this
            % component itself is the output trend.
            if strcmpi(component_name,"trend")
                output.(method_name).(component_name+"_EV") = 1 - sum((x.raw - output.(method_name).(component_name)).^2,"omitnan")/raw_minus_mean_square;
            end
            output.(method_name).(component_name+"_aEV") = 1 - sum((x.raw - output.(method_name).(component_name) - output.(method_name).trend).^2,"omitnan")/raw_minus_mean_square;
        end
    end
    M_1_DISP_NAME = ideal_summary.METHOD_DISP_NAME(ideal_summary.METHOD_NAME == m_1_name);
    M_REF_DISP_NAME = ideal_summary.METHOD_DISP_NAME(ideal_summary.METHOD_NAME == m_ref_name);
    output_diff.case_num = ideal_summary.case_num(case_num);

    %%% diff: summary
    k_max = 10; % Find k largest (smallest) elements of array
    for i = 1:length(ideal_summary.METHOD_NAME)
        method_name = ideal_summary.METHOD_NAME(i);
        for j = i+1:length(ideal_summary.METHOD_NAME)
            ref_method_name = ideal_summary.METHOD_NAME(j);
            for component_name = ["trend","season","residual"]
                field_name = method_name + "_" + ref_method_name + "_" + component_name;
                m_minus_mref = ideal_summary.(method_name).(component_name){case_num,1} - ideal_summary.(ref_method_name).(component_name){case_num,1};
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

    if ~isfield(output_diff, M_FIELD_NAME+"_trend")
        return;
    end

    %% create figure

    if ~create_fig_EN
        return;
    end

    marker_size = 0.58;
    graph_res = 1000;

    ticks_x = t(1:180:end);
    label_x = floor(ticks_x/12) + str2double(extractBetween(ideal_summary.start_month,1,4));

    figure('Name',fig_name)
    t_TCL = tiledlayout(4,1,"TileSpacing","tight","Padding","compact");
    
    method_name_set = ["M1A","M1B","M2","M2A","M2S","M3L","M3Q","Ssa","Ssm"];
    line_spec_order = ["-","-",":","--","-.","x","+"];
    
    % 1. raw data, extracted trend (selected) and ideal trend
    t_axes = nexttile(t_TCL,1);
    hold on
    m_cnt = 0;
    for i = 1:length(method_name_set)
        method_name = method_name_set(i);
        if ismember(method_name,method_disp_set)
            m_cnt = m_cnt + 1;
            plot(t_axes,t,output.(method_name).trend,line_spec_order(m_cnt),"DisplayName",ideal_summary.METHOD_DISP_NAME(ideal_summary.METHOD_NAME==method_name),'MarkerSize',marker_size);
        end
    end
    plot(t_axes,t,ideal_summary.trend_ideal(case_num,:),'--',"DisplayName",'ideal');
    plot(t_axes,t,x.raw,'-',"DisplayName",'raw SST');
    hold off
    set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','in','XTickLabel',{},'XLimitMethod','tight');
    xticks(t_axes,ticks_x);
    xticklabels(t_axes,{})
    ylabel(t_axes,"SST (℃)","FontSize",10)

    % 2. extracted trend (selected) and ideal trend
    
    output_diff_field_name = M_FIELD_NAME+"_trend";
    if strcmpi(star_component_name,"Trend")
        if case_num == 8
            star_str = "\diamondsuit";
        else
            star_str = "*";
        end
    else
        star_str = "";
    end
    t_axes = nexttile(t_TCL,2);
    % plot(t_axes,t,x.raw-x.season,'-',"DisplayName",'ideal deseason');
    hold on
    m_cnt = 0;
    for i = 1:length(method_name_set)
        method_name = method_name_set(i);
        if ismember(method_name,method_disp_set)
            m_cnt = m_cnt + 1;
            plot(t_axes,t,output.(method_name).trend,line_spec_order(m_cnt),"DisplayName",ideal_summary.METHOD_DISP_NAME(ideal_summary.METHOD_NAME==method_name),'MarkerSize',marker_size);
        end
    end
    plot(t_axes,t,ideal_summary.trend_ideal(case_num,:),'--',"DisplayName",'ideal');
    set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','in','XTickLabel',{},'XLimitMethod','tight');
    legend(t_axes,'box','off','Orientation','vertical','Location','best','NumColumns',3);
    xticks(t_axes,ticks_x);
    xticklabels(t_axes,{});
    ylabel(t_axes,"(℃)","FontSize",10);
    title(sprintf("\\bf %sTrend. \\rm (%s minus %s:  %.2e, {\\it t} = %d; %.2e, {\\it t} = %d.  EV: %.2f, %.2f)", ...
        star_str,M_1_DISP_NAME,M_REF_DISP_NAME, ...
        output_diff.(output_diff_field_name).maxk(1),output_diff.(output_diff_field_name).maxk_ind(1), ...
        output_diff.(output_diff_field_name).mink(1),output_diff.(output_diff_field_name).mink_ind(1), ...
        output.(m_1_name).trend_EV,output.(m_ref_name).trend_EV), ...
        "FontSize",10,'FontName','Times New Roman');

    % 3. extracted residual (selected) and ideal

    output_diff_field_name = M_FIELD_NAME+"_residual";
    if strcmpi(star_component_name,"residual")
        if case_num == 8
            star_str = "\diamondsuit";
        else
            star_str = "*";
        end
    else
        star_str = "";
    end
    t_axes = nexttile(t_TCL,3);
    % plot(t_axes,t,x.residual,'-',"DisplayName",'ideal deseason');
    hold on
    m_cnt = 0;
    for i = 1:length(method_name_set)
        method_name = method_name_set(i);
        if ismember(method_name,method_disp_set)
            m_cnt = m_cnt + 1;
            plot(t_axes,t,output.(method_name).residual,line_spec_order(m_cnt),"DisplayName",ideal_summary.METHOD_DISP_NAME(ideal_summary.METHOD_NAME==method_name),'MarkerSize',marker_size);
        end
    end
    plot(t_axes,t,ideal_summary.residual_ideal(case_num,:),'--',"DisplayName",'ideal');
    set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','in','XLimitMethod','tight');
    % legend(t_axes,'boxoff');
    xticks(t_axes,ticks_x);
    xticklabels(t_axes,label_x)
    % xlabel(t_axes,"year","FontSize",10)
    ylabel(t_axes,"(℃)","FontSize",10)
    title(sprintf("\\bf %sResidual. \\rm (%s minus %s:  %.2e, {\\it t} = %d; %.2e, {\\it t} = %d.  aEV: %.2f, %.2f)", ...
        star_str,M_1_DISP_NAME,M_REF_DISP_NAME, ...
        output_diff.(output_diff_field_name).maxk(1),output_diff.(output_diff_field_name).maxk_ind(1), ...
        output_diff.(output_diff_field_name).mink(1),output_diff.(output_diff_field_name).mink_ind(1), ...
        output.(m_1_name).residual_aEV,output.(m_ref_name).residual_aEV), ...
        "FontSize",10,'FontName','Times New Roman');

    % 4. extracted annual cycle (seasonal component) (selected) and ideal

    output_diff_field_name = M_FIELD_NAME+"_season";
    if strcmpi(star_component_name,"season")
        if case_num == 8
            star_str = "\diamondsuit";
        else
            star_str = "*";
        end
    else
        star_str = "";
    end
    t_axes = nexttile(t_TCL,4);
    % plot(t_axes,t,x.raw-x.trend,'-',"DisplayName",'ideal detrended');
    hold on
    m_cnt = 0;
    for i = 1:length(method_name_set)
        method_name = method_name_set(i);
        if ismember(method_name,method_disp_set)
            m_cnt = m_cnt + 1;
            plot(t_axes,t,output.(method_name).season,line_spec_order(m_cnt),"DisplayName",ideal_summary.METHOD_DISP_NAME(ideal_summary.METHOD_NAME==method_name),'MarkerSize',marker_size);
        end
    end
    plot(t_axes,t,ideal_summary.season_ideal(case_num,:),'--',"DisplayName",'ideal');
    set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','in','XLimitMethod','tight');
    xlim(t_axes,[1,24])
    legend(t_axes,'boxoff','Location','best','NumColumns',3);
    xlabel(t_axes,"Months","FontSize",10)
    ylabel(t_axes,"(℃)","FontSize",10)
    title(sprintf("\\bf %sAnnual Cycle. \\rm (%s minus %s:  %.2e, {\\it t} = %d; %.2e, {\\it t} = %d.  aEV: %.2f, %.2f)", ...
        star_str,M_1_DISP_NAME,M_REF_DISP_NAME, ...
        output_diff.(output_diff_field_name).maxk(1),output_diff.(output_diff_field_name).maxk_ind(1), ...
        output_diff.(output_diff_field_name).mink(1),output_diff.(output_diff_field_name).mink_ind(1), ...
        output.(m_1_name).season_aEV,output.(m_ref_name).season_aEV), ...
        "FontSize",10,'FontName','Times New Roman');
    %
    title(t_TCL,title_str,"FontSize",10,'FontName','Times New Roman')

    if export_fig_EN
        exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",file_name),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb') 
    end

    return;
end

%% 

function [output_diff] = ideal_single_case_graph(ideal_summary,diff_struct,star_component_name,create_fig_EN,export_fig_EN)
%ideal_single_case_graph - Draw, iterating through all "method pairs" in the struct. 
%
% Syntax: 
%
% Will call function ideal_single_case.
    arguments
        ideal_summary
        diff_struct
        star_component_name = "residual";
        create_fig_EN = true;
        export_fig_EN = false;
    end
    output_diff = cell(length(diff_struct.method_name),1);
    for i = 1:length(diff_struct.method_name)
        m_1_name = diff_struct.method_name(i);
        m_ref_name = diff_struct.ref_method_name(i);
        field_name = m_1_name + "_" + m_ref_name;
        method_disp_set = [m_1_name,m_ref_name];
        case_ss = diff_struct.case_num(diff_struct.(field_name).max_diff_linear_ind);
        case_selected = case_ss(1);
        %
        ad_cnt = 0;
        fig_name = sprintf("ideal_C%u_%s_%s_%s",case_selected,m_1_name,m_ref_name,star_component_name);
        title_str = sprintf("\\bf Ideal Case %u",case_selected);
        file_name = sprintf("ideal\\%s",fig_name);
        [output_diff{i+ad_cnt}] = ideal_single_case(ideal_summary,case_selected,m_1_name,m_ref_name,method_disp_set,star_component_name,fig_name,title_str,file_name,create_fig_EN,export_fig_EN);
        %
        if case_selected == 8
            ad_cnt = ad_cnt + 1;
            case_selected = case_ss(2);
            fig_name = sprintf("ideal_C%u_%s_%s_%s",case_selected,m_1_name,m_ref_name,star_component_name);
            title_str = sprintf("\\bf Ideal Case %u",case_selected);
            file_name = sprintf("ideal\\%s",fig_name);
            [output_diff{i+ad_cnt}] = ideal_single_case(ideal_summary,case_selected,m_1_name,m_ref_name,method_disp_set,star_component_name,fig_name,title_str,file_name,create_fig_EN,export_fig_EN);
        end
    end

    return;
end

%% 

function [] = ideal_diff_txt_gen(diff_struct,fileID,descrip_str,component_disp_name,METHOD_NAME,METHOD_DISP_NAME)
%ideal_diff_txt_gen - description
%
% Syntax: 
%
% Long description.
    arguments
        diff_struct
        fileID = NaN;
        descrip_str = "Difference between extracted seasonal component (annual cycle).";
        component_disp_name = "season";
        METHOD_NAME = ["M1A","M1B","M2","M2A","M2S","M3L","M3Q","Ssa","Ssm"];
        METHOD_DISP_NAME = ["M-1A","M-1B","M-2","M-2A","M-2S","M-3L","M-3Q","Ssa","Ssm"];
    end

    for i = 1:length(diff_struct.method_name)
        method_name = diff_struct.method_name(i);
        ref_method_name = diff_struct.ref_method_name(i);
        if method_name == ref_method_name
            continue;
        end
        field_name = diff_struct.field_name(i);
        method_disp_name = METHOD_DISP_NAME(METHOD_NAME==method_name);
        ref_method_disp_name = METHOD_DISP_NAME(METHOD_NAME==ref_method_name);
        % seasonality difference from method * to reference method
        fprintf(fileID,"\n[%s minus %s: %s]\n" + ...
            "Description:\t%s\n" + ...
            "Case Name:\t%s\n", ...
            method_disp_name,ref_method_disp_name,component_disp_name, ...
            descrip_str, ...
            strjoin("C" + diff_struct.case_num,'\t'));
        for k = 1:length(diff_struct.indices_name)
            indices_name = diff_struct.indices_name(k);
            if strcmpi(indices_name,"min")
                sort_direction = "ascend";
                sort_direction_sign = "↑";
            else
                sort_direction = "descend";
                sort_direction_sign = "↓";
            end
            [~,I] = sort(diff_struct.(field_name).(indices_name),sort_direction);
            order_ = nan(length(I),1);
            order_(I) = 1:length(I);
            log10_scale = floor(min(log10(abs(diff_struct.(field_name).(indices_name))),[],"omitnan"));
            str_ = compose("%.3g (%u)",diff_struct.(field_name).(indices_name)*(10^(-log10_scale)),order_);
            fprintf(fileID,"%s (1e%i %s) (Order%s):\t%s\n",diff_struct.indices_disp_name_short(k),log10_scale,diff_struct.indices_unit_name(k),sort_direction_sign,strjoin(str_,'\t'));
        end
    end

    return;
end
    