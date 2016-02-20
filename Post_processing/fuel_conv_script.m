% Calculate convention vehicle fuel consumption for post processing
% comparison purposes.
% Filename: fuel_conv_script

% use conv_pdclass6_simresults.xlsx file for more analysis

% Written by Tridib Saha 9/2/15

%Update Log: 2/19/2016 - Cleaned up plus added vehicle feature!

clear all
%% Load sim data final
%load('HEVO2_Data_Main');

%% Constants
num_sim = 3;            % number of simulations (best, nominal and worst)
g = 9.81;               % Accn. due to gravity (m/s^2)
rho = 1.1985;           % Density of air (kg/m^3)from autonomie at 20C
C2 = 0.00012;           % C2 is held constant for all simulation
theta = 0;              % no grade consideration
filt_flag = 1;          % 3 point filter on


%% %%%%%%%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vehicle_type = 2; % (1-Truck; 2-Bus)

% Tuning Pmech Accesory & Efficiency values
if vehicle_type == 1
    P_mechacc = 8600;                               % Mechanical accessory power tuning
    Eff_mult = 1;                                   % Efficiency tuning factor 
    Eff = [(36.64+2.43) (35.58-5.86) (32.6-7.01)]/100*Eff_mult;    % Truck from engine efficiency
elseif vehicle_type == 2
    P_mechacc = 18800;                              % mechanical accessory power tuning
    Eff_mult = 1;                                   % efficiency tuning factor 
    Eff = [(33.67-5.094) (36.25-4.89) (32.95-0.621) (35.27-4.019)]/100*Eff_mult; % Bus from engine efficiency
else
    fprintf('Error in Vehicle type!!!!')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% VEHICLE PARAMETERS

if vehicle_type == 2
    % BUS FC Conce from Autonomie
    FC_Auto = [99.02 65.09 59.9 76.05; 89.77 57.63 54.41 68.03; 80.35 50.46 49.32 60.4];
    
    % BUS Drivecylces
    load ('Manhattan');
    DC{1}.t = sch_cycle(:,1)';
    DC{1}.v = sch_cycle(:,2)';
    load ('Orange County');
    DC{2}.t = sch_cycle(:,1)';
    DC{2}.v = sch_cycle(:,2)';
    load ('China Normal');
    DC{3}.t = sch_cycle(:,1)';
    DC{3}.v = sch_cycle(:,2)';
    load ('China Aggressive');
    DC{4}.t = sch_cycle(:,1)';
    DC{4}.v = sch_cycle(:,2)';
    
    % Bus Noise Parameters
    num_DC = 4; % number of drivecycles
    C1_x = [0.007 0.006 0.005]';
    Cd_x = [0.88	0.72	0.58]';
    Af_x = [7.1 7.1 7.1];
    Mv_x = [18000	15000	12000];
    
elseif vehicle_type == 1
    % Truck FC from Autonomie
    FC_Auto = [41.12 56.23 52.37; 34.06 47.69 45.4; 27.37 39.39 38.55];
    
    % TRUCK Drivecycles
    load ('HTUF PD Class 6 Truck');
    DC{1}.t = sch_cycle(:,1)';
    DC{1}.v = sch_cycle(:,2)';
    load ('HTUF Refuse Truck');
    DC{2}.t = sch_cycle(:,1)';
    DC{2}.v = sch_cycle(:,2)';
    load ('NY Composite Truck');
    DC{3}.t = sch_cycle(:,1)';
    DC{3}.v = sch_cycle(:,2)';
    
    % Truck Noise Parameters
    num_DC = 3; % number of drivecycles
    C1_x = [0.008 0.007 0.006]';
    Cd_x = [0.94	0.76	0.58]';
    Af_x = [9 9 9];
    Mv_x = [15000	11925	8850];
else
    fprintf('Error in Vehicle type!!!!')
end


%% Loop for fuel consumption data
% initializing
fuel_consumed = zeros(num_sim,num_DC); 

% loop calculation
for n = 1:num_DC
    for k = 1:num_sim
        % Extract and update vehicle parameters
        C1 = C1_x(k);
        Cd = Cd_x(k);
        Af = Af_x(k);
        Mv = Mv_x(k);
        Cd_Af = Cd*Af;
        
        %Call energy solution to get energy info
        [T1(k,n)] = energy_soln(DC{n}.t,DC{n}.v,Mv,Cd_Af,C1,theta,filt_flag,P_mechacc);
        
        %Calculate fuel consumption
        Pos_energy_at_wheel = T1(k,n).pos_en_at_whl; %Wh/km
        fuel_consumed(k,n) = Pos_energy_at_wheel/Eff(n); % in Wh/km
        
    end
end
%% Fuel Consumed in L/100km
FC_Conv = fuel_consumed/98.5764; % Wh/km to L/100km

%% Other Calc
Diff = abs(FC_Auto-FC_Conv);
Per_Diff = (Diff./FC_Auto)*100;

if vehicle_type == 1
    Sum = [sum(Per_Diff(:,1)) sum(Per_Diff(:,2)) sum(Per_Diff(:,3))]
elseif vehicle_type == 2
   Sum = [sum(Per_Diff(:,1)) sum(Per_Diff(:,2)) sum(Per_Diff(:,3)) sum(Per_Diff(:,4))]
else
    fprintf('Error in Vehicle type!!!!')
end


