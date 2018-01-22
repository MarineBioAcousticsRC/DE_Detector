function dtST_batch(fullLabels,fullFiles,p,metaDir)
% Runs a quick energy detector on a set of files using
% the specified set of detection parameters. Flags times containing signals
% of interest, and outputs the results to a .c file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = size(fullFiles,2);

for idx = 1:N  % "parfor" works here, parallellizing the process across as
    % many cores as your machine has available.
    % It's faster, but the drawback is that if the code crashes,
    % it's hard to figure out where it was, and how many files
    % have been completed. It will also eat up your cpu.
    % You can use regular "for" too.
    
    outFileName = fullLabels{idx};
    
    detections = [];
    %if ~exist(outFileName,'file')~=2
    
    % Pull in a file to examine
    currentRecFile = fullFiles{idx};
    [~,strippedName,fType1] = fileparts(currentRecFile);
    [~,~,fType2] = fileparts(strippedName);
    fType = [fType2,fType1];
    % Read the file header info
    if strncmpi(fType,'.wav',4)
        hdr = ioReadWavHeader(currentRecFile, p.DateRE);
        % divide wav into smaller bits for processing ease
        [startsSec,stopsSec] = dST_choose_segments(p,hdr);
    elseif strcmp(fType,'.x.wav')
        hdr = ioReadXWAVHeader(currentRecFile);
        if ~isempty(hdr)
            % divide xwav by raw file
            [startsSec,stopsSec] = dST_choose_segments_raw(hdr);
        else
            continue
        end
        
    end
    % Determine channel of interest
    channel = p.chan;
    
    % Open audio file
    fid = fopen(currentRecFile, 'r');
   
    % Build a band pass filter
    bandPassRange = p.fRanges;
    filtType = 'bandpass';
    p.filterSignal = true;
    % handle different filter cases
    if p.fRanges(1)== 0
       % they only specified a top freqency cutoff, so we need a low pass
       % filter
       bandPassRange = p.fRanges(2);
       filtType = 'low';
       if bandpassRange == hdr.fs/2
           % they didn't specify any cutoffs, so we need no filter
           p.filterSignal = false;
       end
    end
    if p.fRanges(2)== hdr.fs/2 && p.filterSignal
       % they only specified a lower freqency cutoff, so we need a high pass
       % filter
        bandPassRange = p.fRanges(1);
        filtType = 'high';
    end    
    if p.filterSignal
        [B,A] = butter(p.filterOrder, bandPassRange./(hdr.fs/2),filtType);
        filtTaps = length(B);
    end
    % Loop through search area, running short term detectors
    for k = 1:length(startsSec)
        % Select iteration start and end
        startK = startsSec(k);
        stopK = stopsSec(k);
        
        % Read in data segment
        if strncmp(fType,'.wav',4)
            data = ioReadWav(fid, hdr, startK, stopK, 'Units', 's',...
                'Channels', channel, 'Normalize', 'unscaled')';
        else
            data = ioReadRaw(fid, hdr, k, channel);
        end
        if isempty(data)
            warning('No data read from current file segment. Skipping.')
            continue
        end
        % bandpass
        if p.filterSignal
            filtData = filter(B,A,data);
        else
            filtData = data;
        end
        energy = filtData.^2;
        
        buffSamples = p.buff*hdr.fs;
        % Flag times when the amplitude rises above a threshold
        spotsOfInt = find(energy>(p.thresholds));
        detStart = max((((spotsOfInt - buffSamples)/hdr.fs)+startK),startK);
        detStop = min((((spotsOfInt + buffSamples)/hdr.fs)+startK),stopK);
        
        % Merge flags that are close together.
        if length(detStart)>1
            [stopsM,startsM] = spMergeCandidates(buffSamples/hdr.fs,detStop',detStart');
        else
            startsM = detStart;
            stopsM = detStop;
        end
        
        % Add current detections to overall detection vector
        % detections = [detections; signalBins];
        if ~isempty(startsM)
            detections = [detections;[startsM,stopsM]];
        end
    end
    
    % done with current audio file
    fclose(fid);
    
    % Write out .c file for this audio file
    if ~isempty(detections)
        ioWriteLabel(outFileName, detections);
    else % write zeros to file if no detections.
        ioWriteLabel(outFileName, [0,0])
    end
    %end
end