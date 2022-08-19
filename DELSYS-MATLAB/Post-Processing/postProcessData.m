%% load experiment data
clear all
close all  
clc
%%
% load EMG data from files
date_key = '081622';
subject_num = "1";

emg_norm =subject_num + '_emg_struct_' + date_key+ "_1";
load(emg_norm,"emg_struct_raw");

%load IMU data from files
imu_norm = subject_num + '_imu_struct_' + date_key+"_1";
load(imu_norm,"imu_struct_raw");

emg_struct = emg_struct_raw;
imu_struct = imu_struct_raw;

maxfname =subject_num+ "max_vol_contraction_081522"; %+date_key;

%% filtering imu and EMG data
% filtering imu data
imu_setting.band = 0;
imu_setting.calibrate = 1;
imu_setting.linear_env.flag = 1;
imu_setting.linear_env.butterorder = 1;
imu_setting.linear_env.fc = 1;
imu_setting.integrate = 0;
imu_setting.flip = 1;
imu_struct = preprocessIMU(imu_struct,imu_setting);
%%
% filtering emg data
emg_setting.band.flag = 1;
emg_setting.band.bandrange = [20,500];
emg_setting.rectify = 1;
emg_setting.linear_env.flag = 1;
emg_setting.linear_env.butterorder = 2;
emg_setting.linear_env.fc = 5;
emg_struct = preprocessEMG(emg_struct,emg_setting);

%% find max voluntart contraction for normalization
emg_setting.max_avg_flag = 1;
max_emg_struct = findMaxVolContraction(maxfname,emg_setting);
%% extract heel strikes
hs_setting.sensorL = 3;%12; % 2 or 11 % 3 old code
hs_setting.sensorR = 6;
hs_setting.min_separation = [0.9,1.3,1.3];%[0.9,1.2,1.4]
% hs_setting.min_separation =1.2;
emg_struct = heelStrikeIMU(imu_struct,emg_struct,hs_setting);

%% use extracted heel strikes to identify steps
step_setting.time_last_step = [0,0,0,0];%[2,0.5,0.5,0.5];
emg_step_struct = findGaitCycle(emg_struct,step_setting);

%%
% remove outlier steps
plotbool = 0;
emg_step_struct = removeDurationOutlier(emg_step_struct,plotbool);
%% normalize/interpolate data using max voluntary contraction
max_ch_order = [1,2,3,4,6,5];%[1,3,5,6,2,4];%[1,2,3,4,6,5];
no_max_flag = 0; %set this to 1 if there's no corresponding max file for this experiment
emg_step_struct = normalizeEMG(emg_step_struct,max_emg_struct,max_ch_order,no_max_flag);

color1 = [209,66,0]/255;
color2 = [0.4660 0.6740 0.1880];
color3 = [0 0.4470 0.7410];

%%
plot_setting.type = 'avg';
plot_setting.tr_idx = [1];
plot_setting.color = {color1,color2,color3};
% 2,1,4 for muscle nomuscle flatmuscle
plot_setting.transp = 0.08;
plot_setting.ch_pos = [1,2,3,4,5,6];
plot_setting.sen_num = 1;
plot_setting.save = 1;
plot_setting.titles = {'Left GAS','Left TA','Left SOL', 'Right TA','Right GAS','Right SOL'};
plot_setting.legend= {'normal'};
plot_setting.legend_flag = 0;
plot_setting.fold = fullfile(fileparts(pwd),'EMG_plots');
plot_setting.fname= append('sub',num2str(subject_num),'EMG.png');
plotTrialfromStruct(emg_step_struct,plot_setting);
