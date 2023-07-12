function filename = get_filename(fid)

if isinteger(fid)
    filename = (fid);
elseif ischar(fid) || isstring(fid)
    filename = fid;
elseif isa(fid, 'H5ML.id')
    filename = H5F.get_name(fid);
else
    error("Cannot determine filename from fid/filename");
end

if (hdfml('ishdf',filename) == 0)
    error('File is not HDF');
end

if (hdfml('isfile',filename) == 0)
    error('File does not exist');
end

if (hdfml('isreadonly',filename) == 1)
    error('File is read-only');
end

end