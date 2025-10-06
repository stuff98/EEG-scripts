
%% Initializing variables 

clear 
clc
close all

experiment = 'Project';

addpath ('path_to_CBPT_folder')
addpath ('Path_to/fieldtrip-20190224/');
ft_defaults;

rootPath_data = sprintf('/data_path/%s/', experiment);
rootPath_scripts = sprintf('path_to_your_scripts/');

%% The CBPT design

clear n1 n2 m1 m2
n1  = size(GA_A.powspctrm, 1);
n2 = size(GA_B.powspctrm, 1);

m1 = GA_A;
m2 = GA_B;



layoutData = load('Layout_EEG.mat');
layout = layoutData.lay;

cfg = [];
cfg.method = 'distance';          
cfg.layout = layout;
cfg.neighbourdist = 0.25;          
neighbours = ft_prepare_neighbours(cfg);

clear cfg


cfg = [];

cfg.channel     = 'all';
cfg.latency     = 'all';     
cfg.frequency   = [4 6];      
cfg.method      = 'montecarlo';
cfg.statistic   = 'indepsamplesT'; 
cfg.correctm    = 'cluster';
cfg.clusteralpha = 0.05;           
cfg.clusterstatistic = 'maxsum';   
cfg.minnbchan   = 3;
cfg.tail        = 0;
cfg.clustertail = 0;
cfg.alpha       = 0.025;
cfg.numrandomization = 1000;

cfg.neighbours  = neighbours;     
cfg.design      = [ones(1,n1), ones(1,n2)*2]; 
cfg.ivar        = 1;              

% Step 4: Run the statistics
[stat] = ft_freqstatistics(cfg, m1, m2);

