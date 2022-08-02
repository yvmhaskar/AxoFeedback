%% preprocessEMG
function struct = preprocessEMG(struct,setting)
% This function filters the EMG data (includes bandpass and filtfilt)

for ch = 1:size(struct.channel,2)
    samplerate = struct.channel{ch}.samplerate;
    

        data = struct.channel{ch}.raw_emg;
        if setting.band.flag
            bandrange = setting.band.bandrange;
            data = bandpass(data,bandrange,samplerate);
        end
        
        if setting.rectify 
            data = abs(data - mean(data));
        end
        

        if setting.linear_env.flag
            butterorder = setting.linear_env.butterorder;
            fc = setting.linear_env.fc;
            [b, a] = butter(butterorder, fc/(samplerate/2));
            data = filtfilt(b,a,data);
        end
        filtered_data = data;
    channel{ch} = struct.channel{ch};
    channel{ch}.filtered = filtered_data;
    channel{ch}.setting = setting;
    struct.channel{ch}= channel{ch};
    
end
end