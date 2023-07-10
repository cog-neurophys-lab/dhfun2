function contInfo = getcontinfo(fid, blockid)

arguments
    fid 
    blockid double {mustBeInteger}
end

filename = get_filename(fid);

info = h5info(filename);
iGroup = cellfun(@(name) string(name) == "/CONT" + blockid, {info.Groups.Name});
contInfo = info.Groups(iGroup);

end