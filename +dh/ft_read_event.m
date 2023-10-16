function events = ft_read_event(filename, header)
% DH.FT_READ_EVENT reads an events from a DAQ-HDF5 (DH5) file in FieldTrip format
%
% To be used with ft_read_data as follows:
%   event = ft_read_event(filename, 'eventformat', 'dh.ft_read_event');
%
% This function returns an event structure with the following fields
%   event.type      = string
%   event.sample    = expressed in samples, the first sample of a recording is 1
%   event.value     = number or string
%   event.offset    = expressed in samples
%   event.duration  = expressed in samples
%   event.timestamp = expressed in timestamp units, which vary over systems (optional)


events = [];

[time, evt] = dh.readev2(filename);
trialmap = h5read(filename, '/TRIALMAP');

%  TRIALNO - TrialNo member of TRIALMAP_ITEM struct
%            usually corresponds to the TrialNo member of
%            TD01 item associated with a particular trial
%  STIMNO - StimNo member of TRIALMAP_ITEM struct
%            usually corresponds to the StimNo member of
%            TD01 item associated with a particular trial
%  OUTCOME - Outcome member of TRIALMAP_ITEM struct
%            contains trial outcome code
%  STARTTIME - StartTime member of TRIALMAP_ITEM struct
%            contains start time of trial in nanoseconds
%  ENDTIME  - EndTime member of TRIALMAP_ITEM struct
%            contains end time of trial in nanoseconds

if isempty(events)
    % ensure that it has the correct fields, even if it is empty
    events = struct('type', {}, 'value', {}, 'sample', {}, 'offset', {}, 'duration', {});
end