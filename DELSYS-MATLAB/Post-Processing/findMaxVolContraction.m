function struct = findMaxVolContraction(fname,setting)
%This function filters and prepares the MaxVolContraction file in a struct for
%normalization

loadedstruct = load(fname,'emg_struct');
struct = loadedstruct.emg_struct;
for ch = size(struct.channel,2):-1:1
    samplerate = struct.channel{ch}.samplerate;
    sensor = struct.channel{ch}.sensor;
    data = sensor.emg;
            if setting.band.flag
                bandrange = setting.band.bandrange;
                %data =cell2mat(data);
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

            % Takes the average of the max 1000 values
            filtered_data = data;
            if setting.max_avg_flag
                filtered_max = mean(maxk(data,1000));
            else
                filtered_max = max(data);
            end
           
    channel(ch).filtered = filtered_data;
    channel(ch).max = filtered_max;
    channel(ch).setting =setting;
end
struct.channel = channel;
end
