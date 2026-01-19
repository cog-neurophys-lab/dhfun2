%  dhfun(DH.WRITESPIKECLUSTER,FID,BLKID,RBEG,REND,CLUS)
%
%  Write spike cluster information
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike nTrode
%  RBEG,REND - range of record numbers to write. Records from
%              RBEG to REND will be written inclusively.
%  CLUS - Cluster number for each spike. Should be a column
%         vector of uint8, sized according to number of
%         records to write (REND-RBEG+1).
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed
%
%  Each spike is assigned a cluster number during spike sorting.
%  Up to 256 clusters are supported (0-255).
%
%  If the CLUSTER_INFO dataset does not exist in the SPIKE block,
%  this function will create it with the appropriate size based on
%  the number of spikes in the INDEX dataset.
%
function writespikecluster(fid, blkid, rbeg, rend, clus)

arguments
    fid
    blkid double {mustBeNonnegative, mustBeInteger}
    rbeg double {mustBePositive, mustBeInteger}
    rend double {mustBePositive, mustBeInteger}
    clus uint8
end

filename = get_filename(fid);

% Validate cluster dimensions
expected_length = rend - rbeg + 1;
actual_length = length(clus);

if actual_length ~= expected_length
    error('dhfun2:dh:writespikecluster:InvalidClusterLength', ...
        'Cluster length %d does not match expected length %d', ...
        actual_length, expected_length);
end

% Ensure clus is a column vector
if size(clus, 2) > 1
    clus = clus(:);
end

% Check if CLUSTER_INFO dataset exists, create if not
dataset_path = "/SPIKE" + blkid + "/CLUSTER_INFO";
try
    info = h5info(filename, dataset_path);
    % Dataset exists, write to it
    h5write(filename, dataset_path, clus, rbeg, expected_length);
catch
    % Dataset doesn't exist, create it
    % Get number of spikes from INDEX dataset
    index_info = h5info(filename, "/SPIKE" + blkid + "/INDEX");
    num_spikes = index_info.Dataspace.Size;

    % Create CLUSTER_INFO dataset
    plist = 'H5P_DEFAULT';
    file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);

    try
        group_id = H5G.open(file_id, "/SPIKE" + blkid);

        try
            % Create dataset
            cluster_space = H5S.create_simple(1, num_spikes, []);
            cluster_set = H5D.create(group_id, 'CLUSTER_INFO', 'H5T_NATIVE_UCHAR', cluster_space, plist, plist, plist);

            % Initialize with zeros
            if num_spikes > 0
                H5D.write(cluster_set, 'H5T_NATIVE_UCHAR', 'H5S_ALL', 'H5S_ALL', plist, zeros(num_spikes, 1, 'uint8'));
            end

            H5D.close(cluster_set);
            H5S.close(cluster_space);
        catch ME
            H5G.close(group_id);
            H5F.close(file_id);
            rethrow(ME);
        end

        H5G.close(group_id);
        H5F.close(file_id);

        % Now write the actual data
        h5write(filename, dataset_path, clus, rbeg, expected_length);
    catch ME
        H5F.close(file_id);
        rethrow(ME);
    end
end
