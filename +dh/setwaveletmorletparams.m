%  dhfun(DH.SETWAVELETMORLETPARAMS, FID, BLKID, W0, ST_HL);
%
%  Set Morlet wavelet parameters for a given wavelet nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet nTrode
%  W0 - central frequency parameter (omega0) (double scalar)
%  ST_HL - spectral-temporal half-length (double scalar)
%
%  Remarks:
%
%  File must be opened with write access enabled for this
%  operation to succeed.
%
%  These parameters describe the Morlet wavelet used for
%  time-frequency decomposition. They are optional metadata.

function setwaveletmorletparams(fid, blkid, w0, st_hl)

arguments
    fid
    blkid double {mustBeInteger, mustBeScalarOrEmpty}
    w0 double {mustBePositive, mustBeScalarOrEmpty}
    st_hl double {mustBePositive, mustBeScalarOrEmpty}
end

filename = get_filename(fid);

groupPath = "/WAVELET" + blkid;

% Write Morlet parameters as attributes
h5writeatt(filename, groupPath, 'MorletW0', w0);
h5writeatt(filename, groupPath, 'MorletSTHL', st_hl);

end
