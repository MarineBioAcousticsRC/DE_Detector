% cat_click_times.m
% Could turn this into a function and instert at the end of de_detector.m
% function cat_click_times(inDir)
inDir = 'E:\metadata\bigDL'; % the path to your directory of detector outputs goes here
matList = dir(fullfile(inDir,'Tin*.mat'));
clickDnum = [];
sec2dnum = 60*60*24;
for i1 = 1:length(matList)
    clickTimes = [];
    clickDnumTemp = [];
    load(fullfile(inDir,matList(i1).name),'hdr','clickTimes')
    
   
    if ~isempty(clickTimes)
        clickDnumTemp = (clickTimes./sec2dnum) + hdr.start.dnum + datenum([2000,0,0]);
        clickDnum = [clickDnum,clickDnumTemp];
           
    end
    clickTimeRel = zeros(size(clickDnumTemp));
    rawStarts = hdr.raw.dnumStart + datenum([2000,0,0]);
    outFileName = strrep(matList(i1).name,'.mat','.lab');
    fidOut = fopen(fullfile(inDir,outFileName),'w+');
    for i2 = 1:size(clickTimes,1)
        thisRaw = find(rawStarts<=clickDnumTemp(i2,1),1,'last');
        clickTimeRel(i2,:) = (clickDnumTemp(i2,:) - rawStarts(thisRaw))*sec2dnum;
        fprintf(fidOut, '%f %f %d\n', clickTimeRel(i2,1),clickTimeRel(i2,2),i2);

    end
    fclose(fidOut);
end

save(fullfile(inDir,'AllClickDnum.mat'),'clickDnum')