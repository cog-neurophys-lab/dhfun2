%  FAXIS = dhfun(DH.GETWAVELETFAXIS,FID,BLKID);
%
%  Get frequency axis of a wavelet nTrode.
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%
%  Output:
%
%  FAXIS - (double vector) frequency axis of the requested
%          wavelet nTrode
function faxis = getwaveletfaxis(fid, blkid)

filename = get_filename(fid);
faxis = h5readatt(filename, "/WAVELET" + blkid, 'FrequencyAxis');