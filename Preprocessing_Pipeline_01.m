
clearvars -except action basePath innerFolders cSubjects conf

clear all
clc
close all

experiment = 'Project1'; 
group = 1; 
action = 9;  

%% Initializing variables (paths, subjects ID, fieldtrip version, etc.)

addpath ('Path/fieldtrip-20190224/');
ft_defaults;

innerFolders = getCons('innerFolders'); 
addpath ('/Path_to_your_scripts/')

rootPath_data = sprintf('/data_path/%s/', experiment);
rootPath_scripts = sprintf('/Path_to_scripts/');

% Load general specifications for the experiment

run(sprintf('%sGeneral_Config', rootPath_scripts));
basePath = sprintf('%s%s/', rootPath_data, conf('groupName'));

cSubjects = conf('subjects');
nSubjects = length(cSubjects);
cSuffix = conf('suffix');
cFileType = conf('fileType');

%% Action 1: Load EEG files and downsampling

if any(action == 1)
    cInnerFolder = innerFolders{1};

    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s%s%s', basePath, cInnerFolder, cSubject, cSuffix, cFileType);
        cprintf('Cyan', 'Participant %s:\n', cSubject); 
        
        
        cfg = []; 
        cfg.dataset= cFile; 
        cfg.channel = [{'all'}, strcat('-', conf('eliminateChans'))];
        cfg.continuous = 'yes'; 
        cfg.elecfile = conf('3Dlay');
        data_format = ft_preprocessing(cfg); 
       
        %Downsampling
        if strcmp(conf('downsampling'), 'yes')
            cprintf('Green', 'Applying downsampling at %d Hz in participant %s:\n', conf('downsamprate'), cSubject);
            cfg = [];
            cfg.resamplefs = conf('downsamprate'); 
            data_resampled = ft_resampledata(cfg, data_format);
        end

         
        outFile = sprintf('%s%s/%s_resampled', basePath, innerFolders{2}, cSubject);
        save(outFile, 'data_resampled'); 
    
    end
end

%% Action 2: First visual check. 

if any(action == 2)
    cInnerFolder = innerFolders{2};
    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s_resampled.mat', basePath, cInnerFolder, cSubject);
        cprintf('Cyan', 'Plotting participant %s:\n', cSubject); 
        data = load(cFile);
        data_resampled = data.data_resampled;
       
        cfg = [];
        cfg.viewmode = 'vertical';
        artf = ft_databrowser(cfg,data_resampled);

    end
end

%% Action 3: Inspect raw data. Discard bad channels. Interpolating bc.


if any(action == 3)
    cInnerFolder = innerFolders{2};
    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s_resampled.mat', basePath, cInnerFolder, cSubject);
        cprintf('Cyan', 'Subject %s:\n', cSubject); 
        data = load(cFile);
        data_resampled = data.data_resampled; 

        cfg          = [];
        cfg.method   = 'summary';
        dummy        = ft_rejectvisual(cfg,data_resampled);
        
        
        data = dummy;

 
        lay = conf('2Dlay');
        lay = load(lay); 
        lay = lay.lay;

        allLabels = data_resampled.label; 
        allPositions = lay.pos; 
        misschans=find(~ismember(allLabels , data.label)); 
        nmiss=length(misschans);
        cleanchans=find(ismember(allLabels,  data.label)); 
        nclen=size(allLabels,1) -nmiss; 

       
        
        for t=1:length(data.trial) 
            tmp0=data.trial{t};
            tmp1=tmp0(1:end,:); 
            tmp2=[tmp1;zeros(nmiss,length(tmp1))]; 
            tmp3=[tmp2,[cleanchans;misschans]]; 
            tmp4=sortrows(tmp3,length(tmp3)); 
            data.trial{t}=tmp4(:,1:length(tmp4)-1); 
        end
        
        data.label = allLabels; 
        
        cfg=[];
        cfg.method = 'triangulation';
        cfg.elecfile = 'EEG_chan.elc'; 
        cfg.channel = 'all';
        cfg.feedback  = 'yes';
        neighbours = ft_prepare_neighbours(cfg, data);
        
        
        cfg=[];
        cfg.badchannel = allLabels(misschans);
        cfg.elecfile = 'EEG_chan.elc'; 
        cfg.neighbours = neighbours;
        data_interp = ft_channelrepair(cfg, data);

        outFile = sprintf('%s%s/%s_interpolate', basePath, innerFolders{3}, cSubject);
        save(outFile, 'data_interp'); 
    end
end


%% Action 4: Rereference and filtering

if any(action == 4)
    cInnerFolder = innerFolders{3};
    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s_interpolate.mat', basePath, cInnerFolder, cSubject);
        cprintf('Cyan', 'Subject %s:\n', cSubject); 
        data = load(cFile);
        data = data.data_interp;

        occularChans = conf('occularChans'); 
        
        refMask = ~ismember(data.label, occularChans);   
        refChannels = data.label(refMask);               


        if strcmp(conf('reref'), 'yes')
            cprintf('Green', 'Rereferencing data from refChannels cell-array in participant %s:\n', cSubject);
            
            cfg = [];
            cfg.reref = conf('reref'); 
            cfg.refchannel    = refChannels; 
            cfg.refmethod     = 'avg'; 
            
            data_reref = ft_preprocessing(cfg,data);
        
        end

            clear cfg

            cfg = [];
            cfg.channel= 'all';
            cfg.continuous = 'yes';

        % FILTERS

        if strcmp(conf('hpfilter'), 'yes')
            cprintf('Green', 'High pass filter of %d Hz will be applied in participant %s:\n', conf('hpfreq'), cSubject);
            cfg.hpfilter = 'yes';
            cfg.hpfilttype ='firws';
            cfg.hpfreq = conf('hpfreq');
        end
        
        if strcmp(conf('lpfilter'), 'yes')
            cprintf('Green', 'Low pass filter of %d Hz will be applied in participant %s:\n', conf('lpfreq'), cSubject);
            cfg.lpfilter = 'yes';
            cfg.lpfreq = conf('lpfreq');
        end

        if strcmp(conf('bsfilter'), 'yes')
            cprintf('Green', 'Band stop filter of %d and %d Hz will be applied in participant %s:\n', conf('bsfreq'), cSubject);
            cfg.bsfilter = 'yes';
            cfg.bsfreq = conf('bsfreq');
        end

        data_filter = ft_preprocessing(cfg,data_reref); %preprocess the data

        outFile = sprintf('%s%s/%s_preproc', basePath, innerFolders{4}, cSubject);
        save(outFile, 'data_filter'); 
       
        clear data_filter
    end 
end
  

%% Action 5: Visual inspection (II) and artifact detection on the continuos data

if any(action == 5)
    cInnerFolder = innerFolders{4};

    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s_preproc.mat', basePath, cInnerFolder, cSubject);
        cprintf('Cyan', 'Plotting participant %s:\n', cSubject); 
        data = load(cFile);
        data_filter = data.data_filter; 


        
        cfg = [];
        cfg.viewmode = 'vertical';
        artfx = ft_databrowser(cfg,data_filter);

        % Mark them as 'nan'
        cfg =[];
        artfx.artfctdef.reject='nan';
        data_vis_inspected = ft_rejectartifact(artfx, data_filter);


        outFile = sprintf('%s%s/%s_vis_inspected', basePath, innerFolders{5}, cSubject);
        save(outFile, 'data_vis_inspected'); 
        clear data_filter; 
    end
end

%% Action 6: Defining trials and keeping only clean trials

if any(action == 6)
    cInnerFolder = innerFolders{1};
    cInnerFolder_2 = innerFolders{5};
    
    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s%s%s', basePath, cInnerFolder, cSubject, cSuffix, cFileType);
        cprintf('Cyan', 'Defining trials for participant %s:\n', cSubject); 
        
        cfg = []; 
        cfg.dataset= cFile; 
        cfg.fsample = conf('origsamprate'); 
        cfg.trialdef.eventvalue = 130; 
        cfg.trialfun = 'MakeTrials_Project';
        cfg.trialdef.pre = conf('trialpre'); 
        cfg.trialdef.post = conf('trialpost'); 

        original_data_epoch = ft_definetrial(cfg);

        original_samplingrate = conf('origsamprate'); 
        actual_data_samplingrate = conf('downsamprate'); 

        
        neotrial = round(original_data_epoch.trl/(original_samplingrate/actual_data_samplingrate));

        
        cSubject_2 = cSubjects{i};
        cFile_2 = sprintf('%s%s/%s_vis_inspected.mat', basePath, cInnerFolder_2, cSubject_2);
        cprintf('Green', 'Redifining trials for participant %s:\n based on raw data', cSubject_2); 
        data = load(cFile_2);
        data_vis_inspected = data.data_vis_inspected;

         

        
        cfg = [];
        cfg.dataset = cFile_2;
        cfg.trl = neotrial; 
        data_epoch_prereject = ft_redefinetrial(cfg, data_vis_inspected);



        counter   = 0; 
        bad_trial = [];
        alltrials = (1:length(data_epoch_prereject.trial)); 


        
        for triales = 1:length(data_epoch_prereject.trial);
        ttt = data_epoch_prereject.trial{triales};
        
        nodata=isnan(ttt(1,:)); 
        
            if sum(nodata)>0
            counter=counter+1;
            bad_trial(counter)=triales;
            end
        
        end
        
        cleantrial = setdiff(alltrials,bad_trial); 
        

        cfg=[];
        cfg.trials=cleantrial;
        data_goodtrials = ft_selectdata(cfg,data_epoch_prereject)


        outFile = sprintf('%s%s/%s_trialdef', basePath, innerFolders{6}, cSubject);
        save(outFile, 'data_goodtrials'); 
    end
end


%% Action 7: ICA, Ensure the ICA components are ordered correctly and set dimord fields

if any(action == 7)
    cInnerFolder = innerFolders{6};
    elec = ft_read_sens(conf('3Dlay'));  
    lay = conf('2Dlay');
    lay = load(lay); 
    lay = lay.lay;
    
    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s_trialdef.mat', basePath, cInnerFolder, cSubject);
        cprintf('Cyan', 'Running ica for participant %s:\n', cSubject); 
        
        data_2ica = load(cFile);
        data_goodtrials = data_2ica.data_goodtrials;  

        cfg        = [];
        cfg.method = 'runica';
        cfg.numcomponent = 20; 
        cfg.channel = 'all'; 
        data_ica = ft_componentanalysis(cfg,data_goodtrials);
        data_comp = data_ica; 
        

         
            if size(data_comp.topo, 2) == 1  
                data_comp.topo = reshape(data_comp.topo, [size(data_comp.label, 1), size(data_comp.unmixing, 1)]);
            end

            
            if size(data_comp.unmixing, 1) == 1
                data_comp.unmixing = data_comp.unmixing';  
            end


            data_comp.dimord = 'chan_comp';
            data_comp.topodimord = 'chan_comp';
            data_comp.unmixingdimord = 'chan_chan';



            data_comp.elec = ft_datatype_sens(data_comp.elec);


            cfg = [];
            cfg.layout = lay; 
            cfg.elec = elec;
            layout = ft_prepare_layout(cfg, data_comp);



        outFile = sprintf('%s%s/%s_ica', basePath, innerFolders{7}, cSubject);
        save(outFile, 'data_comp'); 
    
    
    end
end

%% Action 8: Bad components rejection.

if any(action == 8)  
    cInnerFolder = innerFolders{7}; 
    elec = ft_read_sens(conf('3Dlay'));  
    lay = conf('2Dlay');
    lay = load(lay); 
    lay = lay.lay;

  for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s_ica.mat', basePath, cInnerFolder, cSubject);
        cprintf('Cyan', 'Plotting ICA components for participant %s:\n', cSubject); 

        load(cFile, 'data_comp');  

        rejectedComponents = inspect_ica_components(data_comp, elec, lay, cSubject)
       
                
        cfg = [];
        cfg.component = rejectedComponents;
        data_clean = ft_rejectcomponent(cfg, data_comp);
        data_clean.rejectedComponents = rejectedComponents;


        savePath = sprintf('%s%s/%s_comp_reject.mat', basePath, innerFolders{8}, cSubject);
        save(savePath, 'data_clean');
  end

end

%% Actions 9 and 10: Final signal supervision before saving

if any(action == 9)  
    cInnerFolder = innerFolders{8}; % where the ICA data is saved
    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s_comp_reject.mat', basePath, cInnerFolder, cSubject);
        cprintf('Cyan', 'Plotting ICA components for participant %s:\n', cSubject); 

        load(cFile, 'data_clean');

        cfg = [];
        cfg.viewmode = 'vertical';
        cfg.channel = 'all';
        cfg.allowoverlap = 'yes';
        
        hFig = ft_databrowser(cfg, data_clean);
      
        waitfor(hFig); 

    end
end

%% Action 10: ERP plot

if any(action == 10)  
    cInnerFolder = innerFolders{8}; 
    for i = 1:nSubjects
        cSubject = cSubjects{i};
        cFile = sprintf('%s%s/%s_comp_reject.mat', basePath, cInnerFolder, cSubject);
        cprintf('Cyan', 'Plotting ICA components for participant %s:\n', cSubject); 

        load(cFile, 'data_clean');

        lay = conf('2Dlay');
        lay = load(lay); 
        lay = lay.lay;

        cfg = [];
        cfg.xlim = [-0.2 1]; %time window
        cfg.layout=lay; %layout
        
        figure;
        
        hFig = ft_multiplotER(cfg,data_clean);
        waitfor(hFig)

    end
end




