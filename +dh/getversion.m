function version = getversion(fid)

filename = get_filename(fid);
fileAttrs = h5info(filename).Attributes;
version = fileAttrs(cellfun(@(name) string(name) == "FILEVERSION", {fileAttrs.Name})).Value;


    