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

function [x_1A,x_1B,x_2,x_2A,x_3] = test2_plot1(t,x,span,lwlr_annual,T_annual,h,cat_ind_cell,M1_A,M1_B,M2,M2_A,M3,fig_name,filename,create_fig_en,export_fig_en)
%test2_plot1 - Description
%
% Syntax: [x_1A,x_1B,x_2,x_2A,x_3] = test2_plot1(t,x,span,lwlr_annual,T_annual,h,cat_ind_cell,M1_A,M1_B,M2,M2_A,M3,fig_name,filename,create_fig_en,export_fig_en)
%
% Long description
arguments
    t
    x
    span
    lwlr_annual
    T_annual
    h
    cat_ind_cell
    M1_A
    M1_B
    M2
    M2_A
    M3
    fig_name = "fig_name";
    filename = "ideal_1.emf";
    create_fig_en = 0;
    export_fig_en = 0;
end

if isempty(cat_ind_cell)
    cat_ind_cell = cell(12,1);
    for i = 1:12
        cat_ind_cell{i,1} = i:12:length(t);
    end
end

%% additive classical decomposition

[x_1A.trend,x_1A.season,x_1A.residue] = M1_A(t,x.raw,span,lwlr_annual,cat_ind_cell);
[x_1B.trend,x_1B.season,x_1B.residue] = M1_B(t,x.raw,span,lwlr_annual,cat_ind_cell);
[x_2.trend,x_2.season,x_2.residue] = M2(t,x.raw,span,lwlr_annual,cat_ind_cell);
[x_2A.trend,x_2A.season,x_2A.residue] = M2_A(t,x.raw,span,lwlr_annual,cat_ind_cell);
[x_3.trend,x_3.season,x_3.residue] = M3(t,x.raw,T_annual,h);

%% analysis

%%% 1. sample Pearson linear Correlation Coefficient (CC) and Mean Square
% Error (MSE) of extracted residue to ideal residue Test: Are they equal
% to: CC and MSE of extracted trend + annual cycle (climatological mean?)
% to ideal trend + annual cycle (climatological mean?) ?

% [TODO] 写工具函数!

x_1A.MSE_res2res = var(x_1A.residue - x.residue,0,"omitnan");
x_1B.MSE_res2res = var(x_1B.residue - x.residue,0,"omitnan");
x_2.MSE_res2res = var(x_2.residue - x.residue,0,"omitnan");
x_2A.MSE_res2res = var(x_2A.residue - x.residue,0,"omitnan");
x_3.MSE_res2res = var(x_3.residue - x.residue,0,"omitnan");

x_1A.CC_res2res = corr(x_1A.residue,x.residue,'type','Pearson','rows','pairwise');
x_1B.CC_res2res = corr(x_1B.residue,x.residue,'type','Pearson','rows','pairwise');
x_2.CC_res2res = corr(x_2.residue,x.residue,'type','Pearson','rows','pairwise');
x_2A.CC_res2res = corr(x_2A.residue,x.residue,'type','Pearson','rows','pairwise');
x_3.CC_res2res = corr(x_3.residue,x.residue,'type','Pearson','rows','pairwise');

x_1A.MSE_cm2cm = var(x_1A.trend + x_1A.season - x.trend - x.season,0,"omitnan");
x_1B.MSE_cm2cm = var(x_1B.trend + x_1B.season - x.trend - x.season,0,"omitnan");
x_2.MSE_cm2cm = var(x_2.trend + x_2.season - x.trend - x.season,0,"omitnan");
x_2A.MSE_cm2cm = var(x_2A.trend + x_2A.season - x.trend - x.season,0,"omitnan");
x_3.MSE_cm2cm = var(x_3.trend + x_3.season - x.trend - x.season,0,"omitnan");

x_1A.CC_cm2cm = corr(x_1A.trend + x_1A.season, x.trend + x.season,'type','Pearson','rows','pairwise');
x_1B.CC_cm2cm = corr(x_1B.trend + x_1B.season, x.trend + x.season,'type','Pearson','rows','pairwise');
x_2.CC_cm2cm = corr(x_2.trend + x_2.season, x.trend + x.season,'type','Pearson','rows','pairwise');
x_2A.CC_cm2cm = corr(x_2A.trend + x_2A.season, x.trend + x.season,'type','Pearson','rows','pairwise');
x_3.CC_cm2cm = corr(x_3.trend + x_3.season, x.trend + x.season,'type','Pearson','rows','pairwise');

%%% 2. sample CC and MSE of extracted trend + annual cycle (climatological
% mean?) to ideal raw series
% Question: Their relations to CC and MSE obtained in "1."?

x_1A.MSE_res2res = var(x_1A.residue - x.residue,0,"omitnan");

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
ylabel(t_axes,"ideal series (℃)","FontSize",10)

% 2. ideal deseason vs. extracted trend (several)

t_axes = nexttile(t_TCL,2);
% plot(t_axes,t,x.raw-x.season,'-',"DisplayName",'ideal deseason');
hold on
plot(t_axes,t,x_1A.trend,'-',"DisplayName",'M-1A');
plot(t_axes,t,x_1B.trend,'-',"DisplayName",'M-1B');
plot(t_axes,t,x_2A.trend,'--',"DisplayName",'M-2A');
plot(t_axes,t,x_2.trend,':',"DisplayName",'M-2');
plot(t_axes,t,x_3.trend,'x',"DisplayName",'M-3','MarkerSize',2);
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XTickLabel',{},'XLimitMethod','tight');
legend(t_axes,'box','off','Orientation','vertical','NumColumns',3,'Location','best');
xticks(t_axes,ticks_x);
xticklabels(t_axes,{})
ylabel(t_axes,"trend (℃)","FontSize",10)

% 3. ideal residue vs. extracted residue (several)

t_axes = nexttile(t_TCL,3);
% plot(t_axes,t,x.residue,'-',"DisplayName",'ideal deseason');
hold on
plot(t_axes,t,x_1A.residue,'-',"DisplayName",'M-1A');
plot(t_axes,t,x_1B.residue,'-',"DisplayName",'M-1B');
plot(t_axes,t,x_2A.residue,'--',"DisplayName",'M-2A');
plot(t_axes,t,x_2.residue,':',"DisplayName",'M-2');
plot(t_axes,t,x_3.residue,'x',"DisplayName",'M-3','MarkerSize',2);
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XLimitMethod','tight');
% legend(t_axes,'boxoff');
xticks(t_axes,ticks_x);
xticklabels(t_axes,label_x)
% xlabel(t_axes,"year","FontSize",10)
ylabel(t_axes,"residue (℃)","FontSize",10)

% 4. ideal detrended vs. extracted season (several)

t_axes = nexttile(t_TCL,4);
% plot(t_axes,t,x.raw-x.trend,'-',"DisplayName",'ideal detrended');
hold on
plot(t_axes,t,x_1A.season,'-',"DisplayName",'M-1A');
plot(t_axes,t,x_1B.season,'-',"DisplayName",'M-1B');
plot(t_axes,t,x_2A.season,'--',"DisplayName",'M-2A');
plot(t_axes,t,x_2.season,':',"DisplayName",'M-2');
plot(t_axes,t,x_3.season,'x',"DisplayName",'M-3','MarkerSize',2);
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XLimitMethod','tight');
xlim(t_axes,[1,24])
% legend(t_axes,'boxoff');
xlabel(t_axes,"months","FontSize",10)
ylabel(t_axes,"annual cycle (℃)","FontSize",10)

if export_fig_en
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.emf",filename),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.jpg",filename),'Resolution',600,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
%     exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.eps",filename),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
end

return;
end

function [] = d()

end
