function noise = dHR_get_noise(candidatesRel,stop,p,hdr)
% Get noise
minClick_samples = ceil(hdr.fs / 1e6 * p.minClick_us);
maxClick_samples = ceil(hdr.fs  /1e6 * p.maxClick_us);
noiseStart = 1;
candidateIdx = 1;
prevCandidate = 0;
noise = [];

while noiseStart < candidatesRel(end)
    noiseStop = min(stop, floor(candidatesRel(candidateIdx) ...
        - 0.5 * maxClick_samples));
    noiseStop = max(noiseStop,1);
    
    if noiseStop > noiseStart + minClick_samples
        noise = [noise; noiseStart noiseStop];
    end
    
    % take next noise start after possible click echo
    noiseStart = candidatesRel(candidateIdx) + 2 * maxClick_samples;
    
    while candidateIdx < length(candidatesRel) && ...
            (candidatesRel(candidateIdx)< noiseStart || ...
            candidatesRel(candidateIdx) - .5*maxClick_samples < ...
            prevCandidate)
        noiseStart = candidatesRel(candidateIdx) + 2 * maxClick_samples;
        prevCandidate = candidatesRel(candidateIdx);
        candidateIdx = candidateIdx+1;
    end
end

% Handle very last noise region
if stop - noiseStart > minClick_samples
    noise = [noise; noiseStart stop];
end

if isempty(noise) % if it didn't find any noise, grab some at random. This is pretty rare
    noise = [1:500];
end
