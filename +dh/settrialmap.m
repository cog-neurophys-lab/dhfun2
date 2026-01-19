%  dhfun(DH.SETTRIALMAP, FID, TRIALNO, STIMNO, OUTCOME, STARTTIME, ENDTIME);
%
%  Write the entire contents of the TRIALMAP dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%  TRIALNO - TrialNo member of TRIALMAP_ITEM struct (int32 array)
%  STIMNO - StimNo member of TRIALMAP_ITEM struct (int32 array)
%  OUTCOME - Outcome member of TRIALMAP_ITEM struct (int32 array)
%  STARTTIME - StartTime member in nanoseconds (int64 or double array)
%  ENDTIME - EndTime member in nanoseconds (int64 or double array)
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed.
%  If the TRIALMAP dataset does not exist in the file, it will be created.
%  Any existing TRIALMAP dataset will be deleted and then
%  re-created with a new number of items. Repeated overwriting of
%  TRIALMAP will produce multiple deleted datasets and, consequently,
%  increase in HDF-file size.
%
%  All input arrays (except FID) must have the same length.
function settrialmap(fid, trialno, stimno, outcome, starttime, endtime)

arguments
    fid
    trialno {mustBeVector}
    stimno {mustBeVector}
    outcome {mustBeVector}
    starttime {mustBeVector}
    endtime {mustBeVector}
end

filename = get_filename(fid);

% Validate all arrays have the same length
numTrials = length(trialno);

if length(stimno) ~= numTrials
    error('dhfun2:dh:settrialmap:InvalidStimNoLength', ...
        'STIMNO must have length %d but got %d', numTrials, length(stimno));
end

if length(outcome) ~= numTrials
    error('dhfun2:dh:settrialmap:InvalidOutcomeLength', ...
        'OUTCOME must have length %d but got %d', numTrials, length(outcome));
end

if length(starttime) ~= numTrials
    error('dhfun2:dh:settrialmap:InvalidStartTimeLength', ...
        'STARTTIME must have length %d but got %d', numTrials, length(starttime));
end

if length(endtime) ~= numTrials
    error('dhfun2:dh:settrialmap:InvalidEndTimeLength', ...
        'ENDTIME must have length %d but got %d', numTrials, length(endtime));
end

% Create structure for writing
trialmap_data = struct(...
    'TrialNo', int32(trialno(:)), ...
    'StimNo', int32(stimno(:)), ...
    'Outcome', int32(outcome(:)), ...
    'StartTime', int64(starttime(:)), ...
    'EndTime', int64(endtime(:)));

plist = 'H5P_DEFAULT';
file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);

try
    % Check if TRIALMAP already exists
    dataset_exists = false;
    try
        H5D.open(file_id, '/TRIALMAP');
        H5D.close(H5D.open(file_id, '/TRIALMAP'));
        dataset_exists = true;
    catch
        % Dataset doesn't exist, which is fine
    end

    % If dataset exists, delete it (it will be marked as deleted in HDF5)
    if dataset_exists
        H5L.delete(file_id, '/TRIALMAP', plist);
    end

    % Create compound datatype for TRIALMAP structure
    trialmap_type = H5T.create('H5T_COMPOUND', 28);
    H5T.insert(trialmap_type, 'TrialNo', 0, 'H5T_STD_I32LE');
    H5T.insert(trialmap_type, 'StimNo', 4, 'H5T_STD_I32LE');
    H5T.insert(trialmap_type, 'Outcome', 8, 'H5T_STD_I32LE');
    H5T.insert(trialmap_type, 'StartTime', 12, 'H5T_STD_I64LE');
    H5T.insert(trialmap_type, 'EndTime', 20, 'H5T_STD_I64LE');

    % Create dataspace
    dspace = H5S.create_simple(1, numTrials, []);

    % Create dataset
    dset = H5D.create(file_id, '/TRIALMAP', trialmap_type, dspace, plist);

    % Create memory datatype for writing
    mem_type = H5T.create('H5T_COMPOUND', 28);
    H5T.insert(mem_type, 'TrialNo', 0, 'H5T_NATIVE_INT32');
    H5T.insert(mem_type, 'StimNo', 4, 'H5T_NATIVE_INT32');
    H5T.insert(mem_type, 'Outcome', 8, 'H5T_NATIVE_INT32');
    H5T.insert(mem_type, 'StartTime', 12, 'H5T_NATIVE_INT64');
    H5T.insert(mem_type, 'EndTime', 20, 'H5T_NATIVE_INT64');

    % Write the data
    H5D.write(dset, mem_type, 'H5S_ALL', 'H5S_ALL', plist, trialmap_data);

    % Clean up
    H5T.close(mem_type);
    H5D.close(dset);
    H5S.close(dspace);
    H5T.close(trialmap_type);
    H5F.close(file_id);
catch ME
    H5F.close(file_id);
    rethrow(ME);
end

end
