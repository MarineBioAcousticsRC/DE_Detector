function [xwavNames] = get_xwavNames(xwavDir)
%
% modified from get_xwavdir
% emo 2/5/07

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the directory
%
% str1 = 'Select Disk containing XWAV file Directory';
% indir = 'G:\';
% xwavIndir = uigetdir(indir,str1);
% if xwavIndir == 0	% if cancel button pushed
%     return
% else
%     xwavDir = [xwavIndir,'\'];
% end

%%%%%%%%%%%%%%%%%%%%%%
% check for empty directory
%
d = dir(fullfile(xwavDir,'*.wav'));    % xwav files

fn = char(d.name);      % file names in directory
fnsz = size(fn);        % number of data files in directory 

% filenames
xwavNames = fn;
