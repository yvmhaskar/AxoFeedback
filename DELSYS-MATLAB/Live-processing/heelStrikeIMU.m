function struct_EMG = heelStrikeIMU(struct,struct_EMG,setting)
% This function identifies the heel strikes using the local maximas in the
% x_IMUs.
%  It looks at the acceleration in Y of filtered IMU values should be 2 or
%  11
chL = 3*setting.sensorL-1;
chR = 3*setting.sensorR-1;
min_separation = setting.min_separation;
if size(min_separation,2) == 1
    min_separation = ones(1,size(struct.channel{chL}.filtered,2)) * min_separation;
end
samplerate_EMG = struct_EMG.channel{1}.samplerate;
samplerate = struct.channel{chL}.samplerate;
dataL = struct.channel{chL}.filtered;
dataR = struct.channel{chR}.filtered;

% This is the IMU data of the heel strike identifier sensors.
x_IMU_L = linspace(0,size(dataL, 2)/samplerate, size(dataL, 2));
x_IMU_R = linspace(0,size(dataR, 2)/samplerate, size(dataR, 2));

clear hs_trial
hs_trial.tL = x_IMU_L(islocalmax(dataL,'SamplePoints', x_IMU_L, 'MinSeparation', min_separation(1))& dataL>mean(dataL));
hs_trial.tR = x_IMU_R(islocalmax(dataR,'SamplePoints', x_IMU_R, 'MinSeparation', min_separation(1))& dataR>mean(dataR));

% The below loops make sure that the recorded times are below 7 seconds.
if size(hs_trial.tL,2) > 1
    for i = 1:size(hs_trial.tL)
        if hs_trial.tL(i) > 6
            hs_trial.tL = hs_trial.tL(1:i-1);
            break;
        end
    end
end

if size(hs_trial.tR,2) > 1
    for i = 1:size(hs_trial.tR)
        if hs_trial.tR(i) > 6
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
