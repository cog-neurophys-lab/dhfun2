function [data, events] = ft_read_cont(filename, blkid, options)
% FT_READ_CONT - Read continuous data and events from disk into Fieldtrip format
%
% USAGE
%   [data, {events}] = ft_read_cont(filename, blkid, {options})
%
% INPUTS
%   filename    - string, name of the data file. If empty, a file dialog is opened.
%   blkid       - double, CONT block ID(s) to read. If empty, all CONT blocks are read.
%   options     - struct, optional
%       .feedback   - string, 'yes' or 'no', default='yes'
%
% OUTPUTS
%   data        - struct, Fieldtrip data structure ft_datatype_raw
%   events      - struct, Fieldtrip event structure
%
% See also FT_DATATYPE_RAW, FT_READ_EVENT, FT_READ_HEADER, FT_READ_DATA

arguments
    filename char = ''
    blkid double {mustBeInteger,mustBePositive} = []
    options.feedback string = "yes";
end

if isempty(filename)
    [filename, pathname, ~] = uigetfile('*.dh5', 'Pick a DAQ-HDF5 (*.dh5) data file');
    if filename == 0
        data = [];
        events = [];
        return;
    end

    filename = fullfile(pathname, filename);
end


if options.feedback == "yes"
    fprintf('Reading continuous data from %s \n', filename);
end

% take all cont blocks if blkid is not specified
if isempty(blkid)
    blkid = dh.enumcont(filename);
end

% hdr (header information of the original dataset on disk)
if options.feedback == "yes"
    fprintf('Reading header information\n')
end
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

if options.feedback == "yes"
    fprintf('Reading %d CONT blocks:\t\t', length(blkid));
end
channelBegin = 1;
print_progress('');
for iCont = 1:length(blkid)
    if options.feedback == "yes"
        print_progress(sprintf('%d', iCont));
    end

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

    % convert to seconds
    time = double(time)*1e-9;

    % convert to double precision
    offset = double(offset);

    if isTrialBasedRecording
        if iCont == 1
            data.trial = cell(1,nTrialsInCont(1));
            data.time = cell(1,nTrialsInCont(1));
            data.sampleinfo = zeros(nTrialsInCont(1), 2);
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

            data.time{iTrial} = (0:nSamples-1) / data.hdr.Fs + time(iTrial);
            data.sampleinfo(iTrial, :) = round(time(iTrial) * data.hdr.Fs) + [1 nSamples];
        end
        data.trialinfo = double([data.hdr.trialmap.TrialNo, data.hdr.trialmap.StimNo, data.hdr.trialmap.Outcome]);
    else
        % continuous recording / single trial
        if iCont == 1
            data.trial = {zeros(data.hdr.nChans, data.hdr.nSamples)};
            data.time = {(0:data.hdr.nSamples-1)*data.hdr.Fs + time(1)};         
            data.sampleinfo = [1, data.hdr.nSamples];
        end
        data.trial{1}(channelBegin:channelEnd,:) = contData;        
    end

    % move to next channel range
    channelBegin = channelEnd+1;
end
print_progress('');


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

if nargout == 2
    if options.feedback == "yes"
        fprintf('Reading events\n');
    end
    events = dh.ft_read_event(filename, data.hdr);
else
    events = [];
end

if options.feedback == "yes"
    fprintf('Finished. Dataset uses %g MB of RAM\n', whos('data').bytes/1024/1024);
end


end
