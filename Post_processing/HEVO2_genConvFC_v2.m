%% HEVO2_genConvFC_v2
% Tridib Saha 9/2/15

% Calculate convention vehicle fuel consumption for post processing
% comparison purposes.
% Filename: fuel_conv_script

% Truck Convention
% Column 1 = HTUF PD Class 6 Truck
% Column 2 = HTUF Refuse Truck
% Column 3 = NY Composite Truck

% Bus Convention
% Column 1 = Manhattan
% Column 2 = Orange County
% Column 3 = China Mornal

% Change Log:
% v1 - 09/02/15 - Created
%    - 09/24/15 - Updated to package within lifecycleCalc and work with new
%    energy_soln script - APV
% v2 - 09/02/15 - Modified for vehicle type

%function [FC_Conv] = HEVO2_genConvFC_v2(L2D, N1)

if (L2D.SIM.vehTag == 1)
    %% Create the 3 drivecycle speed vs time matrix
    load ('HTUF PD Class 6 Truck');
    DC{1}.t = sch_cycle(:,1)';
    DC{1}.v = sch_cycle(:,2)';
    load ('HTUF Refuse Truck');
    DC{2}.t = sch_cycle(:,1)';
    DC{2}.v = sch_cycle(:,2)';
    load ('NY Composite Truck');
    DC{3}.t = sch_cycle(:,1)';
    DC{3}.v = sch_cycle(:,2)';


    % Efficiency tuning factors - These no.s were selected to give minimum
    % error across the best, nominal and worst case scenarios on comparing
    % energy model with Autonomie simulations.
    Eff = [29.78+6 27.58 (24.18-1.5)]/100;

    % Accessory power tuning factor
    P_mechacc = 6000;
    
elseif (L2D.SIM.vehTag == 2)
    %% Create the 3 drivecycle speed vs time matrix
    load ('Manhattan');
    DC{1}.t = sch_cycle(:,1)';
    DC{1}.v = sch_cycle(:,2)';
    load ('Orange County');
    DC{2}.t = sch_cycle(:,1)';
    DC{2}.v = sch_cycle(:,2)';
    load ('China Normal');
    DC{3}.t = sch_cycle(:,1)';
    DC{3}.v = sch_cycle(:,2)';


    % Efficiency tuning factors - These no.s were selected to give minimum
    % error across the best, nominal and worst case scenarios on comparing
    % energy model with Autonomie simulations.
    %Eff = [29.78+6 27.58 (24.18-1.5)]/100;
    Eff = [(17.45-0.6) (21.98-0.35) (17.87+1.1)]/100;
    
    % Accessory power tuning factor
    P_mechacc = 5000; 
else
    disp('Error in vehicle tag!')
end

%% Loop for fuel consumption data
N1 = 3;
num_DC = 3;                     % number of drivecycles
fuel_consumed = zeros(N1,num_DC);

C1_x = [0.007 0.006 0.005]';
Cd_x = [0.88	0.72	0.58]';
Af_x = [7.1 7.1 7.1];
Mv_x = [18000	15000	12000];

for i = 1:N1
    for j = 1:num_DC
        
        % Extract Vehicle parameters from sim data
        
        Crr = C1_x(i);
        Cd = Cd_x(i);
        Af = Af_x(i);
        M_veh = Mv_x(i);
        
%         Crr = L2D.L2DATA.Sim_Data(i,85);
%         Cd = L2D.L2DATA.Sim_Data(i,86);
%         Af = L2D.L2DATA.Sim_Data(i,87);
%         M_veh = L2D.L2DATA.Sim_Data(i,88);
        theta = 0;
        filt_flag = 1;
        
        % Call energy solution to get energy info
        [T1] = energy_soln(DC{j}.t,DC{j}.v,M_veh,Cd*Af,Crr,theta,filt_flag,P_mechacc);
        
        % Calculate fuel consumption
        Pos_energy_at_wheel = T1.pos_en_at_whl;         % in Wh/km
        fuel_cons(i,j) = Pos_energy_at_wheel/Eff(j);    % in Wh/km
        
    end
end
%%
FC_Conv = fuel_cons./98.5764; % Wh/km to L/100km

