function struct_EMG = heelStrikeIMU(struct,struct_EMG,setting)
% This function identifies the heel strikes using the local maximas in the
% x_IMUs.
%  It looks at the acceleration in Y of filtered IMU values should be 2 or
%  11
chL = setting.sensorL;
chR = setting.sensorR;
min_separation = setting.min_separation;
if size(min_separation,2) == 1
    min_separation = ones(1,size(struct.channel{chL}.filtered,2)) * min_separation;
    min_separation = ones(1,size(struct.channel{chR}.filtered,2)) * min_separation;
end
samplerate_EMG = struct_EMG.channel{1}.samplerate;
samplerateL = struct.channel{chL}.samplerate;
samplerateR = struct.channel{chR}.samplerate;
%for tr = 1:size(struct.channel{ch}.filtered,2)
dataL = struct.channel{chL}.filtered;
dataR = struct.channel{chR}.filtered;
%     warning('signed flipped')
x_IMU_L = linspace(0,size(dataL, 2)/samplerateL, size(dataL, 2));
x_IMU_R = linspace(0,size(dataR, 2)/samplerateR, size(dataR, 2));
clear hs_trial
hs_trial.tL = x_IMU_L(islocalmax(dataL,'SamplePoints', x_IMU_L, 'MinSeparation', min_separation(1))& dataL>mean(dataL));
hs_trial.tR = x_IMU_R(islocalmax(dataR,'SamplePoints', x_IMU_R, 'MinSeparation', min_separation(1))& dataR>mean(dataR));
if size(hs_trial.tL,2) > 1
    for i = 1:size(hs_trial.tL)
        if hs_trial.tL(i) > 7
            hs_trial.tL = hs_trial.tL(1:i-1);
            break;
        end
    end
end

if size(hs_trial.tR,2) > 1
    for i = 1:size(hs_trial.tR)
        if hs_trial.tR(i) > 7
            hs_trial.tR = hs_trial.tR(1:i-1);
            break;
        end
    end
end

hs_trial.sensorL = chL;
hs_trial.sensorR = chR;
hs_trial.indexL = round(hs_trial.tL.*samplerate_EMG);
hs_trial.indexR = round(hs_trial.tR.*samplerate_EMG);

struct_EMG.hs = hs_trial;
end
