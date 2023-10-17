function data = ft_read_cont(filename, blkid)

arguments
    filename char
    blkid double {mustBeInteger,mustBePositive} = []
end

allContIds = dh.enumcont(filename);

% take all cont blocks if blkid is not specified
if isempty(blkid)
    blkid = allContIds;
end

% hdr (header information of the original dataset on disk)
data.hdr = dh.ft_read_header(filename, blkid);

blkid = data.hdr.includedContIds;

if any(~ismember(blkid, data.hdr.includedContIds))
    error('dhfun2:ft_read_cont:InvalidBlockId', 'Invalid CONT block ID specified');
end

data.fsample = data.hdr.Fs;

nIndex = dh.getcontindexsize(filename, blkid);
if any(nIndex > 1)
    warning('dhfun2:ft_read_cont:MultipleTrialsPerCont', ...
        'File contains multiple trials per CONT block. This is not (yet) supported. All trials will be concatenated into one trial.');
end

% channel labels
data.label = data.hdr.label;

% trial (load actual data)
data.trial = {zeros(data.hdr.nChans, data.hdr.nSamples)};
[~, nChanInCont] = dh.getcontsize(filename, blkid);

channelBegin = 1;
for iCont = 1:length(blkid)
    channelEnd = channelBegin + nChanInCont(iCont)-1;
    data.trial{1}(channelBegin:channelEnd,:) = dh.readcont(filename, blkid(iCont));
    channelBegin = channelEnd+1;
end

% time
data.time = {(0:data.hdr.nSamples-1)*data.hdr.Fs + data.hdr.FirstTimeStamp};

% sampleinfo: the begin and endsample of each trial relative to the recording on disk
data.sampleinfo = [1, data.hdr.nSamples];

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


% Check data if Fieldtrip is available on the path
if exist('ft_defaults', 'file') == 2
    ft_defaults;
    data = ft_checkdata(data, 'datatype', 'raw', 'feedback', 'yes', 'ismeg', 'no', 'iseeg', 'no');
end

end