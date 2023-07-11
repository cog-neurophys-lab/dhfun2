%  BLKIDS = dhfun(DH.ENUMWAVELET,FID);
%
%  Enumerate WAVELETx block identifers
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKIDS - variable to store WAVELETx block identifiers.
%           A vector will be returned. All identifiers
%           are sorted in ascending order.
%           Empty matrix is returned if there are no
%           CONT blocks in the file
%
%  Remarks:
%
%  Identifiers returned by this function are safe for
%  using in any WAVELET-block related functions.

function blkids = enumwavelet(fid)

filename = get_filename(fid);

info = h5info(filename);
spikeGroups = info.Groups( ...
    cellfun(@(x) string(x).startsWith("/WAVELET") , {info.Groups.Name}) ...
    );

blkids = cellfun(@(x) str2double(x(9:end)), {spikeGroups.Name});

end