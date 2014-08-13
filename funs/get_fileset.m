function [fullFiles,fullLabels] = get_fileset(baseDir,metaDir,detFiles)
% Make list of what you're going to name your output files, for easy
% reference later.
fullFiles = [];
fullLabels = [];
for f2 = 1:length(detFiles)
    thisFile = detFiles(f2,:);
    fullFiles{f2}= fullfile(baseDir,thisFile);
    [pathStr, thisName, ~] = fileparts(thisFile);
    thisName = ([thisName(1:length(thisName)-2),'.c']);
    fullLabels{f2} = fullfile(metaDir,pathStr,thisName);
end
