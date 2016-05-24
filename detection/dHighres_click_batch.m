function dHighres_click_batch(fullFiles,fullLabels,inDisk,p,viewPath,tfFullFile)

N = length(fullFiles);
parfor idx1 = 1:N % for each data file
    previousFs = 0; % make sure we build filters on first pass
    %(has to be inside loop for parfor, ie, filters are rebuilt every time,
    % can be outside for regular for)

    % figure out which files are needed, where to find them.
    [hdr,channel,labelFile]...
        = dInput_HR_files(fullFiles{idx1},fullLabels{idx1},viewPath,p);
    
    if isempty(hdr.fs)
        continue % skip if you couldn't read a header
    elseif hdr.fs ~= previousFs
        % otherwise, if this is the first time through, build your filters,
        % only need to do this once though, so if you already have this
        % info, this step is skipped
        [previousFs,fftSize,fftWindow,binWidth_Hz,freq_kHz,...
            fB,fA,specRange] = dBuild_filters(p,hdr.fs);
        
        % Determine the frequencies for which we need the transfer function
        xfr_f = (specRange(1)-1)*binWidth_Hz:binWidth_Hz:(specRange(end)-1)*binWidth_Hz;
        if ~isempty(tfFullFile)
            [xfr_f, xfrOffset] = dtf_map(tfFullFile, xfr_f);
        else
            % if you didn't provide a tf function, then just create a
            % vector of zeros of the right size.
            xfrOffset = zeros(size(xfr_f));
        end
        xfrOffset = xfrOffset';
    end
    
    if exist([inDisk 'metadata\' labelFile],'file')
        % Read in the .c file produced by the short term detector.
        [starts,stops,~] = ioReadLabelFile([inDisk 'metadata\' labelFile]);
    else 
        continue
    end
    % Open xwav file
    fid = ioOpenViewpath(fullFiles{idx1}, viewPath, 'r');
    
    % Look for clicks, hand back parameters of retained clicks
    [clickTimes,ppSignalVec,durClickVec,bw3dbVec,yNFiltVec,yFiltVec,...
        specClickTfVec, specNoiseTfVec, peakFrVec,yFiltBuffVec,f,deltaEnvVec,nDurVec]...
        = dProcess_HR_starts(fid, fB,fA,starts,stops,channel,...
        xfrOffset,specRange,p,hdr,fullFiles{idx1},fftWindow,fullLabels{idx1});
    
    % Done with that file
    fclose(fid);
    fclose all;
    fprintf('done with %s\n', fullFiles{idx1});
    
    % Run post processing to remove rogue loner clicks, prior to writing
    % the remaining output files.
    delFlag = clickInlinePProc(fullLabels{idx1},clickTimes,p);
    delIdx = find(delFlag==1);
    
    % save a mat file now, rather than recalculating later
    clickTimes = clickTimes(delIdx,:);
    ppSignal = ppSignalVec(delIdx,:);
    durClick = durClickVec(delIdx,:);
    bw3db = bw3dbVec(delIdx,:);
    
    specClickTf = specClickTfVec(delIdx,:);
    specNoiseTf = specNoiseTfVec(delIdx,:);
    peakFr = peakFrVec(delIdx,:);
    deltaEnv = deltaEnvVec(delIdx,:);
    nDur = nDurVec(delIdx,:);
    
    if ~isempty(delIdx)
        yFilt = yFiltVec(delIdx);
        yFiltBuff = yFiltBuffVec(delIdx);
        yNFilt = yNFiltVec(delIdx);
    else
        yFilt = {};
        yFiltBuff = {};
        yNFilt = {};
    end
    save_dets2mat(strcat(fullLabels{idx1}(1:end-2),'.mat'),clickTimes,...
        ppSignal,durClick,f,hdr,nDur,deltaEnv,yNFilt,specNoiseTf,bw3db,...
        yFilt,specClickTf,peakFr,yFiltBuff,p,xfrOffset);
   
end