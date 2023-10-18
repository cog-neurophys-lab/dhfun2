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
if ~all(nTrialsInCont == nTrialsInCont(1))
    error('dhfun2:ft_read_cont:NonMatchingNumberOfTrialsInCont', ...
        'The number of trials stored in the selected CONT blocks don''t match');
end
isTrialBasedRecording = any(nTrialsInCont > 1);

[nSamplesInCont, nChanInCont] = dh.getcontsize(filename, blkid);


channelBegin = 1;
for iCont = 1:length(blkid)

    % read data from disk
    contData = double(dh.readcont(filename, blkid(iCont)));

    % apply calibration
    calibrationInfo = dh.getcontcalinfo(filename, blkid(iCont));
    contData = contData .* repmat(calibrationInfo, [1, size(contData,2)]);
    
    % get dimensions of cont data

    % determine end of channel range in data array
    channelEnd = channelBegin + nChanInCont(iCont)-1;

    % read start time and offset of all trials in this CONT block
    [time, offset] = dh.readcontindex(filename, blkid(iCont));

    if isTrialBasedRecording
        if iCont == 1
            data.trial = cell(1,nTrialsInCont(1));
            data.time = cell(1,nTrialsInCont(1));
        end

        for iTrial = 1:length(offset)
            if iTrial < length(offset)
                nSamples = offset(iTrial+1) - offset(iTrial);
                data.trial{iTrial}(channelBegin:channelEnd,:) = contData(:,(offset(iTrial)+1):offset(iTrial+1));
            else
                % last trial
                nSamples = nSamplesInCont(iCont) - offset(end);
                data.trial{iTrial}(channelBegin:channelEnd,:) = contData(:,offset(iTrial)+1:end);
            end

            data.time{iTrial} = (0:nSamples-1) / data.hdr.Fs + time(iTrial)*1e-9;
            data.sampleinfo(iTrial, :) = double(round(time(iTrial) * 1e-9 * data.hdr.Fs) + [1 nSamples]);
        end
        data.trialinfo = double([data.hdr.trialmap.TrialNo, data.hdr.trialmap.StimNo, data.hdr.trialmap.Outcome]);
    else
        % continuous recording / single trial
        if iCont == 1
            data.trial = {zeros(data.hdr.nChans, data.hdr.nSamples)};
            data.time = {(0:data.hdr.nSamples-1)*data.hdr.Fs + data.hdr.FirstTimeStamp};
            % sampleinfo: the begin and endsample of each trial relative to the recording on disk
            data.sampleinfo = [1, data.hdr.nSamples];
        end
        data.trial{1}(channelBegin:channelEnd,:) = contData;        
    end

    % move to next channel range
    channelBegin = channelEnd+1;
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
