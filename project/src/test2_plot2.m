%% test2_plot2.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-07-09
% Last modified: 2022-07-

function [] = test2_plot2()
%test2_plot2 - Description
%
% Syntax: 
%
% Long description
arguments

end

%%

load("../bin/test2.mat",'results_ideal','METHOD_NAME');

%%

indices_name_group = ["res2res_RMSE","res2res_CC";
                      "cm2cm_RMSE","cm2cm_CC";
                      "cm2raw_RMSE","cm2raw_CC";
                      "cm2cm_cvRMSE","cm2raw_cvRMSE"];
fig_name = "ideal_" + ["res2res";"cm2cm";"cm2raw";"cross_validation"];
file_name = fig_name;

create_fig_en = 1;
export_fig_en = 1;

for i = 1:length(fig_name)
    test2_plot2_1(results_ideal,indices_name_group(i,1),indices_name_group(i,2),fig_name(i),file_name(i),create_fig_en,export_fig_en);
end

return;
end

%%

function [] = test2_plot2_1(results_ideal,indices_name1,indices_name2,fig_name,file_name,create_fig_en,export_fig_en)

if ~create_fig_en
    return;
end

indices_table1 = results_ideal.(indices_name1);
indices_table2 = results_ideal.(indices_name2);

figure("Name",fig_name)
t_TCL = tiledlayout(2,1,"TileSpacing","tight","Padding","compact");

% 1.
t_axes = nexttile(t_TCL,1);
Bar = bar(t_axes,indices_table1{:,2:end});
for i = 1:length(Bar)
    Bar(i).set("DisplayName",indices_table1.Properties.VariableNames{i+1})
end      
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XTickLabel',{});
legend(t_axes,'box','off','Orientation','vertical','NumColumns',3,'Location','best');
if file_name ~= "ideal_cross_validation"
    ylabel(t_axes,"RMSE","FontSize",10);
end

% 2.
t_axes = nexttile(t_TCL,2);
bar(t_axes,indices_table2{:,2:end});
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XTickLabel',{});
xticklabels(t_axes,"C"+string(1:size(indices_table1,1)))
xlabel(t_axes,"Name of Case","FontSize",10)
if file_name ~= "ideal_cross_validation"
    ylabel(t_axes,"Corr. Coeff.","FontSize",10)
else
    ylabel(t_TCL,"Cross-validated  RMSE","FontSize",10,"FontName",'Times New Roman')
end

%%

if export_fig_en
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.emf",file_name),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",file_name),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
%     exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.eps",filename),'Resolution',800,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
end

return;
end
