%% preprocessIMU
function struct = preprocessIMU(struct,setting)
% This function filters the EMG data (includes bandpass and filtfilt)

for ch = 1:size(struct.channel,2)
    samplerate = struct.channel{ch}.samplerate;
    data = struct.channel{ch}.raw_imu;
        if setting.band
            data = bandpass(data,bandrange,samplerate);
        end
        if setting.calibrate
            data = (data - mean(data));
        end
        if setting.linear_env.flag
            butterorder = setting.linear_env.butterorder;
            fc = setting.linear_env.fc;
            [b, a] = butter(butterorder, fc/(samplerate/2));
            data = filtfilt(b,a,data);
        end
        if setting.flip 
            data = -data;
        end
        if setting.integrate
            vel = zeros(size(data));
            for i= 2:size(vel,2)
                vel(i) = vel(i-1) + 1/samplerate * data(i-1);
            end
            vel_data = vel;
        end
        filtered_data = data;
    channel{ch}.filtered = filtered_data;
    if setting.integrate
        channel{ch}.velocity = vel_data;
    end
    channel{ch}.setting =setting;
    channel{ch}.samplerate =samplerate;
    struct.channel{ch}= channel{ch};
end

end