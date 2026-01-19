%  dhfun(DH.SETWAVELETFAXIS, FID, BLKID, FAXIS);
%
%  Set frequency axis for a given wavelet nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet nTrode
%  FAXIS - frequency axis values in Hz (double array)
%
%  Remarks:
%
%  File must be opened with write access enabled for this
%  operation to succeed.
%  The length of FAXIS must match the number of frequency bins
%  in the WAVELET block's DATA dataset.

function setwaveletfaxis(fid, blkid, faxis)

arguments
    fid
    blkid double {mustBeInteger, mustBeScalarOrEmpty}
    faxis double
end

filename = get_filename(fid);

groupPath = "/WAVELET" + blkid;
h5writeatt(filename, groupPath, 'FrequencyAxis', faxis);

end
