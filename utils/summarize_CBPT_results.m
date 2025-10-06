function results = summarize_CBPT_results(data1, data2, stat, alpha)

% USAGE:

%   results = summarize_all_clusters(data_groupA, data_groupB, stat, alpha);
    % grab the variable names as seen by the caller
    name1 = inputname(1);
    name2 = inputname(2);
    results = [];
    k = 0;
    clusterFields  = {'negclusters','posclusters'};
    labelMatFields = {'negclusterslabelmat','posclusterslabelmat'};
    for fld = 1:2
        clusters = stat.(clusterFields{fld});
        labelmat = stat.(labelMatFields{fld});
        if isempty(clusters), continue; end
        for i = 1:numel(clusters)
            p = clusters(i).prob;
            if p < alpha
                k = k + 1;
                results(k).type       = clusterFields{fld}(1:end-1);  % 'neg' or 'pos'
                results(k).prob       = p;
                clust_mask            = labelmat == i;

                
                [avg1, sig_chans] = compute_tf_cluster_avg(data1, stat, clust_mask);
                avg2              = compute_tf_cluster_avg(data2, stat, clust_mask);
                results(k).chanLabels = sig_chans;

                
                results(k).mean1 = mean(avg1, 'omitnan');
                results(k).mean2 = mean(avg2, 'omitnan');

                
                results(k).sd1   = std(avg1, 0, 'omitnan');
                results(k).sd2   = std(avg2, 0, 'omitnan');


                results(k).subjVals1 = avg1;
                results(k).subjVals2 = avg2;

    
                tvals_in_cluster = stat.stat(clust_mask);
                results(k).meanT = mean(tvals_in_cluster, 'omitnan');

         
                results(k).nSubj1 = length(avg1);
                results(k).nSubj2 = length(avg2);

               
                fprintf('Cluster %d (%s, p=%.3f)\n', k, results(k).type, results(k).prob);
                fprintf('  %s: mean = %.4f, SD = %.4f (n=%d)\n', ...
                        name1, results(k).mean1, results(k).sd1, results(k).nSubj1);
                fprintf('  %s: mean = %.4f, SD = %.4f (n=%d)\n', ...
                        name2, results(k).mean2, results(k).sd2, results(k).nSubj2);
                fprintf('  Mean t-value in cluster = %.4f\n', results(k).meanT);
                fprintf('  %s has higher power in that cluster.\n', ...
                        ternary(results(k).mean1 > results(k).mean2, name1, name2));
                fprintf('  Significant channels: %s\n\n', strjoin(sig_chans, ', '));
            end
        end
    end
end

function [subj_avg, sig_channels] = compute_tf_cluster_avg(data, stat, clust_mask)
    nSubj = size(data.powspctrm,1);
    [~, cidx] = ismember(stat.label, data.label);
    [~, fidx] = ismember(stat.freq,  data.freq);
    [~, tidx] = ismember(stat.time,  data.time);
    subj_avg = nan(nSubj,1);
    for s = 1:nSubj
        x = squeeze(data.powspctrm(s,cidx,fidx,tidx));  
        subj_avg(s) = mean(x(clust_mask), 'omitnan');
    end
    % which channels
    chan_mask    = squeeze(any(any(clust_mask,3),2));
    sig_channels = data.label(cidx(chan_mask));
end

function out = ternary(cond, a, b)
    if cond, out = a; else out = b; end
end




