%  dhfun(DH.WRITECONTINDEX, FID, BLKID, RBEG, REND, TIME, OFFSET);
%
%  Write contents of a CONTx index block in V2 file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  RBEG,REND - range of record numbers to write. Records from
%              RBEG to REND will be written inclusively.
%  TIME, OFFSET - variables holding 'time' and 'offset'
%          fields of index items. TIME is given in nanoseconds
%          (double array), and OFFSET is given in samples
%          (int32 array). Offset is 1-based and references
%          to the beginning of cont dataset.
%
%  Remarks:
%
%  This function will only succeed if the file was opened
%  for writing.
%
%  For additional information, see DH.READCONTINDEX
function writecontindex(fid, blkid, rbeg, rend, time, offset)

arguments
    fid
    blkid double {mustBePositive, mustBeInteger}
    rbeg double {mustBePositive, mustBeInteger}
    rend double {mustBePositive, mustBeInteger}
    time double {mustBeVector}
    offset {mustBeVector}
end

filename = get_filename(fid);
datasetPath = "/CONT" + blkid + "/INDEX";

% Validate input lengths
expected_length = rend - rbeg + 1;
if length(time) ~= expected_length
    error('dhfun2:dh:writecontindex:InvalidTimeLength', ...
        'TIME must have length %d but got %d', expected_length, length(time));
end

if length(offset) ~= expected_length
    error('dhfun2:dh:writecontindex:InvalidOffsetLength', ...
        'OFFSET must have length %d but got %d', expected_length, length(offset));
end

% Convert offset from 1-based to 0-based (as stored in file)
offset_zero_based = int64(offset) - 1;

% Create structure for writing
index_data = struct('time', int64(time(:)), 'offset', int64(offset_zero_based(:)));

% Write using low-level HDF5 API for structure data
plist = 'H5P_DEFAULT';
file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);

try
    dset_id = H5D.open(file_id, datasetPath);
    
    % Create memory datatype
    mem_type = H5T.create('H5T_COMPOUND', 16);
    H5T.insert(mem_type, 'time', 0, 'H5T_NATIVE_INT64');
    H5T.insert(mem_type, 'offset', 8, 'H5T_NATIVE_INT64');
    
    % Create memory and file dataspaces for partial write
    mem_space = H5S.create_simple(1, expected_length, []);
    file_space = H5D.get_space(dset_id);
    H5S.select_hyperslab(file_space, 'H5S_SELECT_SET', rbeg-1, [], expected_length, []);
    
    % Write the data
    H5D.write(dset_id, mem_type, mem_space, file_space, plist, index_data);
    
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