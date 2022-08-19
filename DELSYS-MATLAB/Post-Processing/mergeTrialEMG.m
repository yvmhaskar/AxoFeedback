function emg_struct_merged = mergeTrialEMG(emg_struct)
trial_name = strrep(emg_struct.trial(1,:),'1','');
trial_name = strrep(trial_name,' ','');
trial_name = strrep(trial_name,'0','');
trial_name = strrep(trial_name,'2','');
trial_name = strrep(trial_name,'Start','');
trial_name = strrep(trial_name,'start','');
emg_struct_merged.trial = append(trial_name,'merged');
for ch=1:length(emg_struct.channel)
   merged{ch}.raw_emg = {cat(2,emg_struct.channel{ch}.raw_emg{:})}; %concat
   merged{ch}.muscle =emg_struct.channel{ch}.muscle;
   merged{ch}.samplerate = emg_struct.channel{ch}.samplerate;
end
emg_struct_merged.channel = merged;
end