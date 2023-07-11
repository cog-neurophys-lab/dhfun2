%  SAMPER = dhfun(DH.GETWAVELETSAMPLEPERIOD, FID, BLKID);
%
%  Get sample period for a given wavelet nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%
%  Output:
%
%  SAMPER - variable to store the sample period
%           (given in nanoseconds)

function samper = getwaveletsampleperiod(fid, blkid)

filename = get_filename(fid);
samper = double(h5readatt(filename, "/WAVELET" + blkid, 'SamplePeriod'));