function filename = get_filename(fid)

if isinteger(fid)
    filename = fopen(fid);
elseif ischar(fid) || isstring(fid)
    filename = fid;
else
    error("Cannot determine filename from fid/filename");
end

end