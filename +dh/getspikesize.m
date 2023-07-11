%  NCHAN = dhfun(DH.GETSPIKESIZE, FID, BLKID);
%
%  Get number of channels in a given SPIKEx nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike Ntrode
%
%  NCHAN - variable to store number of channels
function nchan = getspikesize(fid, blkid)

filename = get_filename(fid);


nchan = h5info(filename, "/SPIKE" + blkid + "/DATA").Dataspace.Size(1);
