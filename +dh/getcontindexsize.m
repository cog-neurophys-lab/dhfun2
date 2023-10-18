%  ITEMS = dhfun(DH.GETCONTINDEXSIZE, FID, BLKID);
%
%  Get number of items in the index of the CONTx block
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%
%  ITEMS - variable to store number of items in the index
function items = getcontindexsize(fid, blkid)

arguments
    fid
    blkid double {mustBeInteger}
end

filename = get_filename(fid);

contInfo = dh.getcontinfo(filename, blkid);
items = zeros(1, length(blkid));

for iCont = 1:length(blkid)
    items(iCont) = contInfo(iCont).Datasets(2).Dataspace.Size;
end

end

