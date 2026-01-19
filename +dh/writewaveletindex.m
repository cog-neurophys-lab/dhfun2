%  dhfun(DH.WRITEWAVELETINDEX, FID, BLKID, RBEG, REND, TIME, OFFSET, SCALING);
%
%  Write contents of a WAVELETx index block to a V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet nTrode
%  RBEG,REND - range of record numbers to write. Records from
%              RBEG to REND will be written inclusively.
%  TIME - timestamps in nanoseconds (int64 array)
%  OFFSET - sample offsets, 1-based (int64 array)
%  SCALING - scaling factors for amplitude conversion (double array)
%
%  Remarks:
%
%  File must be opened with write access enabled for this
%  operation to succeed.
%
%  TIME, OFFSET, and SCALING arrays must all have the same length
%  equal to REND-RBEG+1.

function writewaveletindex(fid, blkid, rbeg, rend, time, offset, scaling)

arguments
    fid
    blkid double {mustBeNonnegative, mustBeInteger}
    rbeg double {mustBePositive, mustBeInteger}
    rend double {mustBePositive, mustBeInteger}
    time int64
    offset int64
    scaling double
end

filename = get_filename(fid);

% Validate input sizes
expected_length = rend - rbeg + 1;
if length(time) ~= expected_length
    error('dhfun2:dh:writewaveletindex:InvalidTimeLength', ...
        'TIME must have length %d but got %d', expected_length, length(time));
end
if length(offset) ~= expected_length
    error('dhfun2:dh:writewaveletindex:InvalidOffsetLength', ...
        'OFFSET must have length %d but got %d', expected_length, length(offset));
end
if length(scaling) ~= expected_length
    error('dhfun2:dh:writewaveletindex:InvalidScalingLength', ...
        'SCALING must have length %d but got %d', expected_length, length(scaling));
end

datasetPath = "/WAVELET" + blkid + "/INDEX";

% Create structure with proper fields
indexData = struct('time', time, 'offset', offset, 'scaling', scaling);

% Write using h5write with partial indexing
h5write(filename, datasetPath, indexData, rbeg, expected_length);

end
