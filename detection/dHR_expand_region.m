function [c_starts,c_stops] = dHR_expand_region(p,hdr,sStarts,sStops,energy,bpDataHi)
% Expand region to lower thresholds

N = length(energy);
c_starts = nan(length(sStarts),1);   % init complete clicks to single/partial clicks
c_stops = nan(length(sStarts),1);
k=1;
clickSampleLims = ceil((hdr.fs./1e6).*[p.minClick_us, p.maxClick_us]);

dataSmooth = smooth(energy,20);
%thresh = prctile(energy,50);
thresh = p.countThresh/10;
bufVal = round(2E-5*hdr.fs);
if length(sStarts)<1000
for itr = 1:length(sStarts)
    rangeVec = sStarts(itr):sStops(itr);
    % make an envelope: TODO - try hilbert and first diff? While loops are
    % slow, but need to think of an alternative solution.
    [m, mI] = max(energy(rangeVec));
    
    % bpMean = mean(smoothEnergy([1:500,end-500:end]));
    % bpStd = std(dataSmooth([1:500,end-500:end]));
    % find the largest peak
    %largePeakList = sort(find(energy(rangeVec) > .5*m));
    % midx = rangeVec(largePeakList(1));
    midx = rangeVec(mI);
    %leftmost = bufVal+1;
    %Repeat for complete clicks using running mean of energy
    leftIdx = find(dataSmooth(1:midx)<=thresh,1,'last');
    rightIdx = find(dataSmooth(midx+1:end)<=thresh,1,'first')+(midx+1);
    %
    %     leftIdx = max(midx - 1,leftmost);
    %     while leftIdx > leftmost && mean(dataSmooth(leftIdx-bufVal:leftIdx) > thresh)~=0 % /2
    %         leftIdx = leftIdx - 1;
    %     end
    %
    %     rightmost = N-bufVal-1;
    %     rightIdx = midx+1;
    %     while rightIdx < rightmost && mean(dataSmooth(rightIdx:rightIdx+bufVal) > thresh)~=0%+bpStd/2
    %         rightIdx = rightIdx+1;
    %     end
    if isempty(leftIdx)
        leftIdx=1;
    end
    if isempty(rightIdx)
        rightIdx = length(energy);
    end
    c_starts(k,1) = leftIdx;
    c_stops(k,1) = rightIdx;
    %clf;plot(bpDataHi);hold on;plot(dataSmooth,'r');plot([c_starts,c_stops],zeros(size([c_starts,c_stops])),'*g')
    
    k = k+1
    
end

if length(c_starts)>1
    [c_starts,IX] = sort(c_starts);
    c_stops = c_stops(IX);
    [c_stops,c_starts] = spMergeCandidates(p.mergeThr,c_stops,c_starts);
    %clf;plot(bpDataHi);hold on;plot([c_starts,c_stops],zeros(size([c_starts,c_stops])),'*g');
    %1;%;plot(dataSmooth,'r')
end
throwIdx = zeros(size(c_stops));
for k2 = 1:length(c_stops)
    % Discard short signals or those that run past end of signal
    if c_stops(k2) >= N-2 %|| c_stops(k2) - c_starts(k2) < clickSampleLims(1) ||...
            %c_stops(k2) - c_starts(k2) > clickSampleLims(2)
        
        throwIdx(k2,1) = 1;
    end
end
% 

c_starts(throwIdx==1) = [];
c_stops(throwIdx==1) = [];
else
    c_starts = [];
    c_stops = [];
end