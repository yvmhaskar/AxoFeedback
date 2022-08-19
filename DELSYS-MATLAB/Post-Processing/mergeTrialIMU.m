function imu_struct_merge = mergeTrialIMU(imu_struct)
imu_struct_merge.trial = append(imu_struct.trial(1,:),'_merged');

for ch=1:length(imu_struct.channel)

   merged{ch}.raw_imu = {cat(2,imu_struct.channel{ch}.raw_imu{:})}; %concat
   merged{ch}.name =imu_struct.channel{ch}.name;
   merged{ch}.samplerate = imu_struct.channel{ch}.samplerate;
end
imu_struct_merge.channel = merged;

end