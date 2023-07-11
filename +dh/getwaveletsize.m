%  [NCHAN,NSAM,NF] = dhfun(DH.GETWAVELETSIZE,FID,BLKID);
%
%  Get number of samples, number of channels and number of frequency
%  bins for a given wavelet nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet nTrode
%
%  Outputs:
%
%  NCHAN - variable to store number of channels
%  NSAMP - variable to store number of samples
%  NF - variable to store number of frequency bins
function [nChan, nSam, nF] = getwaveletsize(fid, blkid)

filename = get_filename(fid);

waveletSize = h5info(filename, "/WAVELET" + blkid + "/DATA").Dataspace.Size;
nF = waveletSize(1);
nSam = waveletSize(2);
nChan = waveletSize(3);

