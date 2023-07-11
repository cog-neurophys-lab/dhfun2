%  [RESULT] = dhfun(DH.ISCLUSTERINFO_PRESENT,FID,BLKID)
%
%  Check if there is cluster information for a given
%  Spike nTrode.
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of spike Ntrode
%
%  RESULT    - output variable to receive the result.
%              zero means that there is no cluster info,
%              nonzero means the opposite.
%
%  Remarks:
%
%  Use this function to check whether there is cluster
%  information for a spike nTrode before trying to read it.
%  Read functions fail if there is no cluster info.
%
function result = isclusterinfo_present(fid, blkid)

filename = get_filename(fid);

result = ismember('CLUSTER_INFO', {h5info(filename, "/SPIKE" + blkid).Datasets.Name});