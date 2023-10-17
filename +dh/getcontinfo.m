function contInfo = getcontinfo(fid, blockid)
% GETCONTINFO  Get information about continuous data blocks
%
% Syntax:
% contInfo = GETCONTINFO(fid, blockid)
%
% Description:
% Returns information about the continuous data blocks in the file.
%
% Input:
% fid (string) - The filename or or identifier of an open file.
% blockid (integer) - The block number(s) to return information about.
%
% Output:
% contInfo (struct) - A structure array containing information about the
%     requested continuous data blocks.
%

arguments
    fid 
    blockid double {mustBeInteger} = []
end

filename = get_filename(fid);


dh5Info = h5info(filename);
groupNames = {dh5Info.Groups.Name};
iSelected = zeros(1, length(blockid));
for iCont = 1:length(blockid)
    iSelected(iCont) = find(cellfun(@(x) string(x) == "/CONT" + blockid(iCont), groupNames));
end

contInfo = dh5Info.Groups(iSelected);

end