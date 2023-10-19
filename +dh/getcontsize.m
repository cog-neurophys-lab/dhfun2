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

function [nsamp, nchan] = getcontsize(fid, blkid)

arguments
    fid 
    blkid double {mustBeInteger}
end
filename = get_filename(fid);
contInfo = dh.getcontinfo(filename, blkid);

nchan = zeros(1, length(blkid));
nsamp = zeros(1, length(blkid));

for iCont = 1:length(blkid)
    nchan(iCont) = contInfo(iCont).Datasets(1).Dataspace.Size(1);
    nsamp(iCont) = contInfo(iCont).Datasets(1).Dataspace.Size(2);
end

end