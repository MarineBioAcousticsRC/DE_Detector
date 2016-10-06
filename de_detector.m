function de_detector
% This is the starting point for a simplified detector based on Marie Roche's  
% teager energy detector. It includes ideas/code snips from Simone, 
% and calls functions from triton. 
% The goal of this detector is to have predictable performance, 
% for use with model-based density estimation efforts. To accomplish this,
% it uses a simple energy threshold to identify clicks, thereby reducing
% the impact of changing noise conditions on detectability. 

% Known issue: Prop cavitation noise often makes it through detector and
% classifier steps.

% The low and hi-res detection passes still happen, but no teager energy 
% is used.

% All input parameters are contained within two separate scripts:
%   dLoad_STsettings : settings for low res detector
%   dLoad_HRsettings : settings for hi res detector
% See those files for info on settings.

clearvars
close all
fclose all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set transfer function location
% tfFullFile = 'E:\Code\TF_files\TF Files\HARP\600_series\667_111028\667_111028_invSensit.tf';
% tfFullFile = 'E:\Code\TF_files\610_100527_DT07B\610_100527_invSensit.tf';
% Note, if you don't have a transfer function just use:
tfFullFile = [];

% Location of base directory containing directories of files to be analyzed
baseDir = 'H:\';

% Optional output directory location. Metadata directory will be created in outDir
% if specified, otherwise it will be created in baseDir.
% outDir = '<your path here>';
outDir  = 'I:\DCL\WAT_NC_'; 

% Name of the deployment. This should be the first few characters in the 
% directory(ies) you want to look in you want to look at. For now, 
% directory hierarchy is expected to be: basedir>depl*>*.x.wav
% TODO: implement recursive directory search for more flexibility.
depl = 'WAT_NC_';

% Set flags indicating which routines to run. 
lowResDet = 1; %run short time detector.
highResDet = 1; %run high res detector

%%%% Optional: guided detection spreadsheet, can be empty
gDxls = 'E:\Data\John Reports\DCLDEdata\WAT_NC_guidedDets.xlsx';
% gDxls = []; % if not used

%%%%%%%%%%%%%%%%%%%%%%%%%%%% End Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramsST = [];
paramsHR = [];
gD = 0;
% load settings
if lowResDet
    paramsST = dLoad_STsettings;
    if paramsST.guidedDetector
       gD = 1; % if guided detector is true in either place, 
       % and the stage (low or high res) it's in is activated, then it
       % needs to be true any other active stage.
    end
end
if highResDet
    paramsHR = dLoad_HRsettings;
    if paramsHR.guidedDetector
       gD = 1;
    end
end

[metaDir,storeDir] = dBuild_dirs(baseDir,outDir);
% inDisk = fileparts(baseDir(1:3));

% Build list of (x)wav names in the base directory.
% Right now only wav and xwav files are looked for.
detFiles = dFind_xwavs(baseDir,depl);

if gD
    [detFiles,encounterTimes] = guidedDetection(detFiles,gDxls);
    fprintf('Using guided detections from file %s \n',gDxls')
    %graphDir = 1;
else 
    encounterTimes = [];
end

viewPath = {metaDir, baseDir};

% return a list of files to be built
[fullFiles,fullLabels] = get_fileset(baseDir,metaDir,detFiles); 

% profile on
% profile clear
if ~isempty(detFiles)
    % Short time detector
    if lowResDet
        tic 
        display('Beginning low-res detection\n')
        dtST_batch(fullLabels,fullFiles,paramsST,metaDir); % run detector
        display('Done with low-res detector\n')
        toc
    end
    
    % High res detector
    if highResDet
        tic
        dHighres_click_batch(fullFiles,fullLabels,storeDir,paramsHR,...
            metaDir,baseDir,tfFullFile,encounterTimes)
        display('Done with high-res detector\n')
        toc
    end
else
    disp('Error: No wav/xwav files found')
end

% profile viewer
% profile off
