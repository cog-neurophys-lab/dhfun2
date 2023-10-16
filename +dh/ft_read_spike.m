function [spike] = ft_read_spike(filename, varargin)
% DH.FT_READ_SPIKE reads spike timestamps and waveforms in FieldTrip format
%
% Use as
%  [spike] = dh.ft_read_spike(filename, ...)
%
% The output spike structure contains
%
%   spike.label     = 1xNchans cell-array, with channel labels
%   spike.waveform  = 1xNchans cell-array, each element contains a matrix (Nleads x Nsamples X Nspikes)
%   spike.waveformdimord = '{chan}_lead_time_spike'
%   spike.timestamp = 1xNchans cell-array, each element contains a vector (1 X Nspikes)
%   spike.unit      = 1xNchans cell-array, each element contains a vector (1 X Nspikes)
%
% and is described in more detail in FT_DATATYPE_SPIKE
%
% See also FT_DATATYPE_SPIKE, FT_READ_HEADER, FT_READ_DATA, FT_READ_EVENT

spike = struct('label', {}, 'waveform', {}, 'waveformdimord', {}, 'timestamp', {}, 'unit', {});




