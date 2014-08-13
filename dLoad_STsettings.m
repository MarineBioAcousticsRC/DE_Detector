function parametersST = dLoad_STsettings

% Assign short term detector settings

parametersST.buff = 500; % # of buffer samples to add on either side of area of interest
parametersST.chan = 1; % which channel do you want to look at?

parametersST.fRanges = [10000 85000]; 
parametersST.thresholds = 5000; % Amplitude threshold in counts. 
% For predictability, keep this consistent between low and hi res steps.

parametersST.frameLengthSec = .01; %Used for calculating fft size
parametersST.overlap = .50; % fft overlap
parametersST.fType = 2; %1=wav, 2=x.wav
parametersST.REWavExt = '(\.x)?\.wav';%  expression to match .wav or .x.wav


