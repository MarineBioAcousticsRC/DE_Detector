function dHighres_click_batch(fullFiles,fullLabels,p,...
    tfFullFile, encounterTimes)

N = length(fullFiles);
for idx1 = 1:N % for each data file
    fprintf('beginning file %d of %d \n',idx1,N)
    previousFs = 0; % make sure we build filters on first pass
    %(has to be inside loop for parfor, ie, filters are rebuilt every time,
    % can be outside for regular for)
    
    recFile = fullFiles{idx1};
    labelFile = fullLabels{idx1};
    
    % read file header
    hdr = dInput_HR_files(recFile,p);
    
    if isempty(hdr.fs)
        continue % skip if you couldn't read a header
    elseif hdr.fs ~= previousFs
        % otherwise, if this is the first time through, build your filters,
        % only need to do this once though, so if you already have this
        % info, this step is skipped
        [previousFs,~,p.fftWindow,p.binWidth_Hz,~,...
            p.fB,p.fA,p.specRange] = dBuild_filters(p,hdr.fs);
        
        % Determine the frequencies for which we need the transfer function
        p.xfr_f = (p.specRange(1)-1)*p.binWidth_Hz:p.binWidth_Hz:...
            (p.specRange(end)-1)*p.binWidth_Hz;
        if ~isempty(tfFullFile)
            [p.xfr_f, p.xfrOffset] = dtf_map(tfFullFile, p.xfr_f);
            % p.countThresh = (10^((p.ppThresh-max(p.xfrOffset))./20));
            p.countThresh = 10000;
        else
            % if you didn't provide a tf function, then just create a
            % vector of zeros of the right size.
            p.countThresh = p.countThresh;
            p.ppThresh = 20*log10(2*sqrt(p.countThresh));
            p.xfrOffset = zeros(size(p.xfr_f));
        end
    end
    
    if exist(labelFile,'file')
        % Read in the .c file produced by the short term detector.
        [starts,stops] = ioReadLabelFile(labelFile);
    else
        continue
    end
    % Open xwav file
    fid = fopen(recFile, 'r');
    
    % Look for clicks, hand back parameters of retained clicks
    [cParams,f] = dProcess_HR_starts(fid,starts,stops,...
        p,hdr,recFile,labelFile);
    
    % Done with that file
    fclose(fid);
    fclose all;
    fprintf('done with %s\n', recFile);
    
    % Run post processing to remove rogue loner clicks, prior to writing
    % the remaining output files.
    clickTimes = sortrows(cParams.clickTimes);
    
    delFlag = clickInlinePProc(labelFile,clickTimes,p,hdr,encounterTimes);
    delIdx = find(delFlag==1);
    
    % save a mat file now, rather than recalculating later
    clickTimes = clickTimes(delIdx,:);
    ppSignal = cParams.ppSignalVec(delIdx,:);
    durClick = cParams.durClickVec(delIdx,:);
    bw3db = cParams.bw3dbVec(delIdx,:);
    
    specClickTf = cParams.specClickTfVec(delIdx,:);
    specNoiseTf = cParams.specNoiseTfVec(delIdx,:);
    peakFr = cParams.peakFrVec(delIdx,:);
    deltaEnv = cParams.deltaEnvVec(delIdx,:);
    nDur = cParams.nDurVec(delIdx,:);
    
    if ~isempty(delIdx)
        yFilt = cParams.yFiltVec(delIdx);
        yFiltBuff = cParams.yFiltBuffVec(delIdx);
        yNFilt = cParams.yNFiltVec(delIdx);
    else
        yFilt = {};
        yFiltBuff = {};
        yNFilt = {};
    end
    save_dets2mat(strrep(labelFile,'.c','.mat'),clickTimes,...
        ppSignal,durClick,f,hdr,nDur,deltaEnv,yNFilt,specNoiseTf,bw3db,...
        yFilt,specClickTf,peakFr,yFiltBuff,p);
    
end