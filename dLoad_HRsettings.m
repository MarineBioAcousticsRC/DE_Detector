function parametersHR = dLoad_HRsettings

%%% Filter and FFT params %%
parametersHR.bpRanges = [10000,90000]; % Bandpass filter params in Hz [min,max]
parametersHR.frameLengthUs = 1200; % For fft computation
parametersHR.overlap = .5; % FFT overlap (in decimal, not percent form)
parametersHR.fs = 200000; % Sampling rate in Hz
parametersHR.chan = 1; % which channel do you want to look at?
parametersHR.clipThreshold = .98;%  Normalized clipping threshold btwn 0 and 1.  If empty, 
% assumes no clipping.


%%% Recieved level threshold params %%%
parametersHR.ppThresh = 110;% minimum  RL threshold - dB peak to peak.
parametersHR.countThresh = 5000; % Keep consistent with Lo-res for predictability.
% Can be higher than low res, but not lower!
% Keep count threshold less than equivalent pp threshold. 
%   dBs = 10*log10(abs(fft(counts *2^14))) - 10*log10(fs/(length(fftWindow)))...
%            + transfer function


%%% Envelope params %%%
parametersHR.energyThr = 0.5; % n-percent energy threshold for envelope duration
parametersHR.dEvLims = [0,.9];  % [min,max] Envelope energy distribution comparing 
% first half to second half of high energy envelope of click. If there is
% more energy in the first half of the click (dolphin) dEv >0, If it's more
% in the second half (boats?) dEv<0. If it's about the same (beaked whale)
% dEnv ~= 0 , but still allow a range...
parametersHR.delphClickDurLims = [2,14];% [min,max] duration in samples allowed
% for high energy envelope of click


%%% Other pruuning params %%%
parametersHR.cutPeakBelowKHz = 20; % discard click if peak frequency below X kHz
parametersHR.cutPeakAboveKHz = 80; % discard click if peak frequency above Y kHz 
parametersHR.minClick_us = 16;% Minimum duration of a click in us 
parametersHR.maxClick_us = 1000; % Max duration of a click including echos
parametersHR.maxNeighbor = 1; % max time in seconds allowed between neighboring 
% clicks. Clicks that are far from neighbors can be rejected using this parameter,
% good for dolphins in noisy environments because lone clicks or pairs of
% clicks are likely false positives

parametersHR.mergeThr = 50;% min gap between energy peaks in us. Anything less
% will be merged into one detection the beginning of the next is fewer
% samples than this, the signals will be merged.


%%% Params you probably don't need to change %%%
parametersHR.timeRE = ...
'.*B(?<hr>\d+)h(?<min>\d+)m(?<s>\d+)s(?<day>\d+)(?<mon>[a-zA-Z]+)(?<yr>\d+)y.*|(?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._-](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)|raven[\._](?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._-](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)|raven[\._](?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._-](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)';
parametersHR.clickAnnotExt = 'cTg';
parametersHR.ppExt = 'pTg';
parametersHR.groupAnnotExt = 'gTg';
