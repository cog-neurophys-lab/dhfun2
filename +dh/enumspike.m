%  OUTPUT = DHFUN.ENUMSPIKE(FID);
%
%  Enumerate SPIKEx block identifers in a V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  OUTPUT - variable to store SPIKEx block identifiers
%           a vector will be returned. All identifiers
%           are sorted in ascending order.
%           Empty matrix is returned if there are no
%           SPIKE blocks in the file
%
%  Remarks:
%
%  Identifiers returned by this function are safe for
%  using in any SPIKE-block related functions
%
%  -------------------------------------------------

function iSpike = enumspike(fid)

filename = get_filename(fid);
info = h5info(filename);
spikeGroups = info.Groups( ...
    cellfun(@(x) string(x).startsWith("/SPIKE") , {info.Groups.Name}) ...
    );
iSpike = cellfun(@(x) str2double(x(7:end)), {spikeGroups.Name});

end
