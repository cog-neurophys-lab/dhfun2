%  [CLUS] = dhfun(DH.READSPIKECLUSTER,FID,BLKID,RBEG,REND)
%
%  Read the spike cluster information
%  (every spike has a cluster number)
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of spike Ntrode
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%  CLUS      - Cluster number for each spike in the
%              requested range
%
function clus = readspikecluster(fid, blkid, rbeg, rend)

filename = get_filename(fid);

switch nargin
    case 2
        clus = double(h5read(filename, "/SPIKE" + blkid + "/CLUSTER_INFO"));
    case 4
        clus = double(h5read(filename, "/SPIKE" + blkid + "/CLUSTER_INFO", rbeg, rend-rbeg+1));
    otherwise
        error('dhfun2:readspikecluster:invalidNargin', ...
        'Invalid number of input arguments (%g). Should be 2 or 4', nargin)
end

