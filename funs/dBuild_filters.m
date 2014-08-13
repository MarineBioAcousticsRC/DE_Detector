function [previousFs,fftSize,fftWindow,binWidth_Hz,freq_kHz,...
   wideBandFilter,specRange] = dBuild_filters(p,fs)

% On first pass, or if a file has a different sampling rate than the
% previous, rebuild the high pass filter

% ToDo: change to IIR filters for speed?

wideBandFilter = spBuildEquiRippleFIR(p.bpRanges, [0, 1], 'Fs', fs);
previousFs = fs;

fftSize = ceil(fs * p.frameLengthUs / 1E6);
if rem(fftSize, 2) == 1
    fftSize = fftSize - 1;  % Avoid odd length of fft
end

fftWindow = hanning(fftSize)';

lowSpecIdx = round(p.bpRanges(1)/fs*fftSize)+1;
highSpecIdx = round(p.bpRanges(2)/fs*fftSize)+1;

specRange = lowSpecIdx:highSpecIdx;
binWidth_Hz = fs / fftSize;
binWidth_kHz = binWidth_Hz / 1000;
freq_kHz = (specRange-1)*binWidth_kHz;  % calculate frequency axis
