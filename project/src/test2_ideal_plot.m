%% test2_ideal_plot.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-07-10
% Last modified: 2022-07-

function [] = test2_ideal_plot(fig_name,mat_file_path,title_str,create_fig_EN,export_fig_EN)
%test2_ideal_plot - Description
%
% Syntax: 
%
% Long description
arguments
    fig_name = "ideal_1_1";
    mat_file_path = "ideal_1_1"
    title_str = fig_name;
    create_fig_EN = 1;
    export_fig_EN = 1;
end

load(sprintf("..\\bin\\test2\\%s.mat",mat_file_path),'t','x','output')

%% create figure

if ~create_fig_EN
    return;
end

marker_size = 0.58;
graph_res = 1000;

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
plot(t_axes,t,output.M2S.trend,'-.',"DisplayName",'M-2S');
plot(t_axes,t,output.M3L.trend,'x',"DisplayName",'M-3L','MarkerSize',marker_size);
plot(t_axes,t,output.M3Q.trend,'+',"DisplayName",'M-3Q','MarkerSize',marker_size);
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XTickLabel',{},'XLimitMethod','tight');
legend(t_axes,'box','off','Orientation','vertical','NumColumns',4,'Location','best');
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
plot(t_axes,t,output.M2S.residue,'-.',"DisplayName",'M-2S');
plot(t_axes,t,output.M3L.residue,'x',"DisplayName",'M-3L','MarkerSize',marker_size);
plot(t_axes,t,output.M3Q.residue,'+',"DisplayName",'M-3Q','MarkerSize',marker_size);
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
plot(t_axes,t,output.M2S.season,'-.',"DisplayName",'M-2S');
plot(t_axes,t,output.M3L.season,'x',"DisplayName",'M-3L','MarkerSize',marker_size);
plot(t_axes,t,output.M3Q.season,'+',"DisplayName",'M-3Q','MarkerSize',marker_size);
set(t_axes,"YDir",'normal',"TickLabelInterpreter",'tex',"FontSize",10,'FontName','Times New Roman','Box','off','TickDir','out','XLimitMethod','tight');
xlim(t_axes,[1,24])
% legend(t_axes,'boxoff');
xlabel(t_axes,"Months","FontSize",10)
ylabel(t_axes,"Annual Cycle (℃)","FontSize",10)

title(t_TCL,title_str,"FontSize",10,'FontName','Times New Roman')

if export_fig_EN
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.emf",mat_file_path),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
    exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.png",mat_file_path),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
%     exportgraphics(t_TCL,sprintf("..\\doc\\fig\\test2\\%s.eps",filename),'Resolution',graph_res,'ContentType','auto','BackgroundColor','none','Colorspace','rgb');
end

return;
end
