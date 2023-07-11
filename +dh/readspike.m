%  OUTPUT = dhfun(DH.READSPIKE, FID, BLKID, SAMBEG, SAMEND, CHNBEG, CHNEND);
%
%  Read contents of a SPIKEx data block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a spike nTrode
%  SAMBEG,SAMEND - range of sample numbers to read. Samples from
%                  SAMBEG to SAMEND will be read inclusively.
%  CHNBEG,CHNEND - range of channel numbers to read. Channels from
%                  CHNBEG to CHNEND will be read inclusively.
%
%  OUTPUT - output variable. A matrix sized [SAMEND-SAMBEG+1,CHNEND-CHNBEG+1]
%           will be returned.
%
%  Remarks:
%
%  Starting and ending samples for a single spike or for a group
%  of spikes can be calculated using spike length obtained from
%  function DH.GETSPIKEPARAMS. To obtain time when a particular
%  spike has been triggered, use DH.READSPIKEINDEX
function output = readspike(fid, blkid, sambeg, samend, chnbeg, chnend)

filename = get_filename(fid);

switch nargin
    case 2
        output = h5read(filename, "/SPIKE" + blkid + "/DATA");
    case 4
        output = h5read(filename, "/SPIKE" + blkid + "/DATA", ...
            [sambeg, chnbeg], ...
            [samend-sambeg+1, chnend-chnbeg+1]);
    otherwise
        error('dhfun2:readspikeindex:invalidNargin',  ...
        'Invalid number of arguments (%g). Should be 2 or 4.', nargin)
end
