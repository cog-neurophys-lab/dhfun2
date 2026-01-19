%  dhfun(DH.WRITESPIKE,FID,BLKID,SAMBEG,SAMEND,CHNBEG,CHNEND,DATA)
%
%  Write contents of a SPIKEx data block
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike nTrode
%  SAMBEG,SAMEND - range of sample numbers to write. Samples from
%                  SAMBEG to SAMEND will be written inclusively.
%  CHNBEG,CHNEND - range of channel numbers to write. Channels from
%                  CHNBEG to CHNEND will be written inclusively.
%
%  DATA - the data to be written. An int16 matrix sized
%         [SAMEND-SAMBEG+1,CHNEND-CHNBEG+1] is required
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed
%
%  Sample indices correspond to the flattened spike waveforms.
%  To write spike N (0-indexed), calculate SAMBEG and SAMEND using
%  the spikesamples parameter from DH.GETSPIKEPARAMS.
%
function writespike(fid, blkid, sambeg, samend, chnbeg, chnend, data)

arguments
    fid
    blkid double {mustBeNonnegative, mustBeInteger}
    sambeg double {mustBePositive, mustBeInteger}
    samend double {mustBePositive, mustBeInteger}
    chnbeg double {mustBePositive, mustBeInteger}
    chnend double {mustBePositive, mustBeInteger}
    data int16
end

filename = get_filename(fid);

% Validate data dimensions
expected_rows = samend - sambeg + 1;
expected_cols = chnend - chnbeg + 1;
[actual_rows, actual_cols] = size(data);

if actual_rows ~= expected_rows || actual_cols ~= expected_cols
    error('dhfun2:dh:writespike:InvalidDataSize', ...
        'Data size [%d,%d] does not match expected size [%d,%d]', ...
        actual_rows, actual_cols, expected_rows, expected_cols);
end

% Write data to HDF5
% Data comes in as [samples x channels] in MATLAB
% HDF5 stores as [channels x samples]
% Transpose data and write with [channel_start, sample_start] ordering
h5write(filename, "/SPIKE" + blkid + "/DATA", data', ...
    [chnbeg, sambeg], ...
    [expected_cols, expected_rows]);
