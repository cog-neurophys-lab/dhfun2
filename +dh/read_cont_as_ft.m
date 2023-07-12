function data = read_cont_as_ft(filename, blkid)

arguments
    filename char
    blkid double {mustBeInteger,mustBePositive}
end

% FT_DATATYPE_RAW describes the FieldTrip MATLAB structure for raw data
%
% The raw datatype represents sensor-level time-domain data typically
% obtained after calling FT_DEFINETRIAL and FT_PREPROCESSING. It contains
% one or multiple segments of data, each represented as Nchan X Ntime
% arrays.
%
% An example of a raw data structure with 151 MEG channels is
%
%          label: {151x1 cell}      the channel labels represented as a cell-array of strings
%           time: {1x266 cell}      the time axis [1*Ntime double] per trial
%          trial: {1x266 cell}      the numeric data as a cell array, with a matrix of [151*Ntime double] per trial
%     sampleinfo: [266x2 double]    the begin and endsample of each trial relative to the recording on disk
%      trialinfo: [266x1 double]    optional trigger or condition codes for each trial
%            hdr: [1x1 struct]      the full header information of the original dataset on disk
%           grad: [1x1 struct]      information about the sensor array (for EEG it is called elec)
%            cfg: [1x1 struct]      the configuration used by the function that generated this data structure
%
% Required fields:
%   - time, trial, label
%
% Optional fields:
%   - sampleinfo, trialinfo, grad, elec, opto, hdr, cfg
%
% Deprecated fields:
%   - fsample
%
% Obsoleted fields:
%   - offset

data = [];
data.label = {};
data.time = {};
data.trial = {};
data.sampleinfo = [];
data.trialinfo = [];
data.cfg = [];
data.hdr = [];

for id = blkid'
    contData = dh.readcont(filename, id);
    contMap = dh.get_cont_map(filename, id);
    % TODO: fill in the rest of the fields
end

% Check data if Fieldtrip is available on the path
if exist('ft_defaults', 'file') == 2
    ft_defaults;
    data = ft_checkdata(data, 'datatype', 'raw', 'feedback', 'yes', 'ismeg', 'no', 'iseeg', 'no');
end

end
