% This file gets you power vs energy point using the following inputs:

% filename, (best=1,nom=2,worst=3),AER dist

function [ESS_energy,ESS_power,P_tr] = get_energy_point(filename,case_par,AER_dist)
%% Parameters
mph2ms = 1600/3600; % miles per hour to meters per second conversion

% Load drive cycle data
%filename = 'NY Composite Truck';
%filename = 'HTUF PD Class 6 Truck';
%filename = 'HTUF Refuse Truck';

load(filename);
t = sch_cycle(:,1)';          % time vector

%% non Grade considerations
gradability = '';
%v = mph2ms*us06(:,2)';  % velocity vector if given in mph
v = sch_cycle(:,2)';          % velocity vector
time_flag = 1;
const_v = AER_dist; time2meet = 1000; % in km


% Vehicle parameters
if case_par == 1
     %% Best Case
    Case_word = 'Best Case';
    M_veh = 8850;          % Total vehicle weight (kg)
    g = 9.8;                % Accn. due to gravity (m/s^2)
    rho = 1.275;            % Density of air (kg/m^3)
    Cd = 0.65 ;
    Af = 8;
    Cd_Af = Cd*Af;         % Drag Coefficient * Frontal Area (m^2)
    %Crr = 0.009;           % Coeff. of Rolling Resistance
    C1 = 0.006; %Crr
    C2 = 3.72e-04;
elseif case_par == 2
    %% Nominal Case
    Case_word = 'Nominal Case';
    M_veh = (8850+15000)/2;          % Total vehicle weight (kg)
    g = 9.8;                % Accn. due to gravity (m/s^2)
    rho = 1.275;            % Density of air (kg/m^3)
    Cd = (0.65+0.85)/2 ;
    Af = (8+10)/2;
    Cd_Af = Cd*Af;         % Drag Coefficient * Frontal Area (m^2)
    %Crr = 0.009;           % Coeff. of Rolling Resistance
    C1 = (0.006+0.008)/2; %Crr
    C2 = 3.72e-04;
else
    %% Worst Case
    Case_word = 'Worst Case';
    M_veh = 15000;          % Total vehicle weight (kg)
    g = 9.8;                % Accn. due to gravity (m/s^2)
    rho = 1.275;            % Density of air (kg/m^3)
    Cd = 0.85 ;
    Af = 10;
    Cd_Af = Cd*Af;         % Drag Coefficient * Frontal Area (m^2)
    %Crr = 0.009;           % Coeff. of Rolling Resistance
    C1 = 0.008; %Crr
    C2 = 3.72e-04;
end
% 
% %% grade considerations
% gradability = 'Gradability';
% const_v = 60*mph2ms; %in m/s
% time2meet = 20*60; %seconds 
% 
% v=ones([1 length(t)])*const_v;
% grade = 2; %percent
% theta = atan(grade/100); % rad
% flag_grade = 1; % 1 to consider or 0 to not consider grade

%% Efficiency assumptions
EFF.mot2wheel_eff = 0.98;           % Efficiency of conversion between mechanical power @ motor and mechanical power @ wheels
EFF.mot_eff = 0.9;                  % Efficiency of conversion between electrical power and mechanical power @ motor
EFF.ess_eff = 0.96;                 % Efficiency of conversion between electrical and electrochemical power @ ESS  
EFF.gen2mot_eff = (EFF.ess_eff)^2;  % Efficiency of conversion from electrical power @ generator to electrical power @ motor (this assumes that all the power goes through the ESS)
EFF.gen_eff = 0.9;                  % Efficiency of conversion from mechanical power to electrical power @ generator
EFF.eng_eff = 0.45;                 % Average brake thermal efficiency of ICE (i.e. fuel energy to mechanical energy)
EFF.regen_frac = 0.8;               % Fraction of braking energy @ wheels that is available for regenerative braking
EFF.usable_energy_frac = 0.7;       % Fraction of energy capacity of ESS that is available for use in vehicle operation
EFF.elec_AC2DC_eff = 0.95;          % Efficiency of AC to DC conversion for grid-charging of battery

% WTW calculation parameters
WTW.UF_60km = 0.627;                % Utility Factor for a CD Range of 60km = 37.5 miles
WTW.wtw_ghg_coeff_fuel = 288;       % Well-to-wheel Green-House Gas emissions coefficient for fuel (g/kWh)
WTW.wtw_peu_coeff_fuel = 0.859;     % Well-to-wheel Petroleum Energy Use coefficient for fuel (kWh PE/kWh)
WTW.wtw_ghg_coeff_elec = 648.3;     % Well-to-wheel Green-House Gas emissions coefficient for grid electricity (g/kWh)
WTW.wtw_peu_coeff_elec = 0.034;     % Well-to-wheel Petroleum Energy Use coefficient for grid electricity (kWh PE/kWh)
WTW.gas_en_den = 34.02;             % Energy density of gasoline (kWh/US gallon)
WTW.fuel_tank_cap = 350;            % Energy capacity of fuel tank (in kWh)

grade=2;
theta = atan(grade/100); % rad
flag_grade = 0; % 1 to consider or 0 to not consider grade
% Q1 - Calculation of energy and power required at wheels - i.e. Table 1

[T1,P_tr,P_in,P_rr,P_aero] = energy_soln(t,v,M_veh,Cd_Af,C1,C2,g,rho,theta,flag_grade);

% Q2 - Powertrain Component Sizing for Series PHEV - i.e. Table 2

[T2,EN] = sizing_soln(T1,EFF,const_v,time2meet);

% Q3 - Well-to-Wheel Analysis for the Series PHEV - i.e. Table 3 & 4

%[CD,CS,UF] = wtw_soln(T1,T2,EFF,WTW,EN);

%% Output
ESS_energy = T2.ess_capacity;
ESS_power = T2.mot_peak_pwr/0.9; % divide by assumed motor efficienty


% Useful Data Printing
%plot (v,P_tr,'b*');
fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
fprintf('\nDrivecycle: %s (%s %s)',filename, gradability,Case_word);
fprintf('\n                    Prop         Regen         Net \n');
fprintf('Energy[Wh/km]       %4.2f       %4.2f         %4.2f\n',T1.pos_en_at_whl,T1.neg_en_at_whl,T1.net_en_at_whl);
fprintf('Avg. Power[kW]      %4.2f        %4.2f      \n',T1.avg_pos_pwr_prop,T1.avg_neg_pwr_reg);
fprintf('Peak Power[kW]      %4.2f        %4.2f      \n\n',T1.peak_pos_pwr_prop,T1.peak_neg_pwr_reg);


fprintf('ESS Energy required to meet Propulsion =         %4.2f Wh/km\n',EN.en_prop_req_ess);
fprintf('ESS Energy recaptured from braking =             %4.2f Wh/km\n',EN.en_reg_recap_ess);
fprintf('ESS Energy needed =                              %4.2f Wh/km\n',EN.en_net_req_ess);
fprintf('ESS Usable Energy for %2.2f km AER =             %4.2f kWh\n\n',T2.dist_AER,EN.en_cap_usable);

fprintf('Motor Peak Power =             %3.2f kW / %3.2f kW\n',T2.mot_peak_pwr,T2.mot_peak_pwr_reg);
fprintf('Generator Continuous Power =   %3.2f kW\n',T2.gen_cont_pwr);
fprintf('Engine Optimal Power =         %3.2f kW\n',T2.eng_opt_pwr);
fprintf('ESS capacity required =        %3.2f kWh\n\n',T2.ess_capacity);


%---------------------------------END-------------------------------------%


