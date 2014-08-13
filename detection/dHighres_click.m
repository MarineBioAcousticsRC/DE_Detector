function [completeClicks, noise] = dHighres_click(p,hdr, energy, bpDataHi)
% Tyack & Clark 2000 cite Au (1993) in Hearing by Whales & Dolphins, Au
% (ed.) stating that dolphins can distinguish clicks separated by as
% little as 205 us.

minGap_samples = ceil(hdr.fs/1e6 * p.mergeThr);
% smoothEnergy = fastsmooth(energy,p.teagerSmooth,1,1)';

% candidatesRel = find(smoothEnergy> p.countThresh);
candidatesRel = find(energy> p.countThresh);
if length(candidatesRel)<1
    candidatesRel = [];
end
completeClicks=[];
noise = [];

if ~ isempty(candidatesRel)

    % noise = dHR_get_noise(candidatesRel,length(energy),p,hdr);

    [sStarts, sStops] = spDurations(candidatesRel, minGap_samples,length(energy));

    [c_starts,c_stops]= dHR_expand_region(p,hdr,...
            sStarts,sStops,energy,bpDataHi);
    
    completeClicks = [c_starts, c_stops];

end
