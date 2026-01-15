%  dhfun(DH.CREATECONT,FID,BLKID,SAMPLES,CHANNELS,SAMPLEPERIOD,INDEXSIZE)
%
%  Create a new CONT block in a V2 file.
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of the new CONT Ntrode
%  SAMPLES   - length of the continuously recorded data, in samples
%  CHANNELS  - number of channels in this nTrode
%  SAMPLEPERIOD - sampling time interval for this nTrode,
%              measured in nanoseconds.
%  INDEXSIZE - number of items in this CONT block's index,
%              also known as number of continuous regions
%              in this piecewise-continuous recording.
%
%  Remarks:
%
%  For every CONT block in a DAQ-HDF file, its sizes must be
%  known at the time of creation. Once a CONT block was created,
%  its sises cannot be changed.
%
%  INDEX dataset of this CONT block will contain zeros at
%  the time of creation. The application should fill the
%  INDEX dataset with correct values as soon as possible.
%  Some DAQ-HDF reading programs may not be prepared for invalid
%  contents of CONTn/INDEX dataset.
%
%  The freshly created CONT block will have no CHAN_DESC
%  attribute specified (that attribute contains A/D descriptive
%  information for each channel in the CONT block).
%  The application should set this attribute, because many
%  programs which read DAQ-HDF files depend on the presence of it.
%
%  This function will fail if the file was not opened for
%  write access.
%
%  If a CONT block with the same BLKID already exists in the
%  file, this function will fail. The existing CONT block contents
%  will be preserved.
%
function createcont(fid, blkid, samples, channels, sampleperiod, indexsize)

arguments
    fid
    blkid double {mustBePositive, mustBeInteger}
    samples double {mustBePositive, mustBeInteger}
    channels double {mustBePositive, mustBeInteger}
    sampleperiod double {mustBePositive, mustBeInteger}
    indexsize double {mustBePositive, mustBeInteger}
end

filename = get_filename(fid);

% Check if CONT block already exists
groupName = "/CONT" + blkid;
try
    info = h5info(filename, groupName);
    % If we get here, the group exists - throw error
    error('dhfun2:dh:createcont:BlockExists', ...
        'CONT block %d already exists in file %s', blkid, filename);
catch ME
    if strcmp(ME.identifier, 'dhfun2:dh:createcont:BlockExists')
        % Re-throw our custom error
        rethrow(ME);
    end
    % Any other error means the group doesn't exist, which is what we want
end

% Create the CONT group
plist = 'H5P_DEFAULT';
file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);
try
    group_id = H5G.create(file_id, groupName, plist, plist, plist);
    
    % Create CONT_INDEX_ITEM datatype if it doesn't exist
    try
        % Try to open existing datatype
        type_id = H5T.open(file_id, 'CONT_INDEX_ITEM');
        H5T.close(type_id);
    catch
        % Create the compound datatype for INDEX
        type_id = H5T.create('H5T_COMPOUND', 16);
        H5T.insert(type_id, 'time', 0, 'H5T_NATIVE_INT64');
        H5T.insert(type_id, 'offset', 8, 'H5T_NATIVE_INT64');
        H5T.commit(file_id, 'CONT_INDEX_ITEM', type_id, plist, plist, plist);
        H5T.close(type_id);
    end
    
    % Create DATA dataset (int16, dimensions: [channels, samples])
    % Note: HDF5 uses C-order (row-major) while MATLAB uses column-major
    % So we reverse the dimensions when creating the dataspace
    data_space = H5S.create_simple(2, [samples, channels], []);
    data_set = H5D.create(group_id, 'DATA', 'H5T_NATIVE_SHORT', data_space, plist, plist, plist);
    H5D.close(data_set);
    H5S.close(data_space);
    
    % Create INDEX dataset (compound type, dimensions: [indexsize])
    index_type = H5T.create('H5T_COMPOUND', 16);
    H5T.insert(index_type, 'time', 0, 'H5T_NATIVE_INT64');
    H5T.insert(index_type, 'offset', 8, 'H5T_NATIVE_INT64');
    
    index_space = H5S.create_simple(1, indexsize, []);
    index_set = H5D.create(group_id, 'INDEX', index_type, index_space, plist, plist, plist);
    
    % Initialize INDEX with zeros
    zero_data = struct('time', zeros(indexsize, 1, 'int64'), ...
        'offset', zeros(indexsize, 1, 'int64'));
    H5D.write(index_set, index_type, 'H5S_ALL', 'H5S_ALL', plist, zero_data);
    
    H5D.close(index_set);
    H5S.close(index_space);
    H5T.close(index_type);
    
    % Create SamplePeriod attribute
    attr_space = H5S.create_simple(1, 1, []);
    attr = H5A.create(group_id, 'SamplePeriod', 'H5T_NATIVE_INT32', attr_space, plist, plist);
    H5A.write(attr, 'H5T_NATIVE_INT32', int32(sampleperiod));
    H5A.close(attr);
    H5S.close(attr_space);
    
    % Create empty Channels attribute (structure array)
    % This will be a compound type with the channel description fields
    chan_type = H5T.create('H5T_COMPOUND', 18);
    H5T.insert(chan_type, 'GlobalChanNumber', 0, 'H5T_NATIVE_SHORT');
    H5T.insert(chan_type, 'BoardChanNo', 2, 'H5T_NATIVE_SHORT');
    H5T.insert(chan_type, 'ADCBitWidth', 4, 'H5T_NATIVE_SHORT');
    H5T.insert(chan_type, 'MaxVoltageRange', 6, 'H5T_NATIVE_FLOAT');
    H5T.insert(chan_type, 'MinVoltageRange', 10, 'H5T_NATIVE_FLOAT');
    H5T.insert(chan_type, 'AmplifChan0', 14, 'H5T_NATIVE_FLOAT');
    
    chan_space = H5S.create_simple(1, channels, []);
    chan_attr = H5A.create(group_id, 'Channels', chan_type, chan_space, plist, plist);
    
    % Initialize with zeros
    zero_channels = struct('GlobalChanNumber', zeros(channels, 1, 'int16'), ...
        'BoardChanNo', zeros(channels, 1, 'int16'), ...
        'ADCBitWidth', zeros(channels, 1, 'int16'), ...
        'MaxVoltageRange', zeros(channels, 1, 'single'), ...
        'MinVoltageRange', zeros(channels, 1, 'single'), ...
        'AmplifChan0', zeros(channels, 1, 'single'));
    H5A.write(chan_attr, chan_type, zero_channels);
    
    H5A.close(chan_attr);
    H5S.close(chan_space);
    H5T.close(chan_type);
    
    H5G.close(group_id);
catch ME
    H5F.close(file_id);
    rethrow(ME);
end

H5F.close(file_id);