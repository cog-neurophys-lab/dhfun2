%  dhfun(DH.WRITESPIKEINDEX,FID,BLKID,RBEG,REND,TIME)
%
%  Write contents of a SPIKEx index block
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike nTrode
%  RBEG,REND - range of record numbers to write. Records from
%              RBEG to REND will be written inclusively.
%  TIME - Spike trigger times in nanoseconds. Should be a column
%         vector of int64, sized according to number of
%         records to write (REND-RBEG+1).
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed
%
%  Each TIME value specifies when a spike was triggered, in nanoseconds.
%  The spike trigger point may not be the beginning of the waveform
%  if preTrigSamples is nonzero.
%
function writespikeindex(fid, blkid, rbeg, rend, time)

arguments
    fid
    blkid double {mustBeNonnegative, mustBeInteger}
    rbeg double {mustBePositive, mustBeInteger}
    rend double {mustBePositive, mustBeInteger}
    time int64
end

filename = get_filename(fid);

% Validate time dimensions
expected_length = rend - rbeg + 1;
actual_length = length(time);

if actual_length ~= expected_length
    error('dhfun2:dh:writespikeindex:InvalidTimeLength', ...
        'Time length %d does not match expected length %d', ...
        actual_length, expected_length);
end

% Ensure time is a column vector
if size(time, 2) > 1
    time = time(:);
end

% Write data to HDF5
h5write(filename, "/SPIKE" + blkid + "/INDEX", time, rbeg, expected_length);
