function data = ft_read_cont(filename, blkid)

arguments
    filename char
    blkid double {mustBeInteger,mustBePositive} = []
end

data = [];
data.label = {};
data.time = {};
data.trial = {};
data.sampleinfo = [];
data.trialinfo = [];
data.cfg = [];

allContIds = dh.enumcont(filename);

% take all cont blocks if blkid is not specified
if isempty(blkid)
    blkid = allContIds;
end

if any(~ismember(blkid, allContIds))
    error('dhfun2:ft_read_cont:InvalidBlockId', 'Invalid CONT block ID specified');
end

[nSamples, nChanInCont] = dh.getcontsize(filename, blkid);
if ~all(nSamples == nSamples(1))
    error('dhfun2:ft_read_cont:NonMatchingNumberOfSamples', 'Not all selected CONT blocks have the same number of samples');
end
nSamples = nSamples(1);
nChannels = sum(nChanInCont);


samplePeriod = dh.getcontsampleperiod(filename, blkid);
if ~all(samplePeriod == samplePeriod(1))
    error('dhfun2:ft_read_cont:NonMatchingSamplePeriods','Not all selected CONT blocks have the same sample period');
end
samplePeriod = samplePeriod(1);
data.fsample = 1/samplePeriod*1E9;

nIndex = dh.getcontindexsize(filename, blkid);
if any(nIndex > 1)
    warning('dhfun2:ft_read_cont:MultipleTrialsPerCont', 'File contains multiple trials per CONT block. This is not (yet) supported. All trials will be concatenated into one trial.');
end


data.label = cell(1,nChannels);
data.trial = {zeros(nChannels, nSamples)};

channelBegin = 1;
for iCont = 1:length(blkid)
    channelEnd = channelBegin + nChanInCont(iCont)-1;
    data.trial{1}(channelBegin:channelEnd,:) = dh.readcont(filename, blkid(iCont));
    
    for iChannel = 0:nChanInCont(iCont)-1
        data.label{channelBegin+iChannel} = sprintf('CONT%d/%02d', blkid(iCont), iChannel);
    end
    channelBegin = channelEnd+1;
end

% time of first sample
tStart = zeros(1,length(blkid));
for iCont = 1:length(blkid)
    [time, offset] = dh.readcontindex(filename, blkid(iCont));
    tStart(iCont) = time(1);
end
if ~all(tStart == tStart(1))
    warning('dhfun2:ft_read_cont:NonMatchingStartTime', 'Not all selected CONT blocks have the same start time. The first start time will be used.');
end
tStart = tStart(1)/1e9;

% time
data.time = {(0:nSamples-1)*samplePeriod/1E9 + tStart};

% sampleinfo: the begin and endsample of each trial relative to the recording on disk
data.sampleinfo = [1, nSamples];

% hdr (header information of the original dataset on disk)
data.hdr = dh.ft_read_header(filename);

% cfg
data.cfg = [];
data.cfg.previous = [];
data.cfg.filename = filename;
data.cfg.iContBlock = blkid;
data.cfg.date = datetime();
data.cfg.operator = char(java.lang.System.getProperty('user.name'));
data.cfg.tool = "dhfun2:ft_read_cont";
data.cfg.dhfunVersion = dh.version();
[data.cfg.previous.opnames, data.cfg.previous.opinfos] = dh.getoperationinfos(filename);

% TODO:
% - trialinfo

% Check data if Fieldtrip is available on the path
if exist('ft_defaults', 'file') == 2
    ft_defaults;
    data = ft_checkdata(data, 'datatype', 'raw', 'feedback', 'yes', 'ismeg', 'no', 'iseeg', 'no');
end

end