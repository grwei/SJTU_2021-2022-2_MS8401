%% test2_plot1.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-07-09
% Last modified: 2022-07-

%% I. ideal cases
% 1) raw & ideal trend,
% 2) extracted trend (several),
% 3) extracted season (several),
% 4) residual (several).

%%

function [] = test2_plot1(create_fig_EN,export_fig_EN)
%test2_plot1 - Description
%
% Syntax: 
%
% Long description
arguments
    create_fig_EN = true;
    export_fig_EN = true;
end

%%

load("../bin/test2/test2.mat",'results_ideal');

%%

indices_name_group = ["res2res_RMSE","res2res_CC";
                      "cm2cm_RMSE","cm2cm_CC";
                      "cm2raw_RMSE","cm2raw_CC";
                      "cm2cm_cvRMSE","cm2raw_cvRMSE";
                      "season_mean","residual_mean";
                      "cm2raw_EV",""];
title_group = ["\bf Residual: output vs. ideal","";
               "\bf Climatological mean: output vs. ideal","";
               "\bf Output climatological mean vs. ideal series","";
               "\bf Climatological mean: output vs. ideal","\bf Output climatological mean vs. ideal series";
               "\bf Mean of seasonal component","\bf Mean of residual component";
               "\bf Variance Explained (EV) by the climatological mean",""];
ylabel_group = ["RMSE (℃)","Corr. Coeff.";
                "RMSE (℃)","Corr. Coeff.";
                "RMSE (℃)","Corr. Coeff.";
                "Cross-validated RMSE (℃)","Cross-validated RMSE (℃)";
                "-log_{10}(abs(value))","-log_{10}(abs(value))";
                "Variance Explained",""];
fig_name = "ideal_" + ["res2res";"cm2cm";"cm2raw";"cross_validation";"season_residual_mean";"cm2raw_EV"];
file_name = fig_name;

for i = 1:length(fig_name)
    test2_plot1_1(results_ideal,indices_name_group(i,1),indices_name_group(i,2),title_group(i,1),title_group(i,2),ylabel_group(i,1),ylabel_group(i,2),fig_name(i),file_name(i),create_fig_EN,export_fig_EN);
end

return;
end

%%

function [] = test2_plot1_1(results_ideal,indices_name1,indices_name2,title1,title2,ylabel1,ylabel2,fig_name,file_name,create_fig_en,export_fig_en)

if ~create_fig_en
    return;
end

graph_res = 1000;

indices_table1 = results_ideal.(indices_name1);
if indices_name2 ~= ""
    indices_table2 = results_ideal.(indices_name2);
else
    indices_table2 = [];
end

figure("Name",fig_name)
if ~isempty(indices_table2)
    t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","compact");
else
    t_TCL = tiledlayout(1,1,"TileSpacing","tight","Padding","compact");
end

% 1.
t_axes = nexttile(t_TCL,1);
if indices_name1 == "season_mean" || indices_name1 == "residual_mean"
    Bar = bar(t_axes,-log10(abs(indices_table1{:,2:end-2})));
else
    Bar = bar(t_axes,indices_table1{:,2:end-2});
end
for i = 1:length(Bar)
    Bar(i).set("DisplayName",indices_table1.Properties.VariableNames{i+1})
end      
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','on','TickDir','in','XTickLabel',{});
grid on
legend(t_axes,'box','on','Orientation','vertical','NumColumns',4,'Location','best');
title(t_axes,title1,"FontSize",10)
if ylabel1 ~= "" && ~isempty(indices_table2) && ylabel1 ~= ylabel2
    ylabel(t_axes,ylabel1,"FontSize",10);
end

if isempty(indices_table2)
    ylabel(t_TCL,ylabel1,"FontSize",10,"FontName",'Times New Roman');
    xticklabels(t_axes,"C"+string(1:size(indices_table1,1)))
    xlabel(t_axes,"Case name","FontSize",10);
    legend(t_axes,'box','on','Orientation','vertical','NumColumns',4,'Location','best');
    
    if export_fig_en
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.emf",file_name),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",file_name),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
    %     exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.eps",filename),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
    end

    return;
end

% 2.
t_axes = nexttile(t_TCL,2);
if indices_name2 == "season_mean" || indices_name2 == "residual_mean"
    bar(t_axes,-log10(abs(indices_table2{:,2:end-2})));
else
    bar(t_axes,indices_table2{:,2:end-2});
end
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','on','TickDir','in','XTickLabel',{});
grid on
xticklabels(t_axes,"C"+string(1:size(indices_table1,1)))
xlabel(t_axes,"Case name","FontSize",10)
title(t_axes,title2,"FontSize",10)
if ylabel2 ~= "" && ylabel1 ~= ylabel2
    ylabel(t_axes,ylabel2,"FontSize",10)
end

if ylabel1 == ylabel2
    ylabel(t_TCL,ylabel1,"FontSize",10,"FontName",'Times New Roman')
end

%%

if export_fig_en
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.emf",file_name),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",file_name),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
%     exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.eps",filename),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
end

return;
end
