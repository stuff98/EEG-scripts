function [avg_vals, sig_chans] = compute_tf_cluster_avg(data, stat, clust_mask)
    
    nSubj = size(data.powspctrm, 1);
    avg_vals = zeros(nSubj, 1);
    sig_chans = stat.label(any(any(clust_mask, 3), 2));  

    for s = 1:nSubj
        subj_data = squeeze(data.powspctrm(s, :, :, :));  
        masked_vals = subj_data(clust_mask);              
        avg_vals(s) = mean(masked_vals, 'omitnan');       
    end
end
