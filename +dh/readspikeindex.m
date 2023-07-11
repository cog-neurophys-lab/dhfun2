%  TIME = dhfun(DH.READSPIKEINDEX, FID, BLKID, RBEG, REND);
%
%  Read contents of a SPIKEx index block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike nTrode
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%  TIME - variable to store read data. A vector sized
%         [REND-RBEG+1] will be returned. Each item
%         corresponds to a single spike and specifies
%         its trigger time given in nanoseconds.
%
%  Remarks:
%
%  Use this function to determine spike occurence times
function time = readspikeindex(fid, blkid, rbeg, rend)

filename = get_filename(fid);

switch nargin
    case 2
        time = double(h5read(filename, "/SPIKE" + blkid + "/INDEX"));
    case 4
        time = double(h5read(filename, "/SPIKE" + blkid + "/INDEX", rbeg, rend-rbeg+1));
    otherwise
        error('dhfun2:readspikeindex:invalidNargin',  ...
        'Invalid number of arguments (%g). Should be 2 or 4.', nargin)
end
