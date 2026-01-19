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
%  forceDelete - (optional) logical, if true, skips interactive
%      confirmation when deleting existing file in 'w' mode. Default: false
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
function fid = open(filename, access, options)

arguments
    filename char
    access char
    options.forceDelete logical = false
end

switch access
    case 'w'
        % Create new file or truncate existing
        if isfile(filename)
            if ~options.forceDelete
                answer = input(sprintf('File "%s" already exists. Delete it? (y/n): ', filename), 's');
                if ~strcmpi(answer, 'y')
                    error('Operation cancelled by user.');
                end
            end
            delete(filename);
        end

        % Create new HDF5 file with DAQ-HDF version 2 structure
        plist = 'H5P_DEFAULT';
        fid = H5F.create(filename, 'H5F_ACC_TRUNC', plist, plist);

        % Set FILEVERSION attribute
        file_id_for_attrs = fid;
        attr_space = H5S.create_simple(1, 1, []);
        attr = H5A.create(file_id_for_attrs, 'FILEVERSION', 'H5T_NATIVE_INT32', attr_space, plist, plist);
        H5A.write(attr, 'H5T_NATIVE_INT32', int32(2));
        H5A.close(attr);
        H5S.close(attr_space);

        % Set BOARDS attribute (empty string array)
        str_type = H5T.copy('H5T_C_S1');
        H5T.set_size(str_type, 'H5T_VARIABLE');
        attr_space = H5S.create_simple(1, 1, []);
        attr = H5A.create(file_id_for_attrs, 'Boards', str_type, attr_space, plist, plist);
        H5A.write(attr, str_type, {''});
        H5A.close(attr);
        H5S.close(attr_space);
        H5T.close(str_type);

        return;

    case 'r'
        flags = "H5F_ACC_RDONLY";
    case 'r+'
        flags = "H5F_ACC_RDWR";
end

fid = H5F.open(filename, flags, 'H5P_DEFAULT');

