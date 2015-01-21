function dtST_batch(baseDir,detFiles,p,viewPath)
% Runs a quick energy detector on a set of files using
% the specified set of detection parameters. Flags times containing signals
% of interest, and outputs the results to a .c file
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = size(detFiles,1);

for idx = 1:N  % "parfor" works here, parallellizing the process across as
    % many cores as your machine has available.
    % It's faster, but the drawback is that if the code crashes,
    % it's hard to figure out where it was, and how many files
    % have been completed. You can use regular "for" too.
    
    outLabel = regexprep(detFiles(idx,:), p.REWavExt, '.c','ignorecase');
    outFileName = ioGetWriteNameViewpath(outLabel, viewPath, true);
    detections = [];
    if ~exist(outFileName,'file')~=2
        
        % Pull in a file to examine
        currentFile = fullfile(baseDir, detFiles(idx,:));
        [~,strippedName,fType1] = fileparts(currentFile);
        [~,~,fType2] = fileparts(strippedName);
        fType = [fType2,fType1];
        % Read the file header info
        if strncmp(fType,'.wav',4)
            hdr = ioReadWavHeader(currentFile, p.DateRE);
            % divide wav into smaller bits for processing ease
            [startsSec,stopsSec] = dST_choose_segments(p,hdr);

        elseif strcmp(fType,'.x.wav')
            hdr = ioReadXWAVHeader(currentFile);
            % divide xwav by raw file
            [startsSec,stopsSec] = dST_choose_segments_raw(hdr);

        end
        % Determine channel of interest
        channel = p.chan;
                
        % Open audio file
        fid = fopen(currentFile, 'r');
        
        % Build a band pass filter
        STFilter = spBuildEquiRippleFIR(p.fRanges, [0, 1], 'Fs', hdr.fs);
        filtTaps = length(STFilter);
        
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
            
            % bandpass
            filtData = filter(STFilter,1,data);
            filtData = filtData(filtTaps+1:end).^2;
            
            % Flag times when the amplitude rises above a threshold
            spotsOfInt = find(filtData>(p.thresholds));
            detStart = max((((spotsOfInt - p.buff)/hdr.fs)+startK),startK);
            detStop = min((((spotsOfInt + p.buff)/hdr.fs)+startK),stopK);
             
            % Merge flags that are close together.
            if length(detStart)>1
                [stopsM,startsM] = spMergeCandidates(p.buff/hdr.fs,detStop',detStart');
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
            ioWriteLabel(outFileName, detections,[]);
        else % write zeros to file if no detections.
            ioWriteLabel(outFileName, [0,0,0],[])
        end
    end
end