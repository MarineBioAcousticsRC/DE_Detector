function [cParams,f] = dProcess_HR_starts(fid,starts,stops,...
    p,hdr,recFile,labelFile)

% Initialize vectors for main detector loop
cParams.clickTimes = nan(1E5,2);
cParams.ppSignalVec = nan(1E5,1);
cParams.durClickVec = nan(1E5,1);
cParams.bw3dbVec = nan(1E5,3);
cParams.specClickTfVec = nan(1E5,length(p.specRange));
cParams.specNoiseTfVec = nan(1E5,length(p.specRange));
cParams.peakFrVec = nan(1E5,1);
cParams.deltaEnvVec = nan(1E5,1);
cParams.nDurVec = nan(1E5,1);
% time series stored in cell arrays because length varies
cParams.yNFiltVec = cell(1E5,1);
cParams.yFiltVec = cell(1E5,1);
cParams.yFiltBuffVec = cell(1E5,1);

f = [];
sIdx = 1;
eIdx = 0;

numStarts = length(starts);
fidOut = fopen(strcat(labelFile(1:end-1),p.clickAnnotExt),'w+');

for k = 1:numStarts % stepping through using the start/end points
    
    % Filter the data
    wideBandData = dGet_filtered_data(fid,starts(k),stops(k),hdr,...
        p,recFile);
    
    % Look for click candidates
    [clicks, noise] = dHighres_click(p, hdr, wideBandData);
    
    if ~ isempty(clicks)
        % if we're in here, it's because we detected one or more possible
        % clicks in the kth segment of data
        % Make sure our click candidates aren't clipped
        validClicks = dPrune_clipping(clicks,p,hdr,wideBandData);
        
        % Look at power spectrum of clicks, and remove those that don't
        % meet peak frequency and bandwidth requirements
        clicks = clicks(validClicks==1,:);
        
        % Compute click parameters to decide if the detection should be kept
        [clickInd,ppSignal,durClick,bw3db,yNFilt,yFilt,specClickTf,...
            specNoiseTf,peakFr,yFiltBuff,f,deltaEnv,nDur] = ...
            clickParameters(noise,wideBandData,p,clicks,hdr);
        
        if ~isempty(clickInd)
            % Write out .cTg file
            [clkStarts,clkEnds] = dProcess_valid_clicks(clicks,clickInd,...
                starts(k),hdr,fidOut,p);
            
            eIdx = sIdx + size(nDur,1)-1;
            cParams.clickTimes(sIdx:eIdx,1:2) = [clkStarts,clkEnds];
            cParams.ppSignalVec(sIdx:eIdx,1) = ppSignal;
            cParams.durClickVec(sIdx:eIdx,1) = durClick;
            cParams.bw3dbVec(sIdx:eIdx,:) = bw3db;
            cParams.yNFiltVec(sIdx:eIdx,:) = yNFilt';
            cParams.yFiltVec(sIdx:eIdx,:)= yFilt';
            cParams.specClickTfVec(sIdx:eIdx,:) = specClickTf;
            cParams.specNoiseTfVec(sIdx:eIdx,:) = specNoiseTf;
            cParams.peakFrVec(sIdx:eIdx,1) = peakFr;
            cParams.yFiltBuffVec(sIdx:eIdx,:) = yFiltBuff';
            cParams.deltaEnvVec(sIdx:eIdx,1) = deltaEnv;
            cParams.nDurVec(sIdx:eIdx,1) = nDur;
            sIdx = eIdx+1;
        end
    end
    if rem(k,1000) == 0
        fprintf('low res period %d of %d complete \n',k,numStarts)
    end
end

fclose(fidOut);

% prune off any extra cells that weren't filled
cParams.clickTimes = cParams.clickTimes(1:eIdx,:);
cParams.ppSignalVec = cParams.ppSignalVec(1:eIdx,:);
cParams.durClickVec = cParams.durClickVec(1:eIdx,:);
cParams.bw3dbVec = cParams.bw3dbVec(1:eIdx,:);
cParams.yFiltVec = cParams.yFiltVec(1:eIdx,:);
cParams.yNFiltVec = cParams.yNFiltVec(1:eIdx,:);
cParams.specClickTfVec = cParams.specClickTfVec(1:eIdx,:);
cParams.specNoiseTfVec = cParams.specNoiseTfVec(1:eIdx,:);
cParams.peakFrVec = cParams.peakFrVec(1:eIdx,:);
cParams.yFiltBuffVec = cParams.yFiltBuffVec(1:eIdx,:);
cParams.deltaEnvVec = cParams.deltaEnvVec(1:eIdx,:);
cParams.nDurVec = cParams.nDurVec(1:eIdx,:);
