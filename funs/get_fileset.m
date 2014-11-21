function [fullFiles,fullLabels] = get_fileset(baseDir,metaDir,detFiles)
% Make list of what you're going to name your output files, for easy
% reference later.
fullFiles = [];
fullLabels = [];
for f2 = 1:size(detFiles,1)
    thisFile = detFiles(f2,:);
    fullFiles{f2}= fullfile(baseDir,thisFile);
    [pathStr, thisName, ~] = fileparts(thisFile);
    if strfind(thisFile,'.x.wav')
        thisName = ([thisName(1:size(thisName,2)-2),'.c']);
    else 
        thisName = [thisName,'.c'];
    end
    fullLabels{f2} = fullfile(metaDir,pathStr,thisName);
end
