% gradability_sim_main
% Main script for gradability after simulation
% created by Tridib Saha

%% Loadfile

load('MasterData_Raw.mat')

%% Loop
for i = 1:1:500
%% Define constants
%vehicle parameters
C2 = 0.00012;
C1 = core.global.L2DATA.Sim_Data(i,85);
Cd = core.global.L2DATA.Sim_Data(i,86);
Af = core.global.L2DATA.Sim_Data(i,87);
Mv = core.global.L2DATA.Sim_Data(i,88);

peak2cont_ratio = 2.4;

% Battery parameters
ess.soc = 0.3; % for CS mode
ess.num_p = core.global.L2DATA.Sim_Data(i,71);
ess.num_s = core.global.L2DATA.Sim_Data(i,70);
ess.C_rate = core.global.DOE.simlist_act(i,6);
ess.Vmax = core.global.L2DATA.Sim_Data(i,10);
ess.Vnom = 3.75; % from Nissan Leaf 66_192
ess.Vmin = core.global.L2DATA.Sim_Data(i,9);
ess.Voc_nom = 3.7940; % from lissan leaf file at 0.3 SOC at 25C Temp
ess.Rint_dis = 0.0015; % from lissan leaf file at 0.3 SOC
ess.Rint_chg = 0.0012;% from lissan leaf file at 0.3 SOC
ess.Ah_cap = 33.1;% from lissan leaf file at 25C temp

% Efficiencies
mot2wheel_eff = 0.97; % final drive efficiency
gen_eff = core.global.L2DATA.Sim_Data(i,33)/100;
mot_eff = core.global.L2DATA.Sim_Data(i,32)/100;
eng_eff = core.global.L2DATA.Sim_Data(i,31)/100;

%% Gradability calculations
v_mph = 45;
grade = 7;

[v,P_tr] = gradability_calc(Mv,Cd,Af,C1,C2,v_mph,grade);

%% Component Power requirements

% Motor
mot_Pmax = mot2wheel_eff*core.global.L2DATA.Sim_Data(i,79)/peak2cont_ratio;

% Generator
gen_Pmax = mot_eff*gen_eff*core.global.L2DATA.Sim_Data(i,80);

% ESS 
pack_power_max = batt_Pmax_calc(ess);
ess_Pmax = mot_eff*pack_power_max;

%% Saving valuable power values
Pmax_all(i,1) = P_tr(1)/1000;
Pmax_all(i,2) = mot_Pmax;
Pmax_all(i,3) = gen_Pmax;
Pmax_all(i,4) = ess_Pmax;

%% Power criteria

if (min(mot_Pmax,gen_Pmax) > (P_tr(1)/1000))
    grad_flag(i) = 1;
else
    grad_flag(i) = 0;
end
fprintf('%i\n',i);
end

grad_flag = grad_flag'; % for consistency in dimentions with other flags
%% Keep just grade_flag
%clearvars -except grad_flag


