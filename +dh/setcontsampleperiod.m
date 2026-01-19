
%  dhfun(DH.SETCONTSAMPLEPERIOD, FID, BLKID, SAMPLEPERIOD)
%
%  Set sample period for a given continuous nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  SAMPLEPERIOD - variable to store the sample period
%           (integer, given in nanoseconds)
%
%  Remarks:
%
%  This function will fail if the file was not opened for
%  write access.
%
%  -------------------------------------------------
function setcontsampleperiod(fid, blkid, sampleperiod)

arguments
    fid
    blkid double {mustBePositive, mustBeInteger}
    sampleperiod double {mustBePositive, mustBeInteger}
end

filename = get_filename(fid);
groupPath = "/CONT" + blkid;

% Write the SamplePeriod attribute
h5writeatt(filename, groupPath, 'SamplePeriod', int32(sampleperiod));

end