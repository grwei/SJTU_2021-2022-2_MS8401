%% test2_real.m
% Description: project:
% Author: Guorui Wei (危国锐) (313017602@qq.com; weiguorui@sjtu.edu.cn)
% Student ID: 120034910021
% Created: 2022-07-05
% Last modified: 2022-07-

%% I. ideal cases
% 1) raw & ideal trend,
% 2) extracted trend (several),
% 3) extracted season (several),
% 4) residue (several).

%% II. real indices
% 1) raw vs. extracted trend (several),
% 2) extracted trend (several),
% 3) extracted season (several),
% 4) residue (several).

%% real indices: () -> ()

function [x_1A,x_1B,x_2,x_2A,x_2P,x_3L,x_3Q,x_Ssa,x_Ssm] = test2_real(t,x,span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell,M1_A,M1_B,M2,M2_A,M2_P,M3,M1_A_cv,M1_B_cv,M2_cv,M2_A_cv,M2_P_cv,M3_cv,file_name,real_solve_EN)
%test2_real - Description
%
% Syntax: [x_1A,x_1B,x_2,x_2A,x_2P,x_3L,x_3Q,x_Ssa,x_Ssm] = test2_real(t,x,span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell,M1_A,M1_B,M2,M2_A,M2_P,M3,M1_A_cv,M1_B_cv,M2_cv,M2_A_cv,M2_P_cv,M3_cv,file_name,real_solve_EN)
%
% Long description
arguments
    t           (:,1) double {mustBeNonNan(t)}
    x
    span
    trend_deg
    lwlr_annual
    T_annual
    h
    cat_ind_cell
    M1_A        function_handle
    M1_B        function_handle
    M2          function_handle
    M2_A        function_handle
    M2_P        function_handle
    M3          function_handle
    M1_A_cv     function_handle
    M1_B_cv     function_handle
    M2_cv       function_handle
    M2_A_cv     function_handle
    M2_P_cv     function_handle
    M3_cv       function_handle
    file_name = "ersst\ersst_v5_2N_2E";
    real_solve_EN = true;
end

%%

mat_file_path = sprintf("..\\bin\\test2\\%s.mat",file_name);
if ~real_solve_EN && isfile(mat_file_path)
    load(mat_file_path,'output');
    % output
    x_1A = output.M1A;
    x_1B = output.M1B;
    x_2 = output.M2;
    x_2A = output.M2A;
    x_2P = output.M2P;
    x_3L = output.M3L;
    x_3Q = output.M3Q;
    x_Ssa = output.Ssa;
    x_Ssm = output.Ssm;
    
    return;
end

METHOD_NAME = ["M1A","M1B","M2","M2A","M2P","M3L","M3Q","Ssa","Ssm"];
CV_FUNC_HANDLER = {M1_A_cv,M1_B_cv,M2_cv,M2_A_cv,M2_P_cv,M3_cv,M3_cv,M1_A_cv,M3_cv};

for i = 1:length(METHOD_NAME)
    CV_FUNC.(METHOD_NAME(i)) = CV_FUNC_HANDLER{i};
    output.(METHOD_NAME(i)).t = t;
end

if isempty(cat_ind_cell)
    cat_ind_cell = cell(12,1);
    for i = 1:12
        cat_ind_cell{i,1} = i:12:length(t);
    end
end

%% additive classical decomposition

[output.M1A.trend,output.M1A.season,output.M1A.residue] = M1_A(t,x.raw,span,trend_deg,lwlr_annual,cat_ind_cell);
[output.M1B.trend,output.M1B.season,output.M1B.residue] = M1_B(t,x.raw,span,trend_deg,lwlr_annual,cat_ind_cell);
[output.M2.trend,output.M2.season,output.M2.residue] = M2(t,x.raw,span,trend_deg,lwlr_annual,cat_ind_cell);
[output.M2A.trend,output.M2A.season,output.M2A.residue] = M2_A(t,x.raw,span,trend_deg,lwlr_annual,cat_ind_cell);
[output.M2P.trend,output.M2P.season,output.M2P.residue] = M2_P(t,x.raw,span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell);
[output.M3L.trend,output.M3L.season,output.M3L.residue] = M3(t,x.raw,T_annual,h,1);
[output.M3Q.trend,output.M3Q.season,output.M3Q.residue] = M3(t,x.raw,T_annual,h,2);
[output.Ssa.trend,output.Ssa.season,output.Ssa.residue] = M1_A(t,x.raw,+Inf,0,lwlr_annual,cat_ind_cell);
[output.Ssm.trend,output.Ssm.season,output.Ssm.residue] = M3(t,x.raw,T_annual,h,0);

%% Analysis

%%% 1. sample Pearson linear Correlation Coefficient (CC) and Mean Square
% Error (MSE) of extracted trend + annual cycle (climatological mean?) to
% original raw series

for m_name = METHOD_NAME
    output_cm = output.(m_name).trend + output.(m_name).season;
    if any(~isnan(output_cm))
        output.(m_name).cm2raw_RMSE = std(output_cm - x.raw, 0,"omitnan");
        output.(m_name).cm2raw_CC = corr(output_cm, x.raw, 'type','Pearson','rows','pairwise');
    else
        output.(m_name).cm2raw_RMSE = NaN;
        output.(m_name).cm2raw_CC = NaN;
    end
end

for m_name = METHOD_NAME
   output.(m_name).season_mean = mean(output.(m_name).season,"omitnan");
   output.(m_name).res_mean = mean(output.(m_name).residue,"omitnan");
end

%%% 2. The fraction of variance explained (EV) by the trend + annual cycle (climatological mean?)

for m_name = METHOD_NAME
    output_cm = output.(m_name).trend + output.(m_name).season;
    x_raw_mean = mean(x.raw,"omitnan");
    if all(~isnan(output_cm))
        output.(m_name).cm2raw_EV = 1 - sum((x.raw - output_cm).^2,"omitnan")/sum((x.raw - x_raw_mean).^2,"omitnan");
        if output.(m_name).cm2raw_EV < 0 || output.(m_name).cm2raw_EV > 1
            fprintf("Invalid cm2raw_EV:\t %.2g\n",output.(m_name).cm2raw_EV)
            output.(m_name).cm2raw_EV = NaN;
        end
    else
        output.(m_name).cm2raw_EV = NaN;
    end
end

%%% 3. Cross-validated mean squared Error (cvMSE) of extracted trend +
% annual cycle (climatological mean?) to original raw series

n_fold = 1;
cv_period = 12*30; % repeating interval of test set
n_period = floor((length(t)-12)/cv_period); % monthly data only!
for m_name = METHOD_NAME
    output.(m_name).cm2raw_cvSE = nan(n_fold,1);
    cnt_month = 0;
    for i = 0:n_fold-1
        ind_test = (1:12)+12*i;
        ind_test = ind_test.' + repmat(0:n_period,[12,1])*cv_period;
        ind_test = ind_test(:);
        cnt_month = cnt_month + length(ind_test);
        t_istest = zeros(size(t));
        t_istest(ind_test) = 1;
        if m_name == "M3L"
            x_fit = CV_FUNC.M3L(t,x.raw,t_istest,T_annual,h,1);
        elseif m_name == "M3Q"
            x_fit = CV_FUNC.M3Q(t,x.raw,t_istest,T_annual,h,2);
        elseif m_name == "M2P"
            x_fit = CV_FUNC.M2P(t,x.raw,t_istest,span,trend_deg,lwlr_annual,T_annual,h,cat_ind_cell);
        elseif m_name == "Ssa"
            x_fit = CV_FUNC.Ssa(t,x.raw,t_istest,+Inf,0,lwlr_annual,cat_ind_cell);
        elseif m_name == "Ssm"
            x_fit = CV_FUNC.Ssm(t,x.raw,t_istest,T_annual,h,0);
        else
            x_fit = CV_FUNC.(m_name)(t,x.raw,t_istest,span,trend_deg,lwlr_annual,cat_ind_cell);
        end
        x_test_cm_fit = x_fit.trend(ind_test) + x_fit.season(ind_test);
        if any(~isnan(x_test_cm_fit))
            output.(m_name).cm2raw_cvSE(i+1) = sum((x_test_cm_fit - x.raw(ind_test)).^2,"omitnan");
        end
    end
    if ~all(isnan(output.(m_name).cm2raw_cvSE))
        output.(m_name).cm2raw_cvRMSE = sqrt(sum(output.(m_name).cm2raw_cvSE,"omitnan")/cnt_month);
    else
        output.(m_name).cm2raw_cvRMSE = NaN;
    end
end

% output
x_1A = output.M1A;
x_1B = output.M1B;
x_2 = output.M2;
x_2A = output.M2A;
x_2P = output.M2P;
x_3L = output.M3L;
x_3Q = output.M3Q;
x_Ssa = output.Ssa;
x_Ssm = output.Ssm;

%%

if isfile(mat_file_path)
    save(mat_file_path,'output','-append');
else
    save(mat_file_path,'output');
end

return;
end
