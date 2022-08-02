function [imu] = loadIMUstruct(fname,pathname,keyword)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
load([pathname fname])

[numchannels numblocks] = size(datastart);
comtextmap = com(:,5);
comments = comtext(comtextmap,:);

all_titles = 1:size(titles, 1);

warning('hardcode IMU');
IMU_channels = all_titles(titles(:,1) == 'A' | titles(:,1) == 'M' | titles(:,1) == 'G');
IMU_channels_names = strcat(titles(IMU_channels,:), char('_(G)', '_(G)', '_(G)', '_(°/s)', '_(°/s)', '_(°/s)', '_(uT)', '_(uT)','_(uT)', '_(G)', '_(G)', '_(G)', '_(°/s)', '_(°/s)', '_(°/s)', '_(uT)', '_(uT)','_(uT)'));

j = 0;
for ch = IMU_channels(1:9)
    j = j+1;
    for c = 1:size(com,1)/2 % comments should occurs in pair to be valid
       bl = com(2*c-1,2); % identify which block this comment falls in
       data_bl = data(datastart(ch,bl):dataend(ch,bl)); % select this block of data
       com_start = round(com(2*c-1,3)*samplerate(ch,bl)/tickrate(bl));
       com_end =round(com(2*c,3)*samplerate(ch,bl)/tickrate(bl)); 
       %assert(com_end <= com(2*c,3),'data selected outside of the comment block');
       data_com = data_bl(com_start:com_end); %only use the data between the start and end comment
      
       imu_com{c} = data_com;
    
    end

    imu_data{j}.raw_imu = imu_com;
    imu_data{j}.name = strtrim(titles(ch,:));
    imu_data{j}.samplerate = samplerate(ch);
end
imu.trial = insertBefore(string(comments(1:2:end,:)),1,[keyword '_']);
imu.channel = imu_data;
end