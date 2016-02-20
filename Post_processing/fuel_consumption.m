function [ fuel_consumed ] = fuel_consumption( T1,Eff )
% Calculate Fuel consumption
% 
% Output fuel consumed
% Input   T1 = output of energy_soln.m with positive power on wheel values
%         Eff = Efficiency structure that contains:
%                 1. Transmission eff
%                 2. Final drive efficiency
%                 3. Engine Efficiency

% Define values:
Pos_energy_at_wheel = T1.pos_en_at_whl; %Wh/km

fuel_consumed = Pos_energy_at_wheel/Eff; % in Wh/km

end

