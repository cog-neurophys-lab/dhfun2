%  dhfun(DH.CREATEWAVELET,FID,BLKID,CHANNELS,SAMPLES,FAXIS,SAMPLEPERIOD,INDEXSIZE)
%
%  Create a new WAVELET block in a V2 file.
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of the new WAVELET Ntrode
%  CHANNELS  - number of channels in this nTrode
%  SAMPLES   - length of the time-frequency data, in time samples
%  FAXIS     - frequency axis values in Hz (double array)
%  SAMPLEPERIOD - sampling time interval for this nTrode,
%              measured in nanoseconds.
%  INDEXSIZE - number of items in this WAVELET block's index,
%              also known as number of continuous regions
%              in this piecewise-continuous recording.
%
%  Remarks:
%
%  For every WAVELET block in a DAQ-HDF file, its sizes must be
%  known at the time of creation. Once a WAVELET block was created,
%  its sizes cannot be changed.
%
%  INDEX dataset of this WAVELET block will contain zeros at
%  the time of creation. The application should fill the
%  INDEX dataset with correct values as soon as possible.
%
%  This function will fail if the file was not opened for
%  write access.
%
%  If a WAVELET block with the same BLKID already exists in the
%  file, this function will fail. The existing WAVELET block contents
%  will be preserved.
%
function createwavelet(fid, blkid, channels, samples, faxis, sampleperiod, indexsize)

arguments
    fid
    blkid double {mustBePositive, mustBeInteger}
    channels double {mustBePositive, mustBeInteger}
    samples double {mustBePositive, mustBeInteger}
    faxis double
    sampleperiod double {mustBePositive, mustBeInteger}
    indexsize double {mustBePositive, mustBeInteger}
end

filename = get_filename(fid);

% Get number of frequency bins from faxis
freqbins = length(faxis);

% Check if WAVELET block already exists
groupName = "/WAVELET" + blkid;
try
    h5info(filename, groupName);
    % If we get here, the group exists - throw error
    error('dhfun2:dh:createwavelet:BlockExists', ...
        'WAVELET block %d already exists in file %s', blkid, filename);
catch ME
    if strcmp(ME.identifier, 'dhfun2:dh:createwavelet:BlockExists')
        % Re-throw our custom error
        rethrow(ME);
    end
    % Any other error means the group doesn't exist, which is what we want
end

% Create the WAVELET group
plist = 'H5P_DEFAULT';
file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);
cleanup_file = onCleanup(@() H5F.close(file_id));

group_id = H5G.create(file_id, groupName, plist, plist, plist);
cleanup_group = onCleanup(@() H5G.close(group_id));

% Create WAVELET_SAMPLE datatype if it doesn't exist
try
    % Try to open existing datatype
    type_id = H5T.open(file_id, 'WAVELET_SAMPLE');
    H5T.close(type_id);
catch
    % Create the compound datatype for wavelet samples
    sample_type = H5T.create('H5T_COMPOUND', 3); % uint16 + int8 = 2 + 1 = 3 bytes
    H5T.insert(sample_type, 'a', 0, 'H5T_NATIVE_UINT16');
    H5T.insert(sample_type, 'phi', 2, 'H5T_NATIVE_INT8');
    H5T.commit(file_id, 'WAVELET_SAMPLE', sample_type);
    H5T.close(sample_type);
end

% Create WAVELET_INDEX_ITEM datatype if it doesn't exist
try
    % Try to open existing datatype
    type_id = H5T.open(file_id, 'WAVELET_INDEX_ITEM');
    H5T.close(type_id);
catch
    % Create the compound datatype for wavelet index
    index_type = H5T.create('H5T_COMPOUND', 24); % int64 + int64 + double = 8 + 8 + 8 = 24 bytes
    H5T.insert(index_type, 'time', 0, 'H5T_NATIVE_INT64');
    H5T.insert(index_type, 'offset', 8, 'H5T_NATIVE_INT64');
    H5T.insert(index_type, 'scaling', 16, 'H5T_NATIVE_DOUBLE');
    H5T.commit(file_id, 'WAVELET_INDEX_ITEM', index_type);
    H5T.close(index_type);
end

% Close handles before using high-level API
clear cleanup_group cleanup_file;

% Create DATA dataset [freqbins, samples, channels]
h5create(filename, groupName + "/DATA", [freqbins, samples, channels], ...
    'Datatype', 'WAVELET_SAMPLE', 'ChunkSize', [freqbins, min(samples, 1000), 1]);

% Create INDEX dataset
h5create(filename, groupName + "/INDEX", indexsize, ...
    'Datatype', 'WAVELET_INDEX_ITEM');

% Set attributes
h5writeatt(filename, groupName, 'SamplePeriod', int32(sampleperiod));
h5writeatt(filename, groupName, 'FrequencyAxis', faxis);

end
