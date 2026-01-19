%  dhfun(DH.SETWAVELETSAMPLEPERIOD, FID, BLKID, SAMPLEPERIOD);
%
%  Set sample period for a given wavelet nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet nTrode
%  SAMPLEPERIOD - sample period in nanoseconds (int32 scalar)
%
%  Remarks:
%
%  File must be opened with write access enabled for this
%  operation to succeed

function setwaveletsampleperiod(fid, blkid, sampleperiod)

arguments
    fid
    blkid double {mustBeInteger, mustBeScalarOrEmpty}
    sampleperiod int32 {mustBePositive, mustBeScalarOrEmpty}
end

filename = get_filename(fid);

groupPath = "/WAVELET" + blkid;
h5writeatt(filename, groupPath, 'SamplePeriod', sampleperiod);

end
