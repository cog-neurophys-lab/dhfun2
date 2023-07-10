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

contGroups = dh.enumcont(filename);
if ~ismember(blkid, contGroups)
    error('No such CONT block')
end


items = dh.getcontinfo(filename, blkid).Datasets(2).Dataspace.Size;

end

