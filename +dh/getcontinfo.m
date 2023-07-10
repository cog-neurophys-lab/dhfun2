function contInfo = getcontinfo(fid, blockid)

arguments
    fid 
    blockid double {mustBeInteger}
end

if isinteger(fid)
    filename = fopen(fid);
elseif ischar(fid) || isstring(fid)
    filename = fid;
end

info = h5info(filename);
iGroup = cellfun(@(name) string(name) == "/CONT" + blockid, {info.Groups.Name});
contInfo = info.Groups(iGroup);

end