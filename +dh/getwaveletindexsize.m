%  NITEMS = dhfun(DH.GETWAVELETINDEXSIZE, FID, BLKID);
%
%  Get number of items in the index of a WAVELETx block
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%
%  Output:
%
%  NITEMS - variable to store number of items in the index
function nItems = getwaveletindexsize(fid, blkid)

filename = get_filename(fid);
nItems = h5info(filename, "/WAVELET" + blkid + "/INDEX").Dataspace.Size;