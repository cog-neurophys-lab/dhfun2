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

end