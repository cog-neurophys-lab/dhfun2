function [trl, event] = trialfun_general(cfg)
% trialfun_general is an example trial function for DAQ-HDF5 (DH5) data. It searches for
% trigger events in the data and returns a trial definition matrix (trl), which can be used
% to define trials on data using the ft_defintrial or ft_redefintrial functions.
% 
% The trl matrix has 3 columns, the first column contains the begin sample for each trial,
% the second column contains the end sample for each trial, the third column contains the
% offset of the trigger with respect to the begin sample of the trial (in samples). The trl
% matrix can also have 3 additional columns, which can be used to store additional
% information about each trial, such as the original trial number, stimulus number, response,
% etc. These additional columns are ignored by the FieldTrip functions, but can be used by
% the user for further analysis. 
%
% You can use this as a template for your own conditial trial definitions.
%
% Use this function by calling 
%   
%   [cfg] = ft_definetrial(cfg) 
% 
% where the configuration structure should contain 
%
%   cfg.dataset                   = string with the filename 
%   cfg.trialfun                  = 'dh.trialfun_general' 
%   cfg.trialdef.startTrigger     = trigger number for start of trial
%   cfg.trialdef.endTrigger       = trigger number for end of trial
%   cfg.trialdef.alignTrigger     = trigger number for aligning trial to, i.e. t=0
%   cfg.trialdef.tPreStartTrigger = time before start trigger, in seconds
%   cfg.trialdef.tPostEndTrigger  = time after end trigger, in seconds 
% 
%     tPreStartTrigger                                             tPostEndTrigger
%     ----------------- | -----------------|--------------------|-----------------
%                  startTrigger       alignTrigger           endTrigger
%
% The startTrigger, alignTrigger and endTrigger can be the same trigger, if tPreStartTrigger
% and tPostEndTrigger are not set to 0.
%
% OUTPUT
% ------
%   trl : nTrial x 8 trial definition matrix with the columns
%       1. start sample
%       2. end sample
%       3. offset
%       4. trial number
%       5. stimulus number
%       6. outcome (0=NotStarted, 1=Hit, 2=WrongResponse, 3=EarlyHit, 4=EarlyWrongReponse, 
%                   5=Early, 6=Late, 7=EyeErr, 8=InexpectedStartSignal, 9=WrongStartSignal)
%       7. start time in nanoseconds
%       8. end time in nanoseconds
%
% See also FT_DEFINETRIAL, FT_REDEFINETRIAL, FT_TRIALFUN_GENERAL
arguments
    cfg struct = []
end

% specify the default file formats
cfg.eventformat   = 'daq_hdf5';
cfg.headerformat  = 'daq_hdf5';
cfg.dataformat    = 'daq_hdf5';

% read the header information and the events from the data
if ~isfield(cfg, 'hdr')
  cfg.hdr   = ft_read_header(cfg.dataset);
end
if ~isfield(cfg, 'event')
  cfg.event = ft_read_event(cfg.dataset);
end

triggerEvents = cfg.event(strcmp('trigger', {cfg.event.type}));
value  = [triggerEvents.value]';
sample = [triggerEvents.sample]';

iAlignEvent = find(value == cfg.trialdef.alignTrigger);
nTrials = length(iAlignEvent);

% nTrialsInTrialMap = length(cfg.hdr.trialmap.TrialNo);
% if nTrials ~= nTrialsInTrialMap
%   warning('dhfun2:trialfun_general:NonMatchingNumberOfTriggersAndTrials', ...
%     'Number of found %d triggers in data (%d) does not match number of trials in header trialmap (%d)', ...
%     cfg.trialdef.alignTrigger, nTrials, nTrialsInTrialMap);
%     matchingTrials = false;
%     trl = zeros(nTrials, 3);
% else
%   matchingTrials = true;
%   trl = zeros(nTrials, 6);
% end

preStart = round(cfg.trialdef.tPreStartTrigger * cfg.hdr.Fs);
postEnd = round(cfg.trialdef.tPostEndTrigger * cfg.hdr.Fs);

trl = zeros(nTrials, 6);

for iTrial = 1:nTrials

  iCurrentAlign = iAlignEvent(iTrial);
  iPreviousStart = iAlignEvent(iTrial) - find(value(iCurrentAlign:-1:1) == cfg.trialdef.startTrigger, 1, 'first') + 1;
  iNextEnd = find(value(iCurrentAlign:end) == cfg.trialdef.endTrigger, 1, 'first') + iCurrentAlign - 1;
  if isempty(iNextEnd)
    warning('dhfun2:trialfun_general:NoEndTriggerFound', ...
      'No end trigger (%d) found for event %d. Skipping event.', cfg.trialdef.endTrigger, iTrial);
      continue
  end
  trl(iTrial, 1) = sample(iPreviousStart) + preStart;
  trl(iTrial, 2) = sample(iNextEnd) + postEnd;
  trl(iTrial, 3) = -(sample(iCurrentAlign) - trl(iTrial, 1));
  
  % find matching trial in trialmap
  timestamp = triggerEvents(iAlignEvent(iTrial)).timestamp;
  jTrial = find(timestamp >= cfg.hdr.trialmap.StartTime & ...
      timestamp <= cfg.hdr.trialmap.EndTime);
  if isempty(jTrial)
    warning('dhfun2:trialfun_general:NoMatchingTrialFound', ...
      'No trial with matching timestamp found in trialmap for align trigger %d', iTrial);
      continue
  end
  trl(iTrial, 4) = double(cfg.hdr.trialmap.TrialNo(jTrial));
  trl(iTrial, 5) = double(cfg.hdr.trialmap.StimNo(jTrial));
  trl(iTrial, 6) = double(cfg.hdr.trialmap.Outcome(jTrial));


  

  
end

event = cfg.event;
