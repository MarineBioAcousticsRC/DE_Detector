function [previousFs,fftSize,fftWindow,binWidth_Hz,freq_kHz,...
   fB,fA,specRange] = dBuild_filters(p,fs)

% On first pass, or if a file has a different sampling rate than the
% previous, rebuild the high pass filter
[fB,fA] = butter(p.filterOrder, p.bpRanges./(fs/2));

%[fA,fB] = ellip(4,0.1,40,p.bpRanges.*2/fs,'bandpass');
% filtTaps = length(fB);
previousFs = fs;

fftSize = ceil(fs * p.frameLengthUs / 1E6);
if rem(fftSize, 2) == 1
    fftSize = fftSize - 1;  % Avoid odd length of fft
end

fftWindow = hann(fftSize)';

lowSpecIdx = round(p.bpRanges(1)/fs*fftSize)+1;
highSpecIdx = round(p.bpRanges(2)/fs*fftSize)+1;

specRange = lowSpecIdx:highSpecIdx;
binWidth_Hz = fs / fftSize;
binWidth_kHz = binWidth_Hz / 1000;
freq_kHz = (specRange-1)*binWidth_kHz;  % calculate frequency axis
