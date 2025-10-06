
function [trl, event] = MakeTrials_RPRAT(cfg)


event = ft_read_event(cfg.dataset);
event = event(strcmp({event.type}, 'trigger'));


 event_values = [event.value];
 event_samples = [event.sample];


target_trigger = cfg.trialdef.eventvalue; 
%matching_indices = find(event_values == target_trigger);
matching_indices = find(ismember(event_values, target_trigger));

if isempty(matching_indices)
    warning('No trials were found based on the determined trigger');
    trl = [];
    return;
end

sample1 = event_samples(matching_indices);


pretrig = -round(cfg.trialdef.pre * cfg.fsample);
posttrig = round(cfg.trialdef.post * cfg.fsample);

% Crear la matriz trl
trl1 = [];
for j = 1:length(sample1)
    trlbegin1 = sample1(j) + pretrig;
    trlend1 = sample1(j) + posttrig;
    offset1 = pretrig;
    trl1 = [trl1; trlbegin1, trlend1, offset1]; 
end


trl_all = [];
trl_all = [trl1];

[B,I] = sort(trl_all(:,1),1);

trl =[];
trl = trl_all(I,:);
