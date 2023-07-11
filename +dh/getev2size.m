%  REC = dhfun(DH.GETEV2SIZE, FID);
%
%  Get number of records in the EV02 dataset of the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  REC - variable to store number of records

function rec = getev2size(fid)

filename = get_filename(fid);
rec = h5info(filename, '/EV02').Dataspace.Size;
