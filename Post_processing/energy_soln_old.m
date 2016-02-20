% energy_soln.m
% Purdue NeXT - HEV Course Project
% Power and Energy Calculations m-file - with solutions
% Author: APV (03/28/2015)

% Complete this function to calculate the energy/power requirements for the
% drivetrain. 

% Do not change the number, name or type of any of the input and output
% parameters for the functions or the name of the function itself, as the 
% verification of your code will be automated. Unless specified as arrays 
% the output variables are single values). Apart from these, you can add 
% any variables or modify the code in any way you like.

% Sign convention: power/energy out of the vehicle is +ve, pwoer/energy into
% the vehicle is -ve.

function [T1, P_tr, P_in, P_rr, P_aero] = energy_soln(t,v,M_veh,Cd_Af,C1,C2,g,rho,theta,flag_grade)

n = length(t);                  % n = length of time vector
for i=1:1:n-1
    accn(i) = v(i+1) - v(i);    % Acceleration (in m/s2 ; 1xn array)
end
accn(i+1) = 0;

dist = sum(v);                          % Distance (in m)


%----------- your code begins here------------

F_in = accn.*M_veh;                     % Inertial force (in N; 1xn array)
P_in = F_in.*v;                         % Inertial Power (in W; 1xn array)
P_rr = M_veh*g*(C1+(C2*v)).*v;          % Rolling Resistance Power (in W; 1xn array)
P_aero = (1/2)*rho*Cd_Af.*(v.*v.*v);    % Aerodynamic Drag Power (in W; 1xn array)
P_theta = M_veh*g*sin(theta)*flag_grade;% Grade Power only present if grade flag =1 other wise 0
P_mechacc = 6000;
P_tr = P_in + P_rr + P_aero+P_theta+P_mechacc;    % Tractive propulsion/braking power requirement from drivetrain/brakes (in W; 1xn array)

    %% Moving Average filter 3 point
    for k = 2:length(t)-1
        P_tr(k) = (P_tr(k-1)+P_tr(k)+P_tr(k+1))/3;
    end
    
    %%
Energy_pos = sum(P_tr.*(P_tr>0));       % in Ws
Energy_neg = sum(P_tr.*(P_tr<0));       % in Ws
peak_pos_pwr = max(P_tr)/1000;          % in kW
peak_neg_pwr = min(P_tr)/1000;          % in kW
avg_pos_pwr = Energy_pos/t(end)/1000;   % in kW
avg_neg_pwr = Energy_neg/t(end)/1000;   % in kW

% Output for Table 1 (remember to convert to appropriate units)
% These are requirements that the drivetrain needs to satisfy.
% Propulsion is when P_tr > 0, Braking/Regen is when P_tr < 0.
% Where averaging is required, average over the entire drivecycle.

T1.pos_en_at_whl = Energy_pos/3600/dist*1000;                     % Positive (Propulsion) Energy required at wheels (in Wh/km)
T1.neg_en_at_whl = Energy_neg/3600/dist*1000;                     % Negative (Braking) Energy required at wheels (in Wh/km)
T1.net_en_at_whl = (Energy_pos + Energy_neg)/3600/dist*1000;      % Net Energy required at wheels (in Wh/km)
T1.avg_pos_pwr_prop = avg_pos_pwr;                      % Average positive (propulsion) power required at the wheels (kW) 
T1.avg_neg_pwr_reg = avg_neg_pwr;                       % Average negative (regen) power required at the wheels (kW)
T1.peak_pos_pwr_prop = peak_pos_pwr;                    % Peak positive (propulsion) power required at the wheels (kW)
T1.peak_neg_pwr_reg = peak_neg_pwr;                     % Peak negative (regen) power required at the wheels (kW)

%-----------------end------------------
end
