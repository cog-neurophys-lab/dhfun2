%  FID = DHFUN.OPEN(FILENAME,ACCESS, <FID_ORIGINAL> );
%
%  Open a DAQ-HDF file
%
%  arguments:
%
%  FILENAME - character string
%  ACCESS - character string, access mode. Possible values:
%   'r' - read existing
%   'w' - create new or truncate existing file, read and write
%   'r+' - update existing file, read and write
%  FID_ORIGINAL - (optional) file identifier of another opened
%      DAQ-HDF file used when creating a derivative file.
%
%
%  FID - file identifier, should be stored in a variable for further
%  operations with this file
%
%  Remarks:
%
%  Write functions (such as WRITECONT) succeed only on
%  files opened for writing (modes 'w' and 'r+').
%
%  Truncation mode ('w') creates an empty DAQ-HDF file of
%  version 2. The file can be populated by functions like
%  CREATECONT, etc. A DAQ-HDF file can be created as a
%  derivative of another DAQ-HDF file. In this case,
%  file identifier of the original file must be supplied.
%  For derivative files, processing history of the original
%  file is copied, and original file name is saved in a
%  processing history entry when the target file is closed.
%
%  All files opened by this function must be closed when they
%  are no longer needed, using the function DH.CLOSE. Failure
%  to do so (for example, in case of a user program error)
%  will cause the files to remain open and blocked by the
%  operating system, wasting the system resources.
%
%  When the DHFUN mex file is unloaded, it closes all open
%  files. User can unload the mex file by executing
%  'clear dhfun' command from Matlab. This will cause
%  all files opened by DHFUN to be closed.
function fid = open(filename, access)

arguments 
    filename char
    access char
end

H5.open();

switch access
    case 'w'
        flags = "H5ACC_RDWR";
    case 'r'
        flags = "H5F_ACC_RDONLY";
    case 'r+'
        flags = "H5F_ACC_RDWR";
end

fid = H5F.open(filename, flags);

return;

