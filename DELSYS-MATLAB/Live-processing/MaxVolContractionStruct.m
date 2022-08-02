function new_struct = MaxVolContractionStruct(emg_struct)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i = 1: size(emg_struct.trial,1)
    new_struct.channel(i).sensor.emg = emg_struct.channel{i}.raw_emg(i);
    new_struct.channel(i).sensor.ch_num = i;
%     new_struct.channel(i).sensor(1).emg = emg_struct.channel{i}.raw_emg(i);
    %new_struct.channel(i).sensor(2).emg = emg_struct.channel{i+4}.raw_emg(i);
%     new_struct.channel(i).sensor(1).ch_num = i;
    %new_struct.channel(i).sensor(2).ch_num = i+4;
    new_struct.channel(i).muscle = strtrim(strrep(emg_struct.trial(i,:),'start',''));
    new_struct.channel(i).samplerate = emg_struct.channel{i}.samplerate;
end
end
