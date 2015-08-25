function [wideBandData] = dGet_filtered_data(fid,start,stop,hdr,...
    fB,fA,channel,fullFiles)

wideBandTaps = length(fB);
duration = stop - start;
duration_samples = duration * hdr.fs;
if duration_samples <= 3*wideBandTaps
    % if data is too short for our filter, read a little more
    % on either side making sure not to go past the beginning/
    % end of file.
    pad_s = (length(fB)*3) / hdr.fs;
    start = max(0, start - pad_s);
    stop = stop + pad_s;
    if hdr.start.dnum + datenum([0 0 0 0 0 stop]) > hdr.end.dnum
        stop = (hdr.end.dnum - hdr.start.dnum) * 24*3600;
    end
end

% read in the data
data = ioReadXWAV(fid, hdr, start, stop, channel, fullFiles);

% filter the data
wideBandData = filter(fB,fA,data,[],2);
wideBandData = wideBandData(:,wideBandTaps+1:end);