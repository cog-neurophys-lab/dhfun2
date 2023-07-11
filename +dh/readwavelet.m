%  [A,PHI] = dhfun(DH.READWAVELET,FID,BLKID,CHNBEG,CHNEND,SAMBEG,SAMEND,FRQBEG,FRQEND);
%
%  Read contents of a WAVELETx data block
%
%  Arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet block
%  CHNBEG,CHNEND - range of channel numbers to read. Channels from
%                  CHNBEG to CHNEND will be read inclusively.
%  SAMBEG,SAMEND - range of sample numbers to read. Samples from
%                  SAMBEG to SAMEND will be read inclusively.
%  FRQBEG,FRQEND - range of frequency bins to read. Frequency
%                  bins from FRQBEG to FRQEND will be read inclusively.
%
%  Outputs:
%
%  A - (uint16) variable to store the magnitude values. A 3-dimensional array
%      sized [FRQEND-FRQBEG+1,SAMEND-SAMBEG+1,CHNEND-CHNBEG+1] will be returned.
%      If only one channel was requested, the return value will be a
%      2D matrix. Magnitude values are unsigned, scaled,
%      and take integer values from 0 to 65535. To translate them into
%      native floating-point representation, information from wavelet
%      index must be used (see DH.READWAVELETINDEX).
%  PHI - (int8) variable to store the phase values. It will have the same
%      sizes as A. Phase values are scaled and take integer values from
%      -127 to 127. To translate them into radians, use the following
%      formula: phi_rad = phi*pi/127.0;
function [a, phi] = readwavelet(fid,blkid,chnbeg,chnend,sambeg,samend,frqbeg,frqend)

filename = get_filename(fid);

if nargin == 2
    [a, phi] = struct2commaseparatedlist( ...
        h5read(filename, "/WAVELET" + blkid + "/DATA") ...
    );
elseif nargin == 8
    [a, phi] = struct2commaseparatedlist( ...
        h5read(filename, "/WAVELET" + blkid + "/DATA", ...
            [frqbeg, sambeg, chnbeg], ...
            [frqend-frqbeg+1, samend-sambeg+1, chnend-chnend+1]) ...
    );
else
    error('Invalid number of input arguments. Should be 2 or 8')
end
