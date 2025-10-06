function [con] = getCons(field)
% Determine the global IDs for consistency in our experiment/project, 
% the folders, suffix files and names for the structures within the files.

    cons = containers.Map;

    cons('innerFolders') = {'0_sourcedata', '1_loaded', '2_interp' '3_preproc', '4_vis_inspected', '5_trialdef', '6_ica', '7_component_reject', '8_TF_analyses', '9_preGAv', '10_GA', '11_Reports'};
    cons('suffixes') = {'', '_resampled', 'interpolate', '_preproc', '_vis_inspected', '_original_epoch', 'trialdef', '_ica', '_comp_reject', '_freq_bc', '_preGAv' };
    cons('varNames') = {'', 'data_vis_inspected', 'data_goodtrials', 'data_comp', 'data_ica_rejected'};


    assert(isKey(cons, field), 'There is no constant named %s', field);
    
    con = cons(field);
end

