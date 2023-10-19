function [trl, event] = trialfun_from_trialmap(cfg)
% DH.TRIALFUN_FROM_TRIALMAP Construct trial definition from trialmap in header
%
% USAGE
% -----
%
%   [trl, event] = dh.trialfun_from_trialmap(cfg)
%
%   trialCfg = []; trialCfg.trl = trl;
%   data = ft_redefinetrial(trialCfg, data);
%
% INPUTS
% ------
%
%   cfg : struct, configuration with the following fields
%      .dataset : string, path to the dataset
%      .hdr : struct, header information from dh.ft_read_header
%      .event :: struct, event information from dh.ft_read_event
%
% OUTPUTS
% -------
%
%   trl : nTrial x 8 trial definition matrix with the columns
%       1. start sample
%       2. end sample
%       3. offset
%       4. trial number
%       5. stimulus number
%       6. outcome
%       7. start time in nanoseconds
%       8. end time in nanoseconds
%   event : struct, event information
%
% See also DH.FT_READ_HEADER, DH.FT_READ_EVENT, FT_REDEFINETRIAL



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

trials  = [cfg.event(strcmp('trial', {cfg.event.type}))];
nTrials = length(trials);


trl = zeros(nTrials, 6);
for iTrial = 1:length(trials)
    trl(iTrial, 1) = trials(iTrial).sample;
    trl(iTrial, 2) = trials(iTrial).sample + trials(iTrial).duration;
    trl(iTrial, 3) = 0;

end
trl(:, 4) = double(cfg.hdr.trialmap.TrialNo);
trl(:, 5) = double(cfg.hdr.trialmap.StimNo);
trl(:, 6) = double(cfg.hdr.trialmap.Outcome);
trl(:, 7) = double(cfg.hdr.trialmap.StartTime);
trl(:, 8) = double(cfg.hdr.trialmap.EndTime);

event = cfg.event;