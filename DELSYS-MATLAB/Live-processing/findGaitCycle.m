function struct= findGaitCycle(struct,setting)
% This function uses the heel strike timings to separate the EMG data in
% different steps.

time_last_step = setting.time_last_step;
if size(time_last_step,2) == 1
    time_last_step = ones(1,size(struct.channel(1).filtered,2)) * time_last_step;
end
ch_num = size(struct.channel,2 ...
    );
for ch = 1:size(struct.channel,2)/2
%% Left Leg
    samplerate = struct.channel{ch}.samplerate;
    clear steps
    clear step_lengthL
    for j = 1:(size(struct.hs.tL,2)-1)
        start = struct.hs.indexL(j);
        stop = struct.hs.indexL(j+1);
        start_idx = start - floor(samplerate * time_last_step(1));

        if start_idx < 1
            start_idx = 1;
        end

        stop_idx = stop - floor(samplerate * time_last_step(1));
        steps{j} = struct.channel{ch}.filtered(start_idx:stop_idx);

        step_lengthL(j) = stop_idx-start_idx + 1;

    end
        step.trial = steps;
        struct.channel{ch}.stepL = step;
%% Right Leg
    samplerate = struct.channel{ch+ch_num/2}.samplerate;
    clear steps
    clear step_lengthR
    for j = 1:(size(struct.hs.tR,2)-1)
        start = struct.hs.indexR(j);
        stop = struct.hs.indexR(j+1);
        start_idx = start - floor(samplerate * time_last_step(1));
    
        if start_idx < 1
            start_idx = 1;
        end
        stop_idx = stop - floor(samplerate * time_last_step(1));
        steps{j} = struct.channel{ch+ch_num/2}.filtered(start_idx:stop_idx);
     
        step_lengthR(j) = stop_idx-start_idx + 1;

     end
        
        step.trial = steps;
        struct.channel{ch+ch_num/2}.stepR = step;
         
end
hs = struct.hs;
if ~isfield(struct.hs,'step_lenL')
    hs.step_lenL = step_lengthL;
end
if ~isfield(struct.hs,'step_lenR')
    hs.step_lenR = step_lengthR;
end
struct.hs = hs;
end