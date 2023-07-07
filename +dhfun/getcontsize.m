%  [NSAMP, NCHAN] = dhfun(DH.GETCONTSIZE, FID, BLKID);
%  
%  Get number of samples and number of channels for a
%  given continuous nTrode
%  
%  arguments:
%  
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  
%  NSAMP - variable to store number of samples
%  NCHAN - variable to store number of channels

function [nsamp, nchan] = getcontsize(filename, blkid)

arguments
    filename char
    blkid double {mustBeInteger}
end

contGroups = dhfun.enumcont(filename);
if ~ismember(blkid, contGroups)
    error('No such CONT block')
end

contInfo = get_cont_info(filename, blkid);

nchan = contInfo.Datasets(1).Dataspace.Size(1);
nsamp = contInfo.Datasets(1).Dataspace.Size(2);


end