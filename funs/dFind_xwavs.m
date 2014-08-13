function [xwavNames,startFile]= dFind_xwavs(baseDir,depl)

% Find folders in baseDir
folders = dir(baseDir);
% Remove those that don't belong to data
for fidx = 1:length(folders)
    true = strfind(folders(fidx).name, depl);
    decim = strfind(folders(fidx).name, 'd100');
    if isempty(true) || ~isempty(decim)
        trueIdx(fidx) = 0;
    else
        trueIdx(fidx) = 1;
    end
end

keep = find(trueIdx==1);
% Build file structure
folderNames = [];
for fidx = 1:length(keep)
    if isdir(fullfile(baseDir,folders(keep(fidx)).name)) == 1
        folderNames = [folderNames; char(folders(keep(fidx)).name)];
    end
end


% Pull out x.wav files from all folders, combine full paths into one long list
xwavNames = [];
for fidx = 1:size(folderNames,1)
    xwavDir = [baseDir,folderNames(fidx,:)];
    xwavs = get_xwavNames(xwavDir);
    xwavList = [];
    for s = 1:size(xwavs,1)
        xwavList(s,:) = fullfile(folderNames(fidx,:),xwavs(s,:));
    end
    xwavNames = [xwavNames;char(xwavList)];
end

%parse out all dates and times for the start of each xwav file
ds = size(xwavNames,2);
startFile = [];
for m = 1:size(xwavNames,1)
    file = xwavNames(m,:);
    dateFile = [str2num(['20',file(ds-18:ds-17)]),str2num(file(ds-16:ds-15)),...
        str2num(file(ds-14:ds-13)),str2num(file(ds-11:ds-10)),...
        str2num(file(ds-9:ds-8)),str2num(file(ds-7:ds-6))];
    startFile = [startFile; datenum(dateFile)];
end
