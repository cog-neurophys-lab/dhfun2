function createfile(filename)
%CREATEFILE Create a minimal valid DAQ-HDF5 file
%
%   CREATEFILE(FILENAME) creates a minimal valid dh5 file with
%   only the required root attributes.
%
%   The created file conforms to the DAQ-HDF specification version 2 and
%   includes only:
%   - Required root attributes (FILEVERSION, Boards)
%
%   No CONT blocks, SPIKE blocks, or other data structures are created.
%   Use dh.createcont or other functions to add data blocks as needed.
%
% Example:
%   dh.createfile('empty.dh5');
%
% See also: dh.createcont, dh.open

% Delete file if it exists
if exist(filename, 'file')
    delete(filename);
end

% Create the file
fid = H5F.create(filename, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');

try
    % Create root attributes
    % FILEVERSION attribute (int32 scalar)
    attr_space = H5S.create('H5S_SCALAR');
    attr_type = H5T.copy('H5T_NATIVE_INT');
    attr = H5A.create(fid, 'FILEVERSION', attr_type, attr_space, 'H5P_DEFAULT');
    H5A.write(attr, 'H5ML_DEFAULT', int32(2));
    H5A.close(attr);
    H5S.close(attr_space);
    H5T.close(attr_type);

    % BOARDS attribute (string array)
    str_type = H5T.copy('H5T_C_S1');
    H5T.set_size(str_type, 'H5T_VARIABLE');
    attr_space = H5S.create_simple(1, 1, []);
    attr = H5A.create(fid, 'Boards', str_type, attr_space, 'H5P_DEFAULT');
    H5A.write(attr, str_type, {'Minimal DH5 File'});
    H5A.close(attr);
    H5S.close(attr_space);
    H5T.close(str_type);

    fprintf('Created minimal dh5 file: %s\n', filename);
    fprintf('  FILEVERSION: 2\n');
    fprintf('  No data blocks created.\n');

catch ME
    H5F.close(fid);
    rethrow(ME);
end

H5F.close(fid);

% Add operation history
dh.createoperation(filename, 'FileCreation', 'Tool', 'dh.createfile');

end
