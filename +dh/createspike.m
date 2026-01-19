%  dhfun(DH.CREATESPIKE,FID,BLKID,SPIKES,CHANNELS,SAMPLEPERIOD,SPIKESAMPLES,PRETRIGSAMPLES,LOCKOUTSAMPLES)
%
%  Create a new SPIKE block in a V2 file.
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of the new SPIKE Ntrode
%  SPIKES    - number of spikes to be stored
%  CHANNELS  - number of channels in this nTrode
%  SAMPLEPERIOD - sampling time interval for this nTrode,
%              measured in nanoseconds.
%  SPIKESAMPLES - number of samples recorded for every spike
%  PRETRIGSAMPLES - number of preTrig samples
%  LOCKOUTSAMPLES - number of lockOut samples
%
%  Remarks:
%
%  For every SPIKE block in a DAQ-HDF file, its sizes must be
%  known at the time of creation. Once a SPIKE block was created,
%  its sizes cannot be changed.
%
%  INDEX dataset of this SPIKE block will contain zeros at
%  the time of creation. The application should fill the
%  INDEX dataset with correct values as soon as possible.
%
%  The freshly created SPIKE block will have no CHAN_DESC
%  attribute specified (that attribute contains A/D descriptive
%  information for each channel in the SPIKE block).
%
%  This function will fail if the file was not opened for
%  write access.
%
%  If a SPIKE block with the same BLKID already exists in the
%  file, this function will fail. The existing SPIKE block contents
%  will be preserved.
%
function createspike(fid, blkid, spikes, channels, sampleperiod, spikesamples, pretrigsamples, lockoutsamples)

arguments
    fid
    blkid double {mustBeNonnegative, mustBeInteger}
    spikes double {mustBeNonnegative, mustBeInteger}
    channels double {mustBePositive, mustBeInteger}
    sampleperiod double {mustBePositive, mustBeInteger}
    spikesamples double {mustBePositive, mustBeInteger}
    pretrigsamples double {mustBeNonnegative, mustBeInteger}
    lockoutsamples double {mustBeNonnegative, mustBeInteger}
end

filename = get_filename(fid);

% Check if SPIKE block already exists
groupName = "/SPIKE" + blkid;
try
    info = h5info(filename, groupName);
    % If we get here, the group exists - throw error
    error('dhfun2:dh:createspike:BlockExists', ...
        'SPIKE block %d already exists in file %s', blkid, filename);
catch ME
    if strcmp(ME.identifier, 'dhfun2:dh:createspike:BlockExists')
        % Re-throw our custom error
        rethrow(ME);
    end
    % Any other error means the group doesn't exist, which is what we want
end

% Create the SPIKE group
plist = 'H5P_DEFAULT';
file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);
try
    group_id = H5G.create(file_id, groupName, plist, plist, plist);

    % Create DATA dataset (int16, dimensions: [channels, total_samples])
    % This matches the existing format in test_data.dh5
    total_samples = spikes * spikesamples;
    data_space = H5S.create_simple(2, [total_samples, channels], []);
    data_set = H5D.create(group_id, 'DATA', 'H5T_NATIVE_SHORT', data_space, plist, plist, plist);
    H5D.close(data_set);
    H5S.close(data_space);

    % Create INDEX dataset (int64, dimensions: [spikes])
    index_space = H5S.create_simple(1, spikes, []);
    index_set = H5D.create(group_id, 'INDEX', 'H5T_NATIVE_INT64', index_space, plist, plist, plist);

    % Initialize INDEX with zeros
    if spikes > 0
        H5D.write(index_set, 'H5T_NATIVE_INT64', 'H5S_ALL', 'H5S_ALL', plist, zeros(spikes, 1, 'int64'));
    end

    H5D.close(index_set);
    H5S.close(index_space);

    % Create SamplePeriod attribute
    attr_space = H5S.create_simple(1, 1, []);
    attr = H5A.create(group_id, 'SamplePeriod', 'H5T_NATIVE_INT32', attr_space, plist, plist);
    H5A.write(attr, 'H5T_NATIVE_INT32', int32(sampleperiod));
    H5A.close(attr);
    H5S.close(attr_space);

    % Create SpikeParams attribute (compound type)
    spike_params_type = H5T.create('H5T_COMPOUND', 6);
    H5T.insert(spike_params_type, 'spikeSamples', 0, 'H5T_NATIVE_SHORT');
    H5T.insert(spike_params_type, 'preTrigSamples', 2, 'H5T_NATIVE_SHORT');
    H5T.insert(spike_params_type, 'lockOutSamples', 4, 'H5T_NATIVE_SHORT');

    params_space = H5S.create_simple(1, 1, []);
    params_attr = H5A.create(group_id, 'SpikeParams', spike_params_type, params_space, plist, plist);

    spike_params = struct('spikeSamples', int16(spikesamples), ...
        'preTrigSamples', int16(pretrigsamples), ...
        'lockOutSamples', int16(lockoutsamples));
    H5A.write(params_attr, spike_params_type, spike_params);

    H5A.close(params_attr);
    H5S.close(params_space);
    H5T.close(spike_params_type);

    % Create Channels attribute (structure array)
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
