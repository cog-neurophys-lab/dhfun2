%  PARAMS = dhfun(DH.GETWAVELETMORLETPARAMS, FID, BLKID);
%
%  Get Morlet wavelet parameters for a given wavelet nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet nTrode
%
%  PARAMS - structure containing Morlet wavelet parameters:
%           .w0 - central frequency parameter (omega0)
%           .st_hl - spectral-temporal half-length
%           (Returns empty struct if attributes are not present)
%
%  Remarks:
%
%  These parameters are optional and may not be present in all
%  WAVELET blocks. They describe the Morlet wavelet used for
%  time-frequency decomposition.

function params = getwaveletmorletparams(fid, blkid)

arguments
    fid
    blkid double {mustBeInteger, mustBeScalarOrEmpty}
end

filename = get_filename(fid);

groupPath = "/WAVELET" + blkid;

% Try to read Morlet parameters
params = struct();
try
    params.w0 = h5readatt(filename, groupPath, 'MorletW0');
catch
    % Attribute doesn't exist
    params.w0 = [];
end

try
    params.st_hl = h5readatt(filename, groupPath, 'MorletSTHL');
catch
    % Attribute doesn't exist
    params.st_hl = [];
end

end
