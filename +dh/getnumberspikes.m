%  NSPIKES = dhfun(DH.GETNUMBERSPIKES, FID, BLKID);
%
%  Get number of spikes in a given SPIKEx nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike Ntrode
%
%  NSPIKES - variable to store number of spikes
function nSpikes = getnumberspikes(fid, blkid)

filename = get_filename(fid);

nSpikes = h5info(filename, "/SPIKE" + blkid + "/INDEX").Dataspace.Size;