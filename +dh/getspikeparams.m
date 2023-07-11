%  [TOTAL, PRETRIG, LOCKOUT] = dhfun(DH.GETSPIKEPARAMS, FID, BLKID);
%
%  Get spike-specific parameters of a spike nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike Ntrode
%
%  TOTAL - variable to store number of samples
%          recorded for every spike
%
%  PRETRIG - variable to store number of preTrig samples
%
%  LOCKOUT - variable to store number of lockOut samples
%
function [total, pretrig, lockout] = getspikeparams(fid, blkid)

filename = get_filename(fid);

spikeParams = h5readatt(filename, "/SPIKE" + blkid, 'SpikeParams');

total = spikeParams.spikeSamples;
pretrig = spikeParams.preTrigSamples;
lockout = spikeParams.lockOutSamples;