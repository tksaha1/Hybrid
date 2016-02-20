% sizing_soln.m
% Purdue NeXT - HEV Course Project
% Powertrain Component Sizing m-file - with solutions
% Author: APV (03/28/2015)

% Complete this function to size powertrain components for a mid-size
% series PHEV.

% Do not change the number, name or type of any of the input and output
% parameters for the functions or the name of the function itself, as the 
% verification of your code will be automated. Unless specified as arrays 
% the output variables are single values). Apart from these, you can add 
% any variables or modify the code in any way you like.

% Sign convention: power/energy out of the vehicle is +ve, pwoer/energy into
% the vehicle is -ve.

function[T2,EN] = sizing_soln(T1,EFF,const_v,time2meet)

%----------- your code begins here------------

% Component Sizes:

% Peak power rating from motor (kW, round UP to nearest multiple of 10)
T2.mot_peak_pwr = 10*ceil(T1.peak_pos_pwr_prop/ EFF.mot2wheel_eff/ 10);  
T2.mot_peak_pwr_reg = -10*ceil(-T1.peak_neg_pwr_reg* EFF.mot2wheel_eff/ 10); 
% Continuous power rating of generator (kW, round UP to nearest multiple of 5)
T2.gen_cont_pwr = 5*ceil(T1.avg_pos_pwr_prop/(EFF.mot2wheel_eff * EFF.mot_eff * EFF.gen2mot_eff * EFF.gen_eff)/5);

% Optimal power at which engine should be operated (kW, round UP to nearest multiple of 5)
T2.eng_opt_pwr = T2.gen_cont_pwr;                                                              


% ESS energy consumption in All-Electric driving mode:

% Total energy (electrochemical) required from ESS to meet propulsive energy requirement at
% wheels (in Wh/km)
EN.en_prop_req_ess = T1.pos_en_at_whl /(EFF.mot2wheel_eff * EFF.mot_eff * EFF.ess_eff);

% Total energy (electrochemical) recaptured at ESS through regen braking (in Wh/km)
EN.en_reg_recap_ess = EFF.regen_frac * T1.neg_en_at_whl * (EFF.mot2wheel_eff * EFF.mot_eff * EFF.ess_eff);

% Total energy (electrochemical) needed at ESS (in Wh/km)
EN.en_net_req_ess = EN.en_prop_req_ess + EN.en_reg_recap_ess;

% Total usable energy capacity needed for 50 km of All-Electric Range (in kWh)
T2.dist_AER = const_v*time2meet/1000; %in km
EN.en_cap_usable = EN.en_net_req_ess*T2.dist_AER/1000; % in kWh

% Total ESS energy capacity required (in kWh, round UP to nearest integer)
T2.ess_capacity = ceil(EN.en_cap_usable / EFF.usable_energy_frac);

%-----------------end------------------
end