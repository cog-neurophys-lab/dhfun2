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

% channel labels
data.label = data.hdr.label;

nTrialsInCont = dh.getcontindexsize(filename, blkid);
if any(nTrialsInCont > 1)
    % trial-based recording with gaps
    if ~all(nTrialsInCont == nTrialsInCont(1))
        error('dhfun2:ft_read_cont:NonMatchingNumberOfTrialsInCont', 'The number of trials stored in the selected CONT blocks don''t match');
    end

    channelBegin = 1;
    for iCont = 1:length(blkid)

        contData = dh.readcont(filename, blkid(iCont));
        [time, offset] = dh.readcontindex(filename, blkid(iCont));
        [nSamplesInCont, nChanInCont] = dh.getcontsize(filename, blkid(iCont));

        channelEnd = channelBegin + nChanInCont-1;

        for iTrial = 1:length(offset)-1
            nSamples = offset(iTrial+1) - offset(iTrial);
            data.trial{iTrial}(channelBegin:channelEnd,:) = contData(:,(offset(iTrial)+1):offset(iTrial+1));
            data.time{iTrial} = (0:nSamples-1) / data.hdr.Fs + time(iTrial)*1e-9;
            data.sampleinfo(iTrial, :) = double(round(time(iTrial) * 1e-9 * data.hdr.Fs) + [1 nSamples]);
        end

        % last trial
        iTrial = iTrial+1;
        nSamples = nSamplesInCont - offset(end);
        data.trial{iTrial}(channelBegin:channelEnd,:) = contData(:,offset(iTrial)+1:end);
        data.time{iTrial} = (0:nSamples-1) / data.hdr.Fs + time(iTrial)*1e-9;
        channelBegin = channelEnd+1;
        data.sampleinfo(iTrial,:) = double(round(time(iTrial) * 1e-9 * data.hdr.Fs) + [1 nSamples]);
    end
    data.trialinfo = double([data.hdr.trialmap.TrialNo, data.hdr.trialmap.StimNo, data.hdr.trialmap.Outcome]);


% single trial / continuous recording    
else
    % trials (load actual data)
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
    
end


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