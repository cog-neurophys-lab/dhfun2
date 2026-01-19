%  dhfun(DH.WRITEEV2, FID, RBEG, REND, TIME, EVENT);
%
%  Write contents of the EV02 dataset in the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  RBEG,REND - range of record numbers to write. Records from
%              RBEG to REND will be written inclusively.
%  TIME - variable holding 'time' field of EV02 records
%         (int64 or double array, will be converted to int64)
%  EVENT - variable holding 'event' field of EV02 records
%          (int32 array)
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed.
%
%  The EV02 dataset must already exist in the file. Use dh.createev2
%  to create it first if needed.
function writeev2(fid, rbeg, rend, time, event)

arguments
    fid
    rbeg double {mustBePositive, mustBeInteger}
    rend double {mustBePositive, mustBeInteger}
    time {mustBeVector}
    event {mustBeVector}
end

filename = get_filename(fid);
datasetPath = '/EV02';

% Validate input lengths
expected_length = rend - rbeg + 1;
if length(time) ~= expected_length
    error('dhfun2:dh:writeev2:InvalidTimeLength', ...
        'TIME must have length %d but got %d', expected_length, length(time));
end

if length(event) ~= expected_length
    error('dhfun2:dh:writeev2:InvalidEventLength', ...
        'EVENT must have length %d but got %d', expected_length, length(event));
end

% Create structure for writing
ev2_data = struct('time', int64(time(:)), 'event', int32(event(:)));

% Write using low-level HDF5 API for structure data
plist = 'H5P_DEFAULT';
file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);

try
    dset_id = H5D.open(file_id, datasetPath);

    % Create memory datatype to match EV02 structure
    % struct with time (int64) at offset 0, event (int32) at offset 8
    mem_type = H5T.create('H5T_COMPOUND', 12);
    H5T.insert(mem_type, 'time', 0, 'H5T_NATIVE_INT64');
    H5T.insert(mem_type, 'event', 8, 'H5T_NATIVE_INT32');

    % Create memory and file dataspaces for partial write
    mem_space = H5S.create_simple(1, expected_length, []);
    file_space = H5D.get_space(dset_id);
    H5S.select_hyperslab(file_space, 'H5S_SELECT_SET', rbeg-1, [], expected_length, []);

    % Write the data
    H5D.write(dset_id, mem_type, mem_space, file_space, plist, ev2_data);

    % Clean up
    H5S.close(mem_space);
    H5S.close(file_space);
    H5T.close(mem_type);
    H5D.close(dset_id);
    H5F.close(file_id);
catch ME
    H5F.close(file_id);
    rethrow(ME);
end

end
