%% test2_plot1.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-07-05
% Last modified: 2022-07-

%% I. ideal cases
% 1) raw & ideal trend,
% 2) ideal deseason vs. extracted trend (several),
% 3) ideal detrended vs. extracted season (several),
% 4) ideal residue vs. extracted residue (several).

%% II. real indices
% 1) raw vs. extracted trend (several),
% 2) raw vs. extracted trend+season (several),
% 3) extracted residue (several).

%% ideal cases: () -> ()

function [x_1A,x_1B,x_2,x_2A,x_3] = test2_plot1(t,x,span,lwlr_annual,T_annual,h,cat_ind_cell,M1_A,M1_B,M2,M2_A,M3,M1_A_cv,M1_B_cv,M2_cv,M2_A_cv,M3_cv,fig_name,file_name,create_fig_en,export_fig_en)
%test2_plot1 - Description
%
% Syntax: [x_1A,x_1B,x_2,x_2A,x_3] = test2_plot1(t,x,span,lwlr_annual,T_annual,h,cat_ind_cell,M1_A,M1_B,M2,M2_A,M3,fig_name,file_name,create_fig_en,export_fig_en)
%
% Long description
arguments
    t           (:,1) double {mustBeNonNan(t)}
    x
    span
    lwlr_annual
    T_annual
    h
    cat_ind_cell
    M1_A        function_handle
    M1_B        function_handle
    M2          function_handle
    M2_A        function_handle
    M3          function_handle
    M1_A_cv     function_handle
    M1_B_cv     function_handle
    M2_cv       function_handle
    M2_A_cv     function_handle
    M3_cv       function_handle
    fig_name    = "fig_name";
    file_name   = "ideal_1";
    create_fig_en = 0;
    export_fig_en = 0;
end

%%

METHOD_NAME = ["M1A","M1B","M2","M2A","M3"];
CV_FUNC_HANDLER = {M1_A_cv,M1_B_cv,M2_cv,M2_A_cv,M3_cv};

for i = 1:length(METHOD_NAME)
    CV_FUNC.(METHOD_NAME(i)) = CV_FUNC_HANDLER{i};
end

if isempty(cat_ind_cell)
    cat_ind_cell = cell(12,1);
    for i = 1:12
        cat_ind_cell{i,1} = i:12:length(t);
    end
end

%% additive classical decomposition

[output.M1A.trend,output.M1A.season,output.M1A.residue] = M1_A(t,x.raw,span,lwlr_annual,cat_ind_cell);
[output.M1B.trend,output.M1B.season,output.M1B.residue] = M1_B(t,x.raw,span,lwlr_annual,cat_ind_cell);
[output.M2.trend,output.M2.season,output.M2.residue] = M2(t,x.raw,span,lwlr_annual,cat_ind_cell);
[output.M2A.trend,output.M2A.season,output.M2A.residue] = M2_A(t,x.raw,span,lwlr_annual,cat_ind_cell);
[output.M3.trend,output.M3.season,output.M3.residue] = M3(t,x.raw,T_annual,h);

%% analysis

%%% 1. sample Pearson linear Correlation Coefficient (CC) and Mean Square
% Error (MSE) of extracted residue to ideal residue
% QUESTION: Are they equal to: CC and MSE of extracted trend + annual cycle
% (climatological mean?) to ideal trend + annual cycle (climatological
% mean?) ?

for m_name = METHOD_NAME
    output.(m_name).res2res_RMSE = std(output.(m_name).residue - x.residue,0,"omitnan");
    output.(m_name).cm2cm_RMSE = std(output.(m_name).trend + output.(m_name).season - x.trend - x.season,0,"omitnan");
    output.(m_name).res2res_CC = corr(output.(m_name).residue, x.residue,'type','Pearson','rows','pairwise');
    output.(m_name).cm2cm_CC = corr(output.(m_name).trend + output.(m_name).season, x.trend + x.season,'type','Pearson','rows','pairwise');
end

%%% 2. sample CC and MSE of extracted trend + annual cycle (climatological
% mean?) to ideal raw series
% Question: Their relations to CC and MSE obtained in "1."?

for m_name = METHOD_NAME
    output.(m_name).cm2raw_RMSE = std(output.(m_name).trend + output.(m_name).season - x.raw, 0,"omitnan");
    output.(m_name).cm2raw_CC = corr(output.(m_name).trend + output.(m_name).season, x.raw, 'type','Pearson','rows','pairwise');
end

%%% 3. Cross-validated mean squared Error (cvMSE) of trend + annual cycle
% (climatological mean?) to ideal climatological mean

n_fold = floor(length(t)/12);
for m_name = METHOD_NAME
    output.(m_name).cm2cm_cvSE = nan(n_fold,1);
    output.(m_name).cm2raw_cvSE = nan(n_fold,1);
    for i = 0:n_fold-1
        ind_test = (1:12)+12*i;
        t_istest = zeros(size(t));
        t_istest(ind_test) = 1;
        if m_name == "M3"
            x_fit = CV_FUNC.M3(t,x.raw,t_istest,T_annual,h);
        else
            x_fit = CV_FUNC.(m_name)(t,x.raw,t_istest,span,lwlr_annual,cat_ind_cell);
        end
        output.(m_name).cm2cm_cvSE(i+1) = sum((x_fit.trend(ind_test) + x_fit.season(ind_test) - x.trend(ind_test) - x.season(ind_test)).^2,"omitnan");
        output.(m_name).cm2raw_cvSE(i+1) = sum((x_fit.trend(ind_test) + x_fit.season(ind_test) - x.raw(ind_test)).^2,"omitnan");
    end
    output.(m_name).cm2cm_cvRMSE = sqrt(sum(output.(m_name).cm2cm_cvSE,"omitnan")/length(t));
    output.(m_name).cm2raw_cvRMSE = sqrt(sum(output.(m_name).cm2raw_cvSE,"omitnan")/length(t));
end

% output
x_1A = output.M1A;
x_1B = output.M1B;
x_2 = output.M2;
x_2A = output.M2A;
x_3 = output.M3;

%% create figure

if ~create_fig_en
    return;
end

ticks_x = t(1:240:end);
label_x = floor(ticks_x/12) + 1900;

figure('Name',fig_name)
t_TCL = tiledlayout(4,1,"TileSpacing","tight","Padding","compact");

% 1. raw & ideal trend

t_axes = nexttile(t_TCL,1);
plot(t_axes,t,x.raw,'-',"DisplayName",'raw data');
hold on
plot(t_axes,t,x.trend,'-',"DisplayName",'ideal trend');
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XTickLabel',{},'XLimitMethod','tight');
xticks(t_axes,ticks_x);
xticklabels(t_axes,{})
ylabel(t_axes,"Ideal Series (℃)","FontSize",10)

% 2. ideal deseason vs. extracted trend (several)

t_axes = nexttile(t_TCL,2);
% plot(t_axes,t,x.raw-x.season,'-',"DisplayName",'ideal deseason');
hold on
plot(t_axes,t,output.M1A.trend,'-',"DisplayName",'M-1A');
plot(t_axes,t,output.M1B.trend,'-',"DisplayName",'M-1B');
plot(t_axes,t,output.M2.trend,':',"DisplayName",'M-2');
plot(t_axes,t,output.M2A.trend,'--',"DisplayName",'M-2A');
plot(t_axes,t,output.M3.trend,'x',"DisplayName",'M-3','MarkerSize',2);
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XTickLabel',{},'XLimitMethod','tight');
legend(t_axes,'box','off','Orientation','vertical','NumColumns',3,'Location','best');
xticks(t_axes,ticks_x);
xticklabels(t_axes,{})
ylabel(t_axes,"Trend (℃)","FontSize",10)

% 3. ideal residue vs. extracted residue (several)

t_axes = nexttile(t_TCL,3);
% plot(t_axes,t,x.residue,'-',"DisplayName",'ideal deseason');
hold on
plot(t_axes,t,output.M1A.residue,'-',"DisplayName",'M-1A');
plot(t_axes,t,output.M1B.residue,'-',"DisplayName",'M-1B');
plot(t_axes,t,output.M2.residue,':',"DisplayName",'M-2');
plot(t_axes,t,output.M2A.residue,'--',"DisplayName",'M-2A');
plot(t_axes,t,output.M3.residue,'x',"DisplayName",'M-3','MarkerSize',2);
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XLimitMethod','tight');
% legend(t_axes,'boxoff');
xticks(t_axes,ticks_x);
xticklabels(t_axes,label_x)
% xlabel(t_axes,"year","FontSize",10)
ylabel(t_axes,"Residual (℃)","FontSize",10)

% 4. ideal detrended vs. extracted season (several)

t_axes = nexttile(t_TCL,4);
% plot(t_axes,t,x.raw-x.trend,'-',"DisplayName",'ideal detrended');
hold on
plot(t_axes,t,output.M1A.season,'-',"DisplayName",'M-1A');
plot(t_axes,t,output.M1B.season,'-',"DisplayName",'M-1B');
plot(t_axes,t,output.M2.season,':',"DisplayName",'M-2');
plot(t_axes,t,output.M2A.season,'--',"DisplayName",'M-2A');
plot(t_axes,t,output.M3.season,'x',"DisplayName",'M-3','MarkerSize',2);
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XLimitMethod','tight');
xlim(t_axes,[1,24])
% legend(t_axes,'boxoff');
xlabel(t_axes,"Months","FontSize",10)
ylabel(t_axes,"Annual Cycle (℃)","FontSize",10)

if export_fig_en
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.emf",file_name),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",file_name),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
%     exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.eps",filename),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
end

return;
end
