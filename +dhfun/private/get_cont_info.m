function contInfo = get_cont_info(filename, blockid)

arguments
    filename char
    blockid double {mustBeInteger}
end

info = h5info(filename);
iGroup = cellfun(@(name) string(name) == "/CONT" + blockid, {info.Groups.Name});
contInfo = info.Groups(iGroup);

end