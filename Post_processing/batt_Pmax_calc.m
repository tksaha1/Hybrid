function [ pack_Pmax_prop ] = batt_Pmax_calc( ess )
% getting data
soc = ess.soc;
num_p = ess.num_p;
num_s = ess.num_s;
Vmax = ess.Vmax;
Vnom = ess.Vnom;
Vmin = ess.Vmin;
Voc_nom = ess.Voc_nom; % nominal open circuit voltage
Rint_dis = ess.Rint_dis;
Rint_chg = ess.Rint_chg;
Ah_cap = ess.Ah_cap;

% Battery Calculations
tot_cell  = num_p*num_s;
pack_volt = num_s*Vnom;

pack_Ah_cap = Ah_cap*num_p;
pack_kWh_cap = pack_Ah_cap*pack_volt/1000;

%% Min max voltage way for power calculation
cell_Pmax_prop_v = (Voc_nom-Vmin)*Vmin*0.001/Rint_dis;
pack_Pmax_prop_v = cell_Pmax_prop_v*tot_cell;
% cell_Pmax_regen_v = (Vmax-Voc_nom)*Vmax*0.001/Rint_chg;
% pack_Pmax_regen_v = cell_Pmax_regen_v*tot_cell;
pack_curr = pack_Pmax_prop_v*1000/pack_volt;

% C_rate power calc
C_rate = ess.C_rate;
cell_Pmax_prop_c = (Voc_nom -(C_rate*Ah_cap*Rint_dis)).*C_rate*Ah_cap/1000;
pack_Pmax_prop_c = cell_Pmax_prop_c*tot_cell;
% cell_Pmax_regen_c = (Voc_nom +(C_rate*Ah_cap*Rint_dis)).*C_rate*Ah_cap/1000;
% pack_Pmax_regen_c = cell_Pmax_regen_c*tot_cell;

%% Power calculation consideration
pack_Pmax_prop = min(pack_Pmax_prop_c,pack_Pmax_prop_v);
% pack_Pmax_regen = min(pack_Pmax_regen_c,pack_Pmax_regen_v);
end