%  OUTPUT = dhfun(DH.READCONT, FID, BLKID, SAMBEG, SAMEND, CHNBEG, CHNEND);
%
%  Read contents of a CONTx data block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  SAMBEG,SAMEND - range of sample numbers to read. Samples from
%                  SAMBEG to SAMEND will be read inclusively.
%  CHNBEG,CHNEND - range of channel numbers to read. Channels from
%                  CHNBEG to CHNEND will be read inclusively.
%
%  OUTPUT - output variable. A matrix sized [SAMEND-SAMBEG+1,CHNEND-CHNBEG+1]
%           will be returned.

function data = readcont(filename, blkid, sambeg, samend, chnbeg, chnend)

arguments
    filename char
    blkid double {mustBePositive, mustBeInteger}
    sambeg double {mustBePositive, mustBeInteger} = []
    samend double {mustBePositive, mustBeInteger} = []    
    chnbeg double {mustBePositive, mustBeInteger} = []    
    chnend double {mustBePositive, mustBeInteger} = []    
end

datasetPath = "/CONT" + blkid + "/DATA";


if nargin == 2
    data = h5read(filename, datasetPath);
else
    data = h5read(filename, datasetPath, [sambeg, chnbeg], [samend-sambeg+1, chnend-chnbeg+1]);
end


end



