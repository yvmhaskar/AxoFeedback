function struct = removeDurationOutlier(struct,plotbool,name)
% This function removes the outlier EMG data.

if nargin <3
    name = 'hs';
    hs_name = 'hs';
else
    hs_name = ['hs_' name];
end

%% Left Leg
durations = struct.(hs_name).step_lenL;
indexes = find(durations>mean(durations) + 3 * std(durations) | durations<mean(durations) - 3 * std(durations));

if(plotbool)
    figure;
    scatter(1:size(durations, 2), durations);
    hold on;
    scatter(indexes, ones(size(indexes))* mean(durations) + 3 * std(durations), '*r')
    hold on;
    scatter(indexes, ones(size(indexes))* mean(durations) - 3 * std(durations), '*r')
end

for ch = 1:size(struct.channel,2)/2
    if isempty(struct.channel{ch}.stepL)
        continue
    else
        if iscell(struct.channel{ch}.stepL.trial)
            struct.channel{ch}.stepL.trial(indexes) = [];
        else
           struct.channel{ch}.stepL.trial.(name)(indexes) =[];
        end
   end
end
struct.(name).step_lenL(indexes) = [];

%% Right Leg
durations = struct.(hs_name).step_lenR;
indexes = find(durations>mean(durations) + 3 * std(durations) | durations<mean(durations) - 3 * std(durations));

if(plotbool)
    figure;
    scatter(1:size(durations, 2), durations);
    hold on;
    scatter(indexes, ones(size(indexes))* mean(durations) + 3 * std(durations), '*r')
    hold on;
    scatter(indexes, ones(size(indexes))* mean(durations) - 3 * std(durations), '*r')
end
for ch = 1+size(struct.channel,2)/2:size(struct.channel,2)
    if isempty(struct.channel{ch}.stepR)
       continue
    else
        if iscell(struct.channel{ch}.stepR.trial)
            struct.channel{ch}.stepR.trial(indexes) = [];
        else
           struct.channel{ch}.stepR.trial.(name)(indexes) =[];
        end
   end
end
struct.(name).step_lenR(indexes) = [];