function createev2(filename, numRecords)
%CREATEEV2 Create EV02 dataset in a DAQ-HDF5 file
%
%   CREATEEV2(FILENAME, NUMRECORDS) creates the EV02 dataset in the
%   specified dh5 file with capacity for NUMRECORDS event records.
%
%   The EV02 dataset stores event triggers with timestamps and event codes.
%   Each record contains:
%   - time (int64): timestamp in nanoseconds
%   - event (int32): encoded event type
%
%   The dataset is initialized with zeros and must be filled using
%   dh.writeev2 function.
%
% Example:
%   dh.createev2('mydata.dh5', 1000);  % Create space for 1000 events
%
% See also: dh.writeev2, dh.readev2

arguments
    filename string {mustBeFile}
    numRecords double {mustBePositive, mustBeInteger}
end

plist = 'H5P_DEFAULT';
file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);

try
    % Create compound datatype for EV02 structure
    % According to spec: time (int64) at offset 0, event (int32) at offset 8
    ev2_type = H5T.create('H5T_COMPOUND', 12);
    H5T.insert(ev2_type, 'time', 0, 'H5T_STD_I64LE');
    H5T.insert(ev2_type, 'event', 8, 'H5T_STD_I32LE');

    % Create dataspace
    dspace = H5S.create_simple(1, numRecords, []);

    % Create dataset
    dset = H5D.create(file_id, '/EV02', ev2_type, dspace, plist);

    % Clean up
    H5D.close(dset);
    H5S.close(dspace);
    H5T.close(ev2_type);
    H5F.close(file_id);

    fprintf('Created EV02 dataset with %d records\n', numRecords);
catch ME
    H5F.close(file_id);
    rethrow(ME);
end

end
