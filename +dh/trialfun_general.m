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
% See also FT_DEFINETRIAL, FT_REDEFINETRIAL, FT_TRIALFUN_GENERAL
arguments
  cfg.dataset string
  cfg.trialdef struct
  cfg.trialfun string = "dh.trialfun_general"
  cfg.hdr struct = [];
  cfg.event struct = [];
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

value  = [cfg.event(strcmp('trigger', {cfg.event.type})).value]';
sample = [cfg.event(strcmp('trigger', {cfg.event.type})).sample]';

iAlignEvent = find(value == cfg.trialdef.alignTrigger);
nTrials = length(iAlignEvent);

if nTrials ~= cfg.hdr.trialmap.nTrials
  warning('dhfun2:trialfun_general:NonMatchingNumberOfTriggersAndTrials', ...
    'Number of found %d triggers in data (%d) does not match number of trials in header trialmap (%d)', ...
    cfg.trialdef.alignTrigger, nTrials, cfg.hdr.trialmap.nTrials);
    matchingTrials = false;
    trl = zeros(nTrials, 3);
else
  matchingTrials = true;
  trl = zeros(nTrials, 6);
end

for iTrial = 1:nTrials

  iCurrentAlign = iAlignEvent(iTrial);
  iPreviousStart = iAlignEvent(iTrial) - find(value(iCurrentAlign:-1:1) == cfg.trialdef.startTrigger, 1, 'first') + 1;
  iNextEnd = find(value(iCurrentAlign:end) == cfg.trialdef.endTrigger, 1, 'first') + iCurrentAlign - 1;

  trl(iTrial, 1) = sample(iPreviousStart) + preStart;
  trl(iTrial, 2) = sample(iNextEnd) + postEnd;
  trl(iTrial, 3) = -(sample(iCurrentAlign) - trl(iTrial, 1));
  
end

if matchingTrials
  trl(:, 4) = double(cfg.hdr.trialmap.TrialNo);
  trl(:, 5) = double(cfg.hdr.trialmap.StimulusNo);
  trl(:, 6) = double(cfg.hdr.trialmap.Outcome);
end

event = cfg.event;
