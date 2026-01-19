%% Test SPIKE write functions for dhfun2
% This script tests the implementation of:
% - DH.CREATESPIKE
% - DH.WRITESPIKE
% - DH.WRITESPIKEINDEX
% - DH.WRITESPIKECLUSTER

function tests = test_spike_write
% Add parent directory to path
testDir = fileparts(mfilename('fullpath'));
addpath(fullfile(testDir, '..'));

tests = functiontests(localfunctions);
end

%% Test creating a new SPIKE block
function testCreateSpike(testCase)
% Create a temporary test file
testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));

% Create a new file
fid = dh.open(testFile, 'w');

% Define SPIKE block parameters
blkid = 1;
spikes = 100;
channels = 4;
sampleperiod = 40000; % 40 microseconds = 25 kHz
spikesamples = 32;
pretrigsamples = 8;
lockoutsamples = 16;

% Create SPIKE block
dh.createspike(fid, blkid, spikes, channels, sampleperiod, ...
    spikesamples, pretrigsamples, lockoutsamples);

dh.close(fid);

% Verify the block was created correctly
info = h5info(testFile, '/SPIKE1');
testCase.verifyEqual(length(info.Datasets), 2); % DATA and INDEX

% Check DATA dataset
data_info = info.Datasets(strcmp({info.Datasets.Name}, 'DATA'));
% HDF5 stores as [channels x total_samples] due to transpose
testCase.verifyEqual(data_info.Dataspace.Size, [channels, spikes * spikesamples]);

% Check INDEX dataset
index_info = info.Datasets(strcmp({info.Datasets.Name}, 'INDEX'));
testCase.verifyEqual(index_info.Dataspace.Size, spikes);

% Check attributes
testCase.verifyEqual(length(info.Attributes), 3); % SamplePeriod, SpikeParams, Channels

% Read and verify SamplePeriod
sp = h5readatt(testFile, '/SPIKE1', 'SamplePeriod');
testCase.verifyEqual(sp, int32(sampleperiod));

% Read and verify SpikeParams
params = h5readatt(testFile, '/SPIKE1', 'SpikeParams');
testCase.verifyEqual(params.spikeSamples, int16(spikesamples));
testCase.verifyEqual(params.preTrigSamples, int16(pretrigsamples));
testCase.verifyEqual(params.lockOutSamples, int16(lockoutsamples));
end

%% Test creating SPIKE block with existing block ID fails
function testCreateSpikeExistingBlock(testCase)
testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));

fid = dh.open(testFile, 'w');

% Create first SPIKE block
dh.createspike(fid, 1, 10, 1, 40000, 32, 8, 16);

% Try to create another with same ID - should fail
testCase.verifyError(@() dh.createspike(fid, 1, 20, 2, 40000, 32, 8, 16), ...
    'dhfun2:dh:createspike:BlockExists');

dh.close(fid);
end

%% Test writing spike waveform data
function testWriteSpike(testCase)
testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));

fid = dh.open(testFile, 'w');

% Create SPIKE block
blkid = 2;
spikes = 50;
channels = 2;
spikesamples = 32;
dh.createspike(fid, blkid, spikes, channels, 40000, spikesamples, 8, 16);

% Generate test data for first 10 spikes
num_spikes_to_write = 10;
test_data = int16(randi([-1000, 1000], spikesamples * num_spikes_to_write, channels));

% Write data
sambeg = 1;
samend = spikesamples * num_spikes_to_write;
chnbeg = 1;
chnend = channels;

dh.writespike(fid, blkid, sambeg, samend, chnbeg, chnend, test_data);

dh.close(fid);

% Read back and verify
fid = dh.open(testFile, 'r');
read_data = dh.readspike(fid, blkid, sambeg, samend, chnbeg, chnend);
dh.close(fid);

testCase.verifyEqual(read_data, test_data);
end

%% Test writing spike waveform data with wrong dimensions fails
function testWriteSpikeInvalidDimensions(testCase)
testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));

fid = dh.open(testFile, 'w');

dh.createspike(fid, 3, 10, 2, 40000, 32, 8, 16);

% Try to write data with wrong dimensions
wrong_data = int16(randi([-1000, 1000], 100, 3)); % 3 channels instead of 2

testCase.verifyError(@() dh.writespike(fid, 3, 1, 100, 1, 2, wrong_data), ...
    'dhfun2:dh:writespike:InvalidDataSize');

dh.close(fid);
end

%% Test writing spike index (timestamps)
function testWriteSpikeIndex(testCase)
testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));

fid = dh.open(testFile, 'w');

% Create SPIKE block
blkid = 4;
spikes = 100;
dh.createspike(fid, blkid, spikes, 1, 40000, 32, 8, 16);

% Generate test timestamps (in nanoseconds)
test_times = int64(sort(randi([0, 1e12], spikes, 1)));

% Write timestamps
dh.writespikeindex(fid, blkid, 1, spikes, test_times);

dh.close(fid);

% Read back and verify
fid = dh.open(testFile, 'r');
read_times = dh.readspikeindex(fid, blkid, 1, spikes);
dh.close(fid);

testCase.verifyEqual(read_times, double(test_times));
end

%% Test writing partial spike index
function testWriteSpikeIndexPartial(testCase)
testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));

fid = dh.open(testFile, 'w');

blkid = 5;
spikes = 100;
dh.createspike(fid, blkid, spikes, 1, 40000, 32, 8, 16);

% Write timestamps for spikes 21-30
rbeg = 21;
rend = 30;
partial_times = int64(sort(randi([0, 1e12], rend - rbeg + 1, 1)));

dh.writespikeindex(fid, blkid, rbeg, rend, partial_times);

dh.close(fid);

% Read back and verify
fid = dh.open(testFile, 'r');
read_times = dh.readspikeindex(fid, blkid, rbeg, rend);
dh.close(fid);

testCase.verifyEqual(read_times, double(partial_times));
end

%% Test writing spike cluster information
function testWriteSpikeCluster(testCase)
testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));

fid = dh.open(testFile, 'w');

% Create SPIKE block
blkid = 6;
spikes = 200;
dh.createspike(fid, blkid, spikes, 1, 40000, 32, 8, 16);

% Generate test cluster assignments (0-4 = 5 clusters)
test_clusters = uint8(randi([0, 4], spikes, 1));

% Write cluster info
dh.writespikecluster(fid, blkid, 1, spikes, test_clusters);

dh.close(fid);

% Read back and verify
fid = dh.open(testFile, 'r');
read_clusters = dh.readspikecluster(fid, blkid, 1, spikes);
dh.close(fid);

testCase.verifyEqual(read_clusters, double(test_clusters));

% Verify CLUSTER_INFO dataset was created
info = h5info(testFile, '/SPIKE6');
cluster_dataset = info.Datasets(strcmp({info.Datasets.Name}, 'CLUSTER_INFO'));
testCase.verifyNotEmpty(cluster_dataset);
testCase.verifyEqual(cluster_dataset.Dataspace.Size, spikes);
end

%% Test writing partial cluster information
function testWriteSpikeClusterPartial(testCase)
testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));

fid = dh.open(testFile, 'w');

blkid = 7;
spikes = 100;
dh.createspike(fid, blkid, spikes, 1, 40000, 32, 8, 16);

% Write cluster info for spikes 11-20
rbeg = 11;
rend = 20;
partial_clusters = uint8(randi([0, 3], rend - rbeg + 1, 1));

dh.writespikecluster(fid, blkid, rbeg, rend, partial_clusters);

dh.close(fid);

% Read back and verify
fid = dh.open(testFile, 'r');
read_clusters = dh.readspikecluster(fid, blkid, rbeg, rend);
dh.close(fid);

testCase.verifyEqual(read_clusters, double(partial_clusters));
end

%% Test complete workflow: create, write all data, read back
function testCompleteWorkflow(testCase)
testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));

fid = dh.open(testFile, 'w');

% Parameters
blkid = 10;
spikes = 50;
channels = 3;
sampleperiod = 40000;
spikesamples = 32;
pretrigsamples = 8;
lockoutsamples = 16;

% Create SPIKE block
dh.createspike(fid, blkid, spikes, channels, sampleperiod, ...
    spikesamples, pretrigsamples, lockoutsamples);

% Generate and write spike waveforms
total_samples = spikes * spikesamples;
spike_data = int16(randi([-5000, 5000], total_samples, channels));
dh.writespike(fid, blkid, 1, total_samples, 1, channels, spike_data);

% Generate and write timestamps
spike_times = int64(sort(randi([0, 1e12], spikes, 1)));
dh.writespikeindex(fid, blkid, 1, spikes, spike_times);

% Generate and write cluster assignments
spike_clusters = uint8(randi([0, 2], spikes, 1));
dh.writespikecluster(fid, blkid, 1, spikes, spike_clusters);

dh.close(fid);

% Read everything back and verify
fid = dh.open(testFile, 'r');

% Verify parameters
[total, pretrig, lockout] = dh.getspikeparams(fid, blkid);
testCase.verifyEqual(total, spikesamples);
testCase.verifyEqual(pretrig, pretrigsamples);
testCase.verifyEqual(lockout, lockoutsamples);

% Verify data
read_data = dh.readspike(fid, blkid, 1, total_samples, 1, channels);
testCase.verifyEqual(read_data, spike_data);

% Verify timestamps
read_times = dh.readspikeindex(fid, blkid, 1, spikes);
testCase.verifyEqual(read_times, double(spike_times));

% Verify clusters
read_clusters = dh.readspikecluster(fid, blkid, 1, spikes);
testCase.verifyEqual(read_clusters, double(spike_clusters));

% Verify cluster info presence
has_cluster = dh.isclusterinfo_present(fid, blkid);
testCase.verifyTrue(has_cluster);

dh.close(fid);
end

%% Test using existing test_data.dh5 file
function testReadExistingSpike(testCase)
% Use the existing test_data.dh5 file
testFile = 'test_data.dh5';

% Skip if file doesn't exist
if ~isfile(testFile)
    warning('test_data.dh5 not found, skipping test');
    return;
end

fid = dh.open(testFile, 'r');

% Test reading from SPIKE0 block
blkid = 0;

% Get spike parameters
[total, pretrig, lockout] = dh.getspikeparams(fid, blkid);
testCase.verifyGreaterThan(total, 0);

% Get number of spikes
num_spikes = dh.getnumberspikes(fid, blkid);
testCase.verifyEqual(num_spikes, 44366);

% Read first 10 spike waveforms
if num_spikes >= 10
    nchannels = dh.getspikesize(fid, blkid);
    spike_data = dh.readspike(fid, blkid, 1, total * 10, 1, nchannels);
    testCase.verifyEqual(size(spike_data, 1), total * 10);
    testCase.verifyEqual(size(spike_data, 2), nchannels);
end

% Read first 100 timestamps
if num_spikes >= 100
    times = dh.readspikeindex(fid, blkid, 1, 100);
    testCase.verifyEqual(length(times), 100);
    % Verify timestamps are in ascending order (they should be)
    testCase.verifyTrue(issorted(times));
end

% Check if cluster info exists and read it
if dh.isclusterinfo_present(fid, blkid)
    clusters = dh.readspikecluster(fid, blkid, 1, 100);
    testCase.verifyEqual(length(clusters), 100);
    % Cluster values should be >= 0
    testCase.verifyTrue(all(clusters >= 0));
end

dh.close(fid);
end

%% Test modifying existing SPIKE block
function testModifyExistingSpike(testCase)
% Create a copy of test_data.dh5 if it exists
sourceFile = 'test_data.dh5';

if ~isfile(sourceFile)
    warning('test_data.dh5 not found, skipping test');
    return;
end

testFile = tempname + ".dh5";
cleanup = onCleanup(@() delete(testFile));
copyfile(sourceFile, testFile);

% Open for modification
fid = dh.open(testFile, 'r+');

blkid = 0;

% Modify cluster assignments for spikes 1-10
new_clusters = uint8([1, 1, 2, 2, 1, 3, 3, 2, 1, 3]');
dh.writespikecluster(fid, blkid, 1, 10, new_clusters);

dh.close(fid);

% Read back and verify changes
fid = dh.open(testFile, 'r');
read_clusters = dh.readspikecluster(fid, blkid, 1, 10);
dh.close(fid);

testCase.verifyEqual(read_clusters, double(new_clusters));
end
