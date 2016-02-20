% energy_soln.m
% Power and Energy Calculations m-file 
% Author: APV (03/28/2015)

% Sign convention: power/energy out of the vehicle is +ve, pwoer/energy into
% the vehicle is -ve.

% Change log:
% 1/26/16- TKS added few minor calulation to T1 like max and avg speed and
% acceleration for table purposes
% 2/11/16 - TKS - corrected distance and power value to account for time
% step. (big change for china aggressive drivecycle which has a time step
% of 0.2)

function [T1] = energy_soln(t,v,M_veh,Cd_Af,Crr,theta,filt_flag,P_mechacc)

% constants
g = 9.81;                   % Accn. due to gravity (m/s^2)
rho = 1.1985;               % Density of air (kg/m^3) from autonomie for 20C
C2 = 0.00012;               % Value from Autonomie

n = length(t);              % n = length of time vector
for i=1:1:n-1
    tstep(i)= t(i+1)-t(i); % timestep
    accn(i) = (v(i+1) - v(i))/tstep(i);    % Acceleration (in m/s2 ; 1xn array)
end
accn(i+1) = 0; % assuming no acceleration at the end of drivecycle
tstep(i+1)=tstep(i); % time step is the same for last data

dist = sum(v.*tstep);                    % Distance (in m)

F_in = accn.*M_veh;                                     % Inertial force (in N; 1xn array)
P_in = F_in.*v;                                         % Inertial Power (in W; 1xn array)
P_rr = M_veh*g*(Crr+(C2*v)).*v;                         % Rolling Resistance Power (in W; 1xn array)
P_aero = (1/2)*rho*Cd_Af.*(v.*v.*v);                    % Aerodynamic Drag Power (in W; 1xn array)
P_theta = M_veh*g*sin(theta).*v;                        % Grade Power
P_tr = P_in + P_rr + P_aero + P_theta + P_mechacc;      % Tractive propulsion/braking power requirement from drivetrain/brakes (in W; 1xn array)

%% Moving Average filter 3 point
if filt_flag == 1
    for k = 2:length(t)-1
        P_tr(k) = (P_tr(k-1)+P_tr(k)+P_tr(k+1))/3;
    end
else
end
    
%% Calculations
Energy_pos = sum(P_tr.*(P_tr>0).*tstep);       % in Ws
Energy_neg = sum(P_tr.*(P_tr<0).*tstep);       % in Ws
peak_pos_pwr = max(P_tr)/1000;          % in kW
peak_neg_pwr = min(P_tr)/1000;          % in kW
avg_pos_pwr = Energy_pos/t(end)/1000;   % in kW
avg_neg_pwr = Energy_neg/t(end)/1000;   % in kW


% These are requirements that the drivetrain needs to satisfy.
% Propulsion is when P_tr > 0, Braking/Regen is when P_tr < 0.


T1.pos_en_at_whl = Energy_pos/3600/dist*1000;                     % Positive (Propulsion) Energy required at wheels (in Wh/km)
T1.neg_en_at_whl = Energy_neg/3600/dist*1000;                     % Negative (Braking) Energy required at wheels (in Wh/km)
T1.net_en_at_whl = (Energy_pos + Energy_neg)/3600/dist*1000;      % Net Energy required at wheels (in Wh/km)
T1.avg_pos_pwr_prop = avg_pos_pwr;                      % Average positive (propulsion) power required at the wheels (kW) 
T1.avg_neg_pwr_reg = avg_neg_pwr;                       % Average negative (regen) power required at the wheels (kW)
T1.peak_pos_pwr_prop = peak_pos_pwr;                    % Peak positive (propulsion) power required at the wheels (kW)
T1.peak_neg_pwr_reg = peak_neg_pwr;                     % Peak negative (regen) power required at the wheels (kW)
T1.P_prop = P_tr.*(P_tr>0);                             % Only Propulsion power requirement values in P_tr; all others 0
T1.P_reg = P_tr.*(P_tr<0);                              % Only Regeneration power requirement vallues in P_tr; all others 0

% Other useful outputs
T1.P_tr = P_tr;
T1.P_in = P_in;
T1.P_aero = P_aero;
T1.P_theta = P_theta;
T1.max_spd = max(v);
T1.max_acc = max(accn);
T1.avg_spd = sum(v)/(length(t));
T1.tstep = tstep;
T1.dist = dist;

%-----------------end------------------
end
