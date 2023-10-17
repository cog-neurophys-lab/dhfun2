function header = ft_read_header(filename)
% This returns a header structure with the following fields
%   header.Fs          = sampling frequency
%   header.nChans      = number of channels
%   header.nSamples    = number of samples
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
samplePeriods = dh.getcontsampleperiod(filename, conts);

if ~all(samplePeriods(1) == samplePeriods)

    % select the most occuring sampling period
    [mostCommonSamplePeriod, iSelectedSamplePeriods] = pick_most_common_element(samplePeriods);
    warning("dhfun2:ft_read_header:NonMatchingSamplePeriods", ...
        "Sampling periods of CONT blocks in DH5 file don't match.\n\tExcluding CONT blocks:\n\t %s", num2str(conts(samplePeriods(1) ~= samplePeriods)))
    header.Fs = 1./mostCommonSamplePeriod*1e9;
    conts = conts(iSelectedSamplePeriods);
else
    header.Fs = 1/samplePeriods(1)*1E9;

end
% header.TimeStampPerSample = samplePeriods;
% header.FirstTimeStamp =

%% number of samples
[nSamples, nChanInCont] = dh.getcontsize(filename, conts);

% check if its the same across CONT blocks
if ~all(nSamples(1) == nSamples)

    % select the most common number of samples
    [mostCommonNSamples, iSelectedNSamples] = pick_most_common_element(nSamples);
    warning("dhfun2:ft_read_header:NonMatchingNSamples", "Number of samples in CONT blocks of DH5 file don't match.\n\tExcluding CONT blocks:\n\t %s", num2str(conts(nSamples(1) ~= nSamples)));
    header.nSamples = mostCommonNSamples;
    conts = conts(iSelectedNSamples);
    nChanInCont = nChanInCont(iSelectedNSamples);
else
    header.nSamples = nSamples(1);
end
header.nSamplesPre = 0;
nChannels = sum(nChanInCont);

%% channel labels
header.label = cell(1, nChannels);
header.chancount = cell(1, nChannels);
count = 1;
for iCont = 1:length(conts)
    cont = conts(iCont);
    for iChan = 0:nChanInCont(iCont)-1
        header.label{count} = sprintf('CONT%d/%02d', cont, iChan);
        header.chantype{count} = 'lfp';
        header.chanunit{count} = 'V';
        count = count + 1;
    end
end

end