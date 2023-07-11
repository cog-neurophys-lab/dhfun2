function contInfo = getcontinfo(fid, blockid)

arguments
    fid 
    blockid double {mustBeInteger}
end

filename = get_filename(fid);
contInfo = h5info(filename, "/CONT" + blockid);

end