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

function data = readcont(fid, blkid, sambeg, samend, chnbeg, chnend)

arguments
    fid
    blkid double {mustBePositive, mustBeInteger}
    sambeg double {mustBePositive, mustBeInteger} = []
    samend double {mustBePositive, mustBeInteger} = []
    chnbeg double {mustBePositive, mustBeInteger} = []
    chnend double {mustBePositive, mustBeInteger} = []
end

filename = get_filename(fid);

datasetPath = "/CONT" + blkid + "/DATA";

switch nargin
    case 2
        data = h5read(filename, datasetPath);
    case 4
        [~, nChannels] =  dh.getcontsize(filename, blkid);
        data = h5read(filename, datasetPath, [1, sambeg], [nChannels, samend-sambeg+1]);
    case 6
        data = h5read(filename, datasetPath, [chnbeg, sambeg], [chnend-chnbeg+1, samend-sambeg+1]);
    otherwise
        error("Invalid number of input arguments %d", nargin)
end


end



