%% TIME FREQUENCY ANALYSES


%% Group and action identification
clearvars -except action basePath innerFolders cSubjects conf

clear all
clc
close all

experiment = 'Project1'; 
group = 1; 
action = 2;  

%% Initializing variables (paths, subjects ID, fieldtrip version, etc.)

%addpath ('Path/fieldtrip-20190224/');
ft_defaults;

addpath ('/Path_to_your_scripts/')
addpath ('/Path_to_your_scripts/utils/')

rootPath_data = sprintf('/data_path/%s/', experiment);
rootPath_scripts = sprintf('/Path_to_scripts/');

innerFolders = getCons('innerFolders'); 

% Load general specifications for the experiment

run(sprintf('%sGeneral_Config', rootPath_scripts));
basePath = sprintf('%s%s/', rootPath_data, conf('groupName'));

cSubjects = conf('subjects');
nSubjects = length(cSubjects);
cSuffix = conf('suffix');
cFileType = conf('fileType');

%% Action 1. Time frequency analyses with baseline correction

if any(action == 1)
    cInnerFolder = innerFolders{8};

    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s_comp_reject.mat', basePath, cInnerFolder, cSubject);
        cprintf('Cyan', 'Participant %s:\n', cSubject); 

      
        data = load(cFile);
        data_clean = data.data_clean ;
        
        cfg = [];
        cfg.method = 'wavelet';
        cfg.output = 'pow';
        cfg.keeptrials = 'yes';
        cfg.foi = 2:0.4:30;
        cfg.toi = -1.5:0.02:5.5;
        cfg.width = 3:(9/70):12;
       
        Freq_EEG = ft_freqanalysis(cfg, data_clean);

        clear cfg

        cfg = [];
        cfg.baseline = [-0.6 -0.2];
        cfg.baselinetype = 'db';
        cfg.keeptrials = 'yes';
        Freq_BC_EEG = ft_freqbaseline(cfg,Freq_EEG);
                      
        
        outFile = sprintf('%s%s/%s_freq_bc', basePath, innerFolders{9}, cSubject);
        save(outFile, 'Freq_BC_EEG'); 
    end
end

%% Action 2. Set dimord and remove rpt for grand average computation, GA computation

if any(action == 2)
    %cInnerFolder = innerFolders{8};

    for j = 1:nSubjects
        cSubject = cSubjects{j};
        inFile = sprintf('%s%s/%s_freq_bc.mat', basePath, innerFolders{9}, cSubject);  
        cData = load(inFile);
        allSubjectsData{j} = cData.Freq_BC_EEG;
    end


    averagedData = cell(size(allSubjectsData));


    for i = 1:numel(allSubjectsData)
        cfg = [];
        cfg.keeptrials = 'no';  
        averagedData{i} = ft_freqdescriptives(cfg, allSubjectsData{i});
    end

        
     outFile = sprintf('%s%s/%s', basePath, innerFolders{10}, '_preGAv');
     save(outFile, 'averagedData');



    clear cfg
    
     cfg = [];
     cfg.keepindividual = 'yes';
     cfg.channel = ft_channelselection({'all', '-HEOL', '-HEOR-L', '-VEOU', '-VEOL-U', '-A1', '-A2'}, averagedData{1}.label); 
     grandavg_ki = ft_freqgrandaverage(cfg, averagedData{:});


     outFile = sprintf('%s%s/%s', basePath, innerFolders{11}, 'GA_ki');
     save(outFile, 'grandavg_ki');

     clear cfg

     cfg = [];
     cfg.channel = ft_channelselection({'all', '-HEOL', '-HEOR-L', '-VEOU', '-VEOL-U', '-A1', '-A2'}, averagedData{1}.label);
     grandavg = ft_freqgrandaverage(cfg, averagedData{:});

     outFile = sprintf('%s%s/%s', basePath, innerFolders{11}, 'GA');
     save(outFile, 'grandavg');

end
 




