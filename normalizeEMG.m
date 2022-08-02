function struct = normalizeEMG(struct,max_emg_struct,max_ch_order,no_max_flag,name)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
for ch = 1:size(max_emg_struct.channel,2)
    max_emg(ch) = max_emg_struct.channel(ch).max(1);
    %max_emg(ch+size(max_emg_struct.channel,2)) = max_emg_struct.channel(ch).max{2};
end
if nargin <= 4
    name = 'hs';
    hs_name = 'hs';
else
    hs_name = ['hs_' name];
end
max_emg = cell2mat(max_emg);
ch_num = size(struct.channel,2);
%%%%%%%%% Left Leg %%%%%%%%%%%%%%%%%%
    max_step = max(struct.(hs_name).step_lenL);
    desire_len = 2*max_step - 1;
    step_data = zeros(ch_num/2,size(struct.(hs_name).step_lenL,2),desire_len);
    for ch = 1:ch_num/2
        ch_max = max_ch_order(ch);
        if isempty(struct.channel{ch}.stepL)
           continue
        else
            if iscell(struct.channel{ch}.stepL.trial)
                data = struct.channel{ch}.stepL.trial;
            else
                data = struct.channel{ch}.stepL.trial.(name);
            end
            for st = 1: size(data,2)
                org_pts = 1:struct.(hs_name).step_lenL(st);
                interp_pts = linspace(1,struct.(hs_name).step_lenL(st),desire_len);
                step_data(ch,st,:) = interp1(org_pts,data{st},interp_pts);
            end
            if no_max_flag
                step_data(ch,:,:) = step_data(ch,:,:)/max_emg(ch_max);
            end
        end
    end
    
    interp_data = step_data;
    avg_step_data = squeeze(mean(step_data,2));
    cur_max_val = max(avg_step_data,[],2);

max_val = max(cur_max_val,[],1);
if ~no_max_flag
    max_val(max_val<1) = 1;
end

%for tr = 1:size(struct.trial,1)
    [~,num_steps,num_pts] = size(interp_data);
    dividmat = [repmat(cur_max_val(1),1,num_steps,num_pts);...
                repmat(cur_max_val(2),1,num_steps,num_pts);...
                repmat(cur_max_val(3),1,num_steps,num_pts)];

    interp_data = interp_data./dividmat;
    
%end
struct.interpL.data = interp_data;
struct.interpL.description = 'for each trial: channel x step x normalized points';

%%%%%%%%% Right Leg %%%%%%%%%%%%%%%%%%
% Change this to 2nd half of ch
disp("need to change here")
clear max_emg
for ch = 1:size(max_emg_struct.channel,2)
    max_emg(ch) = max_emg_struct.channel(ch).max(1);
    %max_emg(ch+size(max_emg_struct.channel,2)) = max_emg_struct.channel(ch).max{2};
end

if nargin <= 4
    name = 'hs';
    hs_name = 'hs';
else
    hs_name = ['hs_' name];
end
max_emg = cell2mat(max_emg);
ch_num = size(struct.channel,2);

max_step = max(struct.(hs_name).step_lenR);
    desire_len = 2*max_step - 1;
    step_data = zeros(ch_num/2,size(struct.(hs_name).step_lenR,2),desire_len);
    for ch = 1+ch_num/2:ch_num
        ch_max = max_ch_order(ch);
        if isempty(struct.channel{ch}.stepR)
           continue
        else
            if iscell(struct.channel{ch}.stepR.trial)
                data = struct.channel{ch}.stepR.trial;
            else
                data = struct.channel{ch}.stepR.trial.(name);
            end
            for st = 1: size(data,2)
                org_pts = 1:struct.(hs_name).step_lenR(st);
                interp_pts = linspace(1,struct.(hs_name).step_lenR(st),desire_len);
                step_data(ch,st,:) = interp1(org_pts,data{st},interp_pts);
            end
            if no_max_flag
                step_data(ch,:,:) = step_data(ch,:,:)/max_emg(ch_max);
            end
        end
    end
    interp_data = step_data;
    avg_step_data = squeeze(mean(step_data,2));
    cur_max_val = max(avg_step_data,[],2);
    


max_val = max(cur_max_val,[],1);
if no_max_flag
    max_val(max_val<1) = 1;
end
%for tr = 1:size(struct.trial,1)
    [~,num_steps,num_pts] = size(interp_data);
    dividmat = [repmat(cur_max_val(4),1,num_steps,num_pts);...
                repmat(cur_max_val(5),1,num_steps,num_pts);...
                repmat(cur_max_val(6),1,num_steps,num_pts)];
    
    interp_data = interp_data(4:6,:,:)./dividmat;
%end
struct.interpR.data = interp_data;
struct.interpR.description = 'for each trial: channel x step x normalized points';

end
