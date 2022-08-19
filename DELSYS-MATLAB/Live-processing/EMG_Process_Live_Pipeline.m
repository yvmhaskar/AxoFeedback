%% EMG Process Live Pipeline

%% Initialization
clear ;
close all;
clc;

Muscle = ["Muscle1", "Muscle2"];

data = live_stream_plot_outputEMG();

for i=1:size(data)
        OutputEMG.channel{i} = i;
        OutputEMG.channel{i}.raw_emg = data(i);
        OutputEMG.channel{i}.samplerate = 0.1;
        OutputEMG.channel{i}.muscle = Muscle(i);
end

%% Filtering EMG Data
emg_setting.band.flag = 1;
emg_setting.band.bandrange = [20,500];
emg_setting.rectify = 1;
emg_setting.linear_env.flag = 1;
emg_setting.linear_env.butterorder = 2;
emg_setting.linear_env.fc = 5;
emg_struct = preprocessEMG(RawEMG,emg_setting);

%% Find max voluntart contraction for normalization
emg_setting.max_avg_flag = 1;
max_emg_struct = findMaxVolContraction(emg_struct,emg_setting);

%% extract heel strikes
hs_setting.left_leg_sensor = 12; % 2 or 11 % 3 old code
hs_setting.right_leg_sensor = 3;
hs_setting.time_last_step = 0.0;
hs_setting.min_separation = 0.9;%[1,1,1,1.5,1.5,1.5,1.5];%[1,1.7,1.2,0.91,0.91,0.9,1.1];
%hs_setting.min_separation =1.2;
emg_struct = heelStrikeBLIMU(imu_struct,emg_struct,hs_setting);