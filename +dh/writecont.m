%  dhfun(DH.WRITECONT, FID, BLKID, SAMBEG, SAMEND, CHNBEG, CHNEND, DATA);
%
%  Write contents of a CONTx data block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a continuous nTrode
%  SAMBEG,SAMEND - range of sample numbers to write. Samples from
%                  SAMBEG to SAMEND will be written inclusively.
%  CHNBEG,CHNEND - range of channel numbers to write. Channels from
%                  CHNBEG to CHNEND will be written inclusively.
%  DATA - the data to be written. An int16 matrix sized
%         [CHNEND-CHNBEG+1,SAMEND-SAMBEG+1] is required
%         NOTE: Despite original documentation stating [samples,channels],
%         this implementation matches readcont's behavior of [channels,samples]
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed
%
function writecont(fid, blkid, sambeg, samend, chnbeg, chnend, data)

arguments
    fid
    blkid double {mustBePositive, mustBeInteger}
    sambeg double {mustBePositive, mustBeInteger}
    samend double {mustBePositive, mustBeInteger}
    chnbeg double {mustBePositive, mustBeInteger}
    chnend double {mustBePositive, mustBeInteger}
    data int16
end

filename = get_filename(fid);

% Validate data dimensions
% Data should be [channels, samples] to match readcont
expected_channels = chnend - chnbeg + 1;
expected_samples = samend - sambeg + 1;

if size(data, 1) ~= expected_channels || size(data, 2) ~= expected_samples
    error('dhfun2:dh:writecont:InvalidDataSize', ...
        'Data must be sized [%d, %d] (channels x samples) but got [%d, %d]', ...
        expected_channels, expected_samples, size(data, 1), size(data, 2));
end

datasetPath = "/CONT" + blkid + "/DATA";

% Write data using h5write
% readcont uses h5read with start=[chnbeg,sambeg] and returns [channels,samples]
% So we use the same indexing for consistency
h5write(filename, datasetPath, data, [chnbeg, sambeg], [expected_channels, expected_samples]);

end