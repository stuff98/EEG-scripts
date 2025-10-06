
conf = containers.Map;

%% General variables affecting to all groups
conf('eliminateChans') = {'EKG' 'EMG' 'Trigger'};
conf('occularChans')  = {'HEOG', 'VEOG'};
conf('refChann') = 'all'; 


%Channel location the 3D coordinates
conf('3Dlay') = 'EEG_chan.elc';
%Channel location with 2D coodinates
conf('2Dlay') = 'Layout_EEG.mat';

%% Preprocessing settings 
conf('downsampling') = 'yes';
conf('reref') = 'yes';
conf('bsfilter') = 'yes';
conf('hpfilter') = 'yes';
conf('lpfilter') = 'yes';
conf('origsamprate') = 1000;
conf('downsamprate') = 500;
conf('hpfreq') = 0.1;
conf('lpfreq') = 40;
conf('bsfreq') = [48 52];
conf('trialpre') = 1.5;
conf('trialpost') = 5.5; 



%% group 1
if group == 1
   conf('groupName') = 'Group1';
   conf('suffix') = '-20';
   conf('fileType') = '.cnt'; 

    
    allSubs = {'8' '10'};

    conf('subjects') = allSubs; 

end

  
    


    