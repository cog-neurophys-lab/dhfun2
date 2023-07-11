%  PERIOD = dhfun(DH.GETSPIKESAMPLEPERIOD, FID, BLKID);
%
%  Get sample period for a given spike nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike Ntrode
%
%  PERIOD - variable to store sample period
%           given in integer (nanoseconds)
function period = getspikesampleperiod(fid, blkid)

filename = get_filename(fid);
period = h5readatt(filename, "/SPIKE" + blkid, 'SamplePeriod');
