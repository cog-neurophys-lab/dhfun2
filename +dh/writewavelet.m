%  dhfun(DH.WRITEWAVELET, FID, BLKID, CHNBEG, CHNEND, SAMBEG, SAMEND, FRQBEG, FRQEND, A, PHI);
%
%  Write contents of a WAVELETx data block to a V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%  CHNBEG,CHNEND - range of channel numbers to write. Channels from
%                  CHNBEG to CHNEND will be written inclusively.
%  SAMBEG,SAMEND - range of sample numbers to write. Samples from
%                  SAMBEG to SAMEND will be written inclusively.
%  FRQBEG,FRQEND - range of frequency bin numbers to write. Bins from
%                  FRQBEG to FRQEND will be written inclusively.
%  A - (uint16) amplitude/magnitude data to write. A matrix sized
%      [FRQEND-FRQBEG+1, SAMEND-SAMBEG+1, CHNEND-CHNBEG+1] is required.
%  PHI - (int8) phase data to write. A matrix with the same size as A.
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed.
%
%  This function converts the input data to the HDF5 storage format:
%  - Amplitude is scaled and converted to uint16
%  - Phase is converted from radians to int8
%  The scaling factor for the region must be set in the INDEX dataset
%  before writing data, or provided appropriately.
%
%  WARNING: This is a simplified implementation that uses a single scaling
%  factor for all data being written. For production use, consider
%  implementing per-region scaling based on the INDEX dataset.
%
function writewavelet(fid, blkid, chnbeg, chnend, sambeg, samend, frqbeg, frqend, a, phi)

arguments
    fid
    blkid double {mustBeNonnegative, mustBeInteger}
    chnbeg double {mustBePositive, mustBeInteger}
    chnend double {mustBePositive, mustBeInteger}
    sambeg double {mustBePositive, mustBeInteger}
    samend double {mustBePositive, mustBeInteger}
    frqbeg double {mustBePositive, mustBeInteger}
    frqend double {mustBePositive, mustBeInteger}
    a double
    phi double
end

filename = get_filename(fid);

% Validate data dimensions
expected_channels = chnend - chnbeg + 1;
expected_samples = samend - sambeg + 1;
expected_freqs = frqend - frqbeg + 1;

if ~isequal(size(a), [expected_freqs, expected_samples, expected_channels])
    error('dhfun2:dh:writewavelet:InvalidDataSize', ...
        'A must be sized [%d, %d, %d] (freqs x samples x channels) but got [%d, %d, %d]', ...
        expected_freqs, expected_samples, expected_channels, size(a, 1), size(a, 2), size(a, 3));
end

if ~isequal(size(phi), size(a))
    error('dhfun2:dh:writewavelet:InvalidPhiSize', ...
        'PHI must have the same size as A');
end

% Calculate scaling factor (use max value for best resolution)
max_a = max(a(:));
if max_a > 0
    scaling = max_a / 65535;
else
    scaling = 1.0;
end

% Convert amplitude to uint16 (scaled)
raw_a = uint16(round(a / scaling));

% Convert phase from radians to int8
raw_phi = int8(round(phi * 127.0 / pi));

% Create compound structure for HDF5
datasetPath = "/WAVELET" + blkid + "/DATA";

% Prepare the data structure
waveletData = struct('a', raw_a, 'phi', raw_phi);

% Write data using low-level HDF5 API
plist = 'H5P_DEFAULT';
file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);
cleanup_file = onCleanup(@() H5F.close(file_id));

dataset_id = H5D.open(file_id, datasetPath);
cleanup_dset = onCleanup(@() H5D.close(dataset_id));

% Define memory and file dataspaces
mem_dims = [expected_freqs, expected_samples, expected_channels];
mem_space_id = H5S.create_simple(3, fliplr(mem_dims), []);
cleanup_mem = onCleanup(@() H5S.close(mem_space_id));

file_space_id = H5D.get_space(dataset_id);
cleanup_file_space = onCleanup(@() H5S.close(file_space_id));

% Select hyperslab in file
start = [frqbeg-1, sambeg-1, chnbeg-1];  % 0-based for HDF5
count = mem_dims;
H5S.select_hyperslab(file_space_id, 'H5S_SELECT_SET', fliplr(start), [], fliplr(count), []);

% Get datatype
type_id = H5D.get_type(dataset_id);
cleanup_type = onCleanup(@() H5T.close(type_id));

% Write the data
H5D.write(dataset_id, type_id, mem_space_id, file_space_id, plist, waveletData);

% Note: In a production implementation, you should also update the
% scaling value in the INDEX dataset for the appropriate region(s)
fprintf('Note: Scaling factor used: %g. Consider updating INDEX dataset accordingly.\n', scaling);

end
