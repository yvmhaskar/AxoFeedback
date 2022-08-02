function struct = findMaxVolContraction(fname,path_folder,setting)
%This function filters and prepares the MaxVolContraction file in a struct for
%normalization

struct = loadEMGstruct(fname,path_folder,'');
struct = MaxVolContractionStruct(struct);

for ch = 1:size(struct.channel,2)
    for sen = 1:size(struct.channel(ch).sensor,2)
        samplerate = struct.channel(ch).samplerate;
        for tr = 1:size(struct.channel(ch).sensor(sen).emg,2)
            data = struct.channel(ch).sensor(sen).emg;      
            if setting.band.flag
                bandrange = setting.band.bandrange;
                data =cell2mat(data);
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
            if setting.max_avg_flag
                filtered_max = mean(maxk(data,1000));
            else
                filtered_max = max(data);
            end
        end
        sensor{sen} = filtered_data;
        sensor_max{sen} = filtered_max;
    end
    struct.channel(ch).filtered = sensor;
    struct.channel(ch).max = sensor_max;
    struct.channel(ch).setting =setting;
end
end
