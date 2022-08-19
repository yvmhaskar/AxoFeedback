function [emg_exp] = loadEMGstruct(fname,pathname,keyword)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
load([pathname fname])

[numchannels numblocks] = size(datastart);
comtextmap = com(:,5);
comments = comtext(comtextmap,:);

all_titles = 1:size(titles, 1);
EMG_channels = all_titles(titles(:, 1) == 'E'); 
IMU_channels = all_titles(titles(:,1) == 'A' | titles(:,1) == 'M' | titles(:,1) == 'G');

j = 0;
for ch = EMG_channels
    j = j+1;
    for c = 1:size(com,1)/2 % comments should occurs in pair to be valid
       bl = com(2*c-1,2); % identify which block this comment falls in
       data_bl = data(datastart(ch,bl):dataend(ch,bl)); % select this block of data
       com_start = com(2*c-1,3);
       com_end =com(2*c,3);
       %assert(com_end <= com(2*c,3),'data selected outside of the comment block');
       data_com = data_bl(com_start:com_end); %only use the data between the start and end comment
      % bandData = bandpass(data_com,[25 400],samplerate(ch,bl));
       %d = designfilt('bandstopiir','FilterOrder',2, ...
        %           'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
         %          'DesignMethod','butter','SampleRate',samplerate(ch,bl));
        %buttData = filtfilt(d,bandData);
        emg_com{c} = data_com;
        %recData{c} = abs(buttData);
        %emg_pow(c) = norm(recData{c});
        %errlow(c) = -std(recData);
        %errhigh(c) = std(recData);
    end

    emg_data{j}.raw_emg = emg_com;
    emg_data{j}.muscle = titles(ch,:);
    emg_data{j}.samplerate = samplerate(ch);
end
emg_exp.trial = insertBefore(string(comments(1:2:end,:)),1,[keyword '_']);
emg_exp.channel = emg_data;
end
