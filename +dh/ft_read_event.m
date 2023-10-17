function events = ft_read_event(filename, header)
% DH.FT_READ_EVENT reads events from a DAQ-HDF5 (DH5) file in FieldTrip format
%
% To be used with ft_read_data as follows:
%   event = ft_read_event(filename, 'eventformat', 'daq_hdf5');
%
% This function returns an event structure with the following fields
%   event.type      = string
%   event.sample    = expressed in samples, the first sample of a recording is 1
%   event.value     = number or string
%   event.offset    = expressed in samples
%   event.duration  = expressed in samples
%   event.timestamp = expressed in timestamp units, which vary over systems (optional)

% read event information from the file
[time, evt] = dh.readev2(filename);
trialmap = h5read(filename, '/TRIALMAP');
nEvents = length(evt) + length(trialmap.TrialNo);

% pre-allocate array of structs with nEvents elements
events = struct('type', cell(nEvents,1), ...
    'value', 0, ...
    'sample', 0, ...
    'offset', 0, ...
    'duration', 0, ...
    'timestamp', 0);

% % convert trigger to events 
for iEvent = 1:length(evt)
    events(iEvent).type = 'trigger';
    events(iEvent).value = double(evt(iEvent));
    events(iEvent).sample = round(double(time(iEvent) - header.FirstTimeStamp) * header.Fs * 1e-9) + 1;
    events(iEvent).offset = 0;
    events(iEvent).duration = 1;
    events(iEvent).timestamp = double(time(iEvent));
end

% convert trialmap to events with duration
for iTrial = 1:length(trialmap.TrialNo)
    events(iEvent+iTrial).type = 'trial';
    events(iEvent+iTrial).value = double(trialmap.TrialNo(iTrial));
    events(iEvent+iTrial).sample = round(double(trialmap.StartTime(iTrial)) * header.Fs * 1e-9);
    events(iEvent+iTrial).offset = 0;
    events(iEvent+iTrial).duration = round(double(trialmap.EndTime(iTrial) - trialmap.StartTime(iTrial)) * header.Fs * 1e-9);
end
