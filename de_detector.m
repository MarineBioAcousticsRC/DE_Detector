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

% clearvars
close all
fclose all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set transfer function location
% tfFullFile = 'E:\Code\TF_files\Hatteras\HAT02\673_131031\673_131031_invSensit.tf';
% Note, if you don't have a transfer function just use:
tfFullFile = [];

% Location of base directory containing directories of files to be analyzed
baseDir = 'I:\GofMX_DT07B\';

% Optional output directory location. Metadata directory will be created in outDir
% if specified, otherwise it will be created in baseDir.
outDir  = []; 
% or use:
% outDir = '<your path here>';

% Name of the deployment. This should be the first few characters in the 
% directory(ies) you want to look in you want to look at. For now,
% directory hierarchy is expected to be: basedir>depl*>*.x.wav
% TODO: implement recursive directory search for more flexibility.
depl = 'GofMX';

% Set flags indicating which routines to run. 
lowResDet = 1; %run short time detector.
highResDet = 1; %run high res detector
%%%%%%%%%%%%%%%%%%%%%%%%%%%% End Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[metaDir,storeDir] = dBuild_dirs(baseDir,outDir);
% inDisk = fileparts(baseDir(1:3));

% Build list of (x)wav names in the base directory.
% Right now only wav and xwav files are looked for.
[detFiles]= dFind_xwavs(baseDir,depl); % doesn't read in manual detection 
% files in this version, but this can be added pretty easily, using an
% older version.

viewPath = {metaDir, baseDir};
[fullFiles,fullLabels] = get_fileset(baseDir,metaDir,detFiles); % returns a list of files to scan through
% profile on
% profile clear
if ~isempty(detFiles)
    % Short time detector
    if lowResDet == 1
        % load settings
        parametersST = dLoad_STsettings;
        % run detector
        dtST_batch(baseDir,detFiles,parametersST,viewPath);
    end
    
    % High res detector
    if highResDet == 1
        % load settings
        parametersHR = dLoad_HRsettings;
        % run detector
        dHighres_click_batch(fullFiles,fullLabels,storeDir,parametersHR,viewPath,tfFullFile)
    end
end

% profile viewer
% profile off