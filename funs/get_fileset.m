function [fullFiles,fullLabels] = get_fileset(baseDir,metaDir,detFiles)
% Make list of what you're going to name your output files, for easy
% reference later.
fullFiles = []; % wav or xwav
fullLabels = []; % .c files

for f2 = 1:size(detFiles,1)
    thisFile = detFiles(f2,:);
    fullFiles{f2}= thisFile;
    [pathStr, thisName, ext] = fileparts(thisFile);
    thisName2 = [thisName,ext];
    if strfind(thisName2,'.x.wav')
        thisLabel = strrep(thisName2,'.x.wav','.c');
    elseif strfind(thisName2,'.wav')
        thisLabel = strrep(thisName2,'.wav','.c');
    elseif strfind(thisName2,'.WAV')
        thisLabel = strrep(thisName2,'.WAV','.c');
    end
    fullLabels{f2} = fullfile(metaDir,thisLabel);
end
