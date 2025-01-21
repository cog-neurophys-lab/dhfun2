% [TIME, OFFSET] = dhfun(DH.READCONTINDEX, FID, BLKID, RBEG, REND);
%
%  Read contents of a CONTx index block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%
%  TIME, OFFSET - variables to store 'time' and 'offset'
%          fields of index items. TIME is given in nanoseconds
%          (double array), and OFFSET is given in samples
%          (int32 array). Offset is 1-based and references
%          to the beginning of cont dataset.
%
%  Remarks:
%
%  Index allows to calculate range of samples for a particular
%  range of time. Each index item is associated a contiguous
%  section of recording, where individual offsets can be
%  calculated given starting time and sample period. Between
%  these contiguous sections there are gaps. Ending time for
%  a section is calculated using the start offset for the next
%  section. Be sure to check that a time range does not
%  include gaps.
%
%  Gaps usually do not exist in files recorded without
%  using space-saving "trial-based" mode. In this case index contains
%  of only 1 item which gives the start time of continuous recording.
%

function [time, offset] = readcontindex(fid, blkid, rbeg, rend)


arguments
    fid
    blkid double {mustBePositive, mustBeInteger}
    rbeg double {mustBePositive, mustBeInteger} = [1]
    rend double {mustBePositive, mustBeInteger} = []
end

filename = get_filename(fid);

datasetPath = "/CONT" + blkid + "/INDEX";

if nargin == 4
    data = h5read(filename, datasetPath, rbeg, rend-rbeg+1);
elseif nargin == 2
    data = h5read(filename, datasetPath);
else 
    error('Invalid number of arguments')
end

time = data.time;
% as in `mex_dh_readcontindex` of dhfun.cpp
offset = data.offset + 1;

end
