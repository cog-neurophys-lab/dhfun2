function header = ft_read_header(filename)
% This returns a header structure with the following fields
%   header.Fs          = sampling frequency
%   header.nChans      = number of channels
%   header.nSamples    = number of samples per trial
%   header.nSamplesPre = number of pre-trigger samples in each trial
%   header.nTrials     = number of trials
%   header.label       = Nx1 cell-array with the label of each channel
%   header.chantype    = Nx1 cell-array with the channel type, see FT_CHANTYPE
%   header.chanunit    = Nx1 cell-array with the physical units, see FT_CHANUNIT
% For some data formats that are recorded on animal electrophysiology
% systems (e.g. Neuralynx, Plexon), the following optional fields are
% returned, which allows for relating the timing of spike and LFP data
%   header.FirstTimeStamp      number, represented as 32-bit or 64-bit unsigned integer
%   header.TimeStampPerSample  number, represented in double precision
%


header = [];

%% TODO: handle selection of CONT blocks
conts = dh.enumcont(filename);

%% determine number of trials
trialMapData = h5read(filename, '/TRIALMAP');
header.nTrials = length(trialMapData.TrialNo);


%% determine sampling frequency
samplePeriods = zeros(size(conts));
for iCont = 1:length(conts)
    cont = conts(iCont);
    samplePeriods(iCont) = dh.getcontsampleperiod(filename, cont);
end
if ~all(samplePeriods(1) == samplePeriods)
    error("dhfun2:ft_read_header", "Sampling periods of CONT blocks in DH5 file don't match")
end
header.Fs = 1/samplePeriods(1)*1E9;

%% number of samples
nSamples = zeros(size(conts));
nChannels = 0;
for iCont = 1:length(conts)
    [nSamples(iCont), nChanInCont] = dh.getcontsize(filename, conts(iCont));
    nChannels = nChannels + nChanInCont;
end
% check if its the same across CONT blocks
if ~all(nSamples(1) == nSamples)
    error("dhfun2:ft_read_header", "Number of samples in CONT blocks of DH5 file don't match")
end
header.nSamples = nSamples(1);
header.nSamplesPre = 0;

%% channel labels
header.label = cell(1, nChannels);
header.chancount = cell(1, nChannels);
count = 1;
for iCont = 1:length(conts)
    cont = conts(iCont);
    [~, nChanInCont] = dh.getcontsize(filename, cont);
    for iChan = 0:nChanInCont-1
        header.label{count} = sprintf("CONT%04d-%03d", cont, iChan);
        header.chantype{count} = 'lfp';
        header.chanunit{count} = 'V';
        count = count + 1;
    end
end

end