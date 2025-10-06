% Functin to eliminate trials containing Nan values 

function data_clean = remove_nan_trials(data_input)

    counter = 0; 
    bad_trial = []; 
    alltrials = 1:length(data_input.trial); 

   
    for trial_idx = 1:length(data_input.trial)
        this_trial = data_input.trial{trial_idx};
        if any(isnan(this_trial(:)))
            counter = counter + 1;
            bad_trial(counter) = trial_idx;
        end
    end

    
    cleantrial = setdiff(alltrials, bad_trial);

   
    cfg = [];
    cfg.trials = cleantrial;
    data_clean = ft_selectdata(cfg, data_input);

end