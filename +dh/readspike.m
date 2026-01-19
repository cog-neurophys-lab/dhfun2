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
        % Read all data - will be [channels x samples] from HDF5
        output = h5read(filename, "/SPIKE" + blkid + "/DATA");
        % Transpose to get [samples x channels] for MATLAB
        output = output';
    case 6
        % Read subset of data
        % HDF5 stores as [channels x samples], so start/count are [chn, samp]
        num_channels = chnend - chnbeg + 1;
        num_samples = samend - sambeg + 1;

        output = h5read(filename, "/SPIKE" + blkid + "/DATA", ...
            [chnbeg, sambeg], ...
            [num_channels, num_samples]);

        % Transpose to get [samples x channels] for MATLAB
        output = output';
    otherwise
        error('dhfun2:readspike:invalidNargin',  ...
            'Invalid number of arguments (%g). Should be 2 or 6.', nargin)
end
