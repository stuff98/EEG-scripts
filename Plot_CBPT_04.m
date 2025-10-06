
load('Layout_project.mat')
layout = lay; 

addpath ('path_to_plotting_utils')
addpath ('Path_to/fieldtrip-20190224/');
ft_defaults;

%% 

alpha_level = 0.05;
pos_clus = [];
pos_clus_probs = [];
if ~isempty(stat.posclusters)
    pos_clus = find([stat.posclusters.prob]<=alpha_level);
    pos_clus_probs = [stat.posclusters.prob];
end

neg_clus = [];
neg_clus_probs = [];
if ~isempty(stat.negclusters)
    neg_clus = find([stat.negclusters.prob]<=alpha_level);
    neg_clus_probs = [stat.negclusters(neg_clus).prob];
end

%% Get the direction, channels, mean, SD and p values of the effect

alpha = 0.05; 
results = summarize_CBPT_results(GA_A, GA_B, stat, alpha);

%% For positive clusters 

for pc = 1:length(pos_clus)
    tmp = [];
    for t = 1:length(stat.time)
        if any(any(stat.posclusterslabelmat(:,:,t) == pos_clus(pc)))
            tmp = [tmp t];
        end
    end
    tmp_all_pos_clusters{pc} = tmp;

  
    sig_elecs = [];
    for el = 1:length(stat.label)
        if any(any(stat.posclusterslabelmat(el,:,:) == pos_clus(pc)))
            sig_elecs = [sig_elecs el];
        end
    end
    elec_all_pos_clusters{pc} = sig_elecs;


    sig_freqs = [];
    for fr = 1:length(stat.freq)
        if any(any(stat.posclusterslabelmat(:,fr,:) == pos_clus(pc)))
            sig_freqs = [sig_freqs fr];
        end
    end
    freq_all_pos_clusters{pc} = sig_freqs;


    figure;
    gfc = gcf;  
    colormap(gfc, parula);  

    cfg = [];
    cfg.layout = layout;
    cfg.xlim = [stat.time(tmp(1)) stat.time(tmp(end))];
    cfg.ylim = [stat.freq(sig_freqs(1)) stat.freq(sig_freqs(end))];
    cfg.zlim = [-4 4];
    cfg.zparam = 'stat';
    cfg.param = 'stat';
    cfg.highlight = 'on';
    cfg.highlightchannel = stat.label(sig_elecs);
    cfg.highlightsymbol = '*';
    cfg.highlightcolor = [1 1 1];
    cfg.highlightsize = 5;

    ft_topoplotTFR(cfg, stat);

    title([
        'Positive Cluster #' num2str(pc) ...
        ' | ' num2str(round(stat.freq(sig_freqs(1)))) '-' num2str(round(stat.freq(sig_freqs(end)))) ' Hz' ...
        ', ' num2str(stat.time(tmp(1))) '-' num2str(stat.time(tmp(end))) ' s' ...
        '; p = ' num2str(pos_clus_probs(pos_clus(pc)))
    ], 'FontSize', 14);

    colorbar;
end


%% For negative clusters

for nc = 1:length(neg_clus)
    tmp = [];
    for t = 1:length(stat.time)
        if any(any(stat.negclusterslabelmat(:,:,t) == neg_clus(nc)))
            tmp = [tmp t];
        end
    end
    tmp_all_neg_clusters{nc} = tmp;


    sig_elecs = [];
    for el = 1:length(stat.label)
        if any(any(stat.negclusterslabelmat(el,:,:) == neg_clus(nc)))
            sig_elecs = [sig_elecs el];
        end
    end
    elec_all_neg_clusters{nc} = sig_elecs;

  
    sig_freqs = [];
    for fr = 1:length(stat.freq)
        if any(any(stat.negclusterslabelmat(:,fr,:) == neg_clus(nc)))
            sig_freqs = [sig_freqs fr];
        end
    end
    freq_all_neg_clusters{nc} = sig_freqs;


    figure;
    gfc = gcf;  
    colormap(gfc, parula); 
    
    cfg = [];
    cfg.layout = layout;
    cfg.xlim = [stat.time(tmp(1)) stat.time(tmp(end))];
    cfg.ylim = [stat.freq(sig_freqs(1)) stat.freq(sig_freqs(end))];
    cfg.zlim = [-4 4];
    cfg.zparam = 'stat';
    cfg.param = 'stat';
    cfg.highlight = 'on';
    cfg.highlightchannel = stat.label(sig_elecs);
    cfg.highlightsymbol = '*';
    cfg.highlightcolor = [1 1 1];
    cfg.highlightsize = 5;

    ft_topoplotTFR(cfg, stat);

    title([
        'Negative Cluster #' num2str(nc) ...
        ' | ' num2str(round(stat.freq(sig_freqs(1)))) '-' num2str(round(stat.freq(sig_freqs(end)))) ' Hz' ...
        ', ' num2str(stat.time(tmp(1))) '-' num2str(stat.time(tmp(end))) ' s' ...
        '; p = ' num2str(neg_clus_probs(neg_clus(nc)))
    ], 'FontSize', 14);

    colorbar;
end