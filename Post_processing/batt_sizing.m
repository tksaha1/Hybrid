% Battery Sizing code @ 25 deg celcius temp
%function [ pack_Pmax_prop,pack_kWh_cap,pack_Pmax_prop ] = batt_sizing( soc,num_p,num_s )
close all
clear all

%ess_plant_li_4_32_Chevrolet_Malibu_2013;
%ess_plant_li_5_72_Hyundai_Sonata_2011;
ess_plant_li_66_192_Nissan_Leaf;
%ess_plant_li_8_8_Cummins_XJ;
%ess_plant_li_17_384_EnerDel;
%ess_plant_li_45_288_Chevrolet_Volt_2013;
%ess_plant_nicd_102_125;
%ess_plant_nimh_93_275;
%ess_plant_nizn_22_196_evercell;


% function [] = batt_sizing(varargin)
% 
% for n=1:nargin
%     run(varargin{n})

%Constants
soc = 0.5; % input state of charge
num_p = 2; % # of cell in parallel
num_s = 1:5:700; % # of cell in series


% getting data
Vmax = ess.plant.init.volt_max;
Vnom = ess.plant.init.volt_nom;
Vmin = ess.plant.init.volt_min;
Voc_nom = interp1(ess.plant.init.voc.idx2_soc,ess.plant.init.voc.map(2,:),soc); % nominal open circuit voltage
Rint_dis = interp1(ess.plant.init.rint_dis.idx2_soc,ess.plant.init.rint_dis.map(2,:),soc);
Rint_chg = interp1(ess.plant.init.rint_chg.idx2_soc,ess.plant.init.rint_chg.map(2,:),soc);
%Rint_nom = Rint_dis; %+ Rint_chg)/2; % nominal internal resistance
Ah_cap = ess.plant.init.cap_max.map(2);

% Battery Calculations
tot_cell  = num_p*num_s;
pack_volt = num_s*Vnom;

pack_Ah_cap = Ah_cap*num_p;
pack_kWh_cap = pack_Ah_cap*pack_volt/1000;

%% Min max voltage way for power calculation
cell_Pmax_prop_v = (Voc_nom-Vmin)*Vmin*0.001/Rint_dis;
pack_Pmax_prop_v = cell_Pmax_prop_v*tot_cell;
cell_Pmax_regen_v = (Vmax-Voc_nom)*Vmax*0.001/Rint_chg;
pack_Pmax_regen_v = cell_Pmax_regen_v*tot_cell;
pack_curr = pack_Pmax_prop_v*1000/pack_volt;

% C_rate power calc
C_rate = [8];
cell_Pmax_prop_c = (Voc_nom -(C_rate*Ah_cap*Rint_dis)).*C_rate*Ah_cap/1000;
pack_Pmax_prop_c = cell_Pmax_prop_c*tot_cell;
cell_Pmax_regen_c = (Voc_nom +(C_rate*Ah_cap*Rint_dis)).*C_rate*Ah_cap/1000;
pack_Pmax_regen_c = cell_Pmax_regen_c*tot_cell;

%% Power calculation consideration
pack_Pmax_prop = min(pack_Pmax_prop_c,pack_Pmax_prop_v);
pack_Pmax_regen = min(pack_Pmax_regen_c,pack_Pmax_regen_v);

%% Find E/kg and P/kg points for ragone plot
P_rag = [cell_Pmax_prop_v;cell_Pmax_prop_c]/ess.plant.init.mass_cell*1000
E_rag = [pack_kWh_cap/ess.plant.init.mass_cell/tot_cell ; pack_kWh_cap/ess.plant.init.mass_cell/tot_cell]*1000

%% Cost Calculation
cost_kW = 22;
cost_kWh = 500;
cost_fixed = 680;
cost_pack = cost_kW*pack_Pmax_prop_v + cost_kWh*pack_kWh_cap + cost_fixed;

%% Drivecycle energy requirement
filename = 'NY Composite Truck';
[E1,P1,Ptr_NY] = get_energy_point(filename,3,35); % filename, (best=1,nom=2,worst=3),AER dist
filename = 'HTUF PD Class 6 Truck';
[E2,P2,Ptr_C6] = get_energy_point(filename,3,35);
filename = 'HTUF Refuse Truck';
[E3,P3,Ptr_RT] = get_energy_point(filename,3,35);
%% Plots
figure(5)
loglog(P1,E1,'b*',P2,E2,'r*',P3,E3,'c*',pack_Pmax_prop,pack_kWh_cap,'k--',pack_Pmax_prop,pack_kWh_cap,'g-.',P_rag,E_rag,'r*');
set(gca,'FontSize',16)
title('Capacity vs Power');
ylabel('Energy Capacity [kWh]');xlabel('Pack Power [kW]'); 
legend ('NYComp','Class6 PD','HTUF Refuse','Nissan Leaf','NL-4C','NL_8C')
xlim([0 10000]);ylim([0 1000]);
grid on
hold on

% figure(6)
% loglog(P1,E1,'b*',P2,E2,'r*',P3,E3,'c*',pack_Pmax_regen,pack_kWh_cap,'k--',pack_Pmax_regen(1,:),pack_kWh_cap,'g-.',pack_Pmax_regen(2,:),pack_kWh_cap);
% set(gca,'FontSize',16)
% title('Capacity vs Power');
% ylabel('Energy Capacity [kWh]');xlabel('Pack Power [kW]'); 
% legend ('NYComp','Class6 PD','HTUF Refuse','Nissan Leaf','NL-4C rate','NL-8C rate')
% xlim([0 10000]);ylim([0 1000]);
% grid on
% hold on
%% Report
% fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%% REPORT %%%%%%%%%%%%%%%%%%%%%%%%%%\n')
% fprintf('\n#Cells   Vpack   Pmax(cell)   Pmax(pack)  Ah_Cap(pack) kWh_Cap(pack)\n')
%fprintf('%3.3f  %3.3f  %3.3f       %3.3f     %3.3f       %3.3f\n',tot_cell,pack_volt,cell_Pmax,pack_Pmax,pack_Ah_cap,pack_kWh_cap)

