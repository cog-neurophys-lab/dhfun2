%  [time,offset,scaling] = dhfun(DH.READWAVELETINDEX,FID,BLKID,RBEG,REND);
%
%  Read contents of a WAVELETx index block
%
%  Arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet nTrode
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%
%  Outputs:
%
%  TIME, OFFSET, SCALING - variables to store 'time', 'offset'
%          and 'scaling' fields of index items. TIME is given
%          in nanoseconds (double array), OFFSET is given in samples
%          (int32 array), and SCALING is a double array. Offset is
%          1-based and references to the beginning of wavelet dataset.
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
%  include gaps. The index system is similar to that of CONT blocks.
%
%  SCALING values are used to restore floating-point values of
%  wavelet magnitude. All values within contiguous regions of
%  recording must be multiplied by corresponding values of
%  SCALING.
%
%  To restore the value of an arbitrary sample within wavelet block,
%  one must first find to which region does it belong. Then the
%  region's scaling value must be fetched and multipied by that sample's
%  raw value (16-bit unsigned integer).

function [time,offset,scaling] = readwaveletindex(fid,blkid,rbeg,rend)
% 
filename = get_filename(fid);

switch nargin
    case 2
        index = h5read(filename, "/WAVELET" + blkid + "/INDEX");
    case 4
        index = h5read(filename, "/WAVELET" + blkid + "/INDEX", rbeg, rend-rbeg+1);
    otherwise
        error('Invalid number of input arguments. Should be 2 or 4')        
end

time = double(index.time);
% as in mex_dh_readwaveletindex of dhfun.cpp
offset = index.offset + 1;
scaling = double(index.scaling);