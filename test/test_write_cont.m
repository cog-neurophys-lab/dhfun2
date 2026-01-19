% Test script for CONT block writing functionality
% This tests createcont, writecont, setcontsampleperiod, setcontcalinfo, and writecontindex

addpath('..')

DH = dh.constants();

% Create a temporary test file
test_filename = 'test_write_cont_temp.dh5';

% Clean up any existing test file
if isfile(test_filename)
    delete(test_filename);
end

% Use onCleanup to ensure temp file is deleted even if tests fail
cleanup = onCleanup(@() cleanupTestFile(test_filename));

%% Test 1: Create new file with FILEVERSION attribute
fprintf('Test 1: Creating new DH5 file...\n');

dh.createfile(test_filename);

fprintf('  ✓ File created successfully\n');

%% Test 2: DH.CREATECONT
fprintf('\nTest 2: Testing DH.CREATECONT...\n');

blkid = 100;
nSamples = 2048;
nChannels = 4;
sampleperiod = 1000000; % 1ms in nanoseconds
indexsize = 3;

dhfun(DH.CREATECONT, test_filename, blkid, nSamples, nChannels, sampleperiod, indexsize);

% Verify the block was created
[samples_read, channels_read] = dhfun(DH.GETCONTSIZE, test_filename, blkid);
assert(samples_read == nSamples, 'Sample count mismatch');
assert(channels_read == nChannels, 'Channel count mismatch');
fprintf('  ✓ CONT block created with correct dimensions\n');

% Verify sample period
period_read = dhfun(DH.GETCONTSAMPLEPERIOD, test_filename, blkid);
assert(period_read == sampleperiod, 'Sample period mismatch');
fprintf('  ✓ Sample period set correctly\n');

% Verify index size
indexsize_read = dhfun(DH.GETCONTINDEXSIZE, test_filename, blkid);
assert(indexsize_read == indexsize, 'Index size mismatch');
fprintf('  ✓ Index size correct\n');

%% Test 3: DH.WRITECONT
fprintf('\nTest 3: Testing DH.WRITECONT...\n');

% Create test data [channels, samples] to match readcont format
test_data = int16(randi([-1000, 1000], nChannels, nSamples));

% Write all data
dhfun(DH.WRITECONT, test_filename, blkid, 1, nSamples, 1, nChannels, test_data);
fprintf('  ✓ Data written successfully\n');

% Read back and verify
data_read = dhfun(DH.READCONT, test_filename, blkid);
assert(isequal(data_read, test_data), 'Data mismatch after full write');
fprintf('  ✓ Full data read matches written data\n');

% Test partial write [channels, samples]
partial_data = int16(randi([-500, 500], 2, 100));
dhfun(DH.WRITECONT, test_filename, blkid, 500, 599, 2, 3, partial_data);

% Read back partial data
partial_read = dhfun(DH.READCONT, test_filename, blkid, 500, 599, 2, 3);
assert(isequal(partial_read, partial_data), 'Partial data mismatch');
fprintf('  ✓ Partial data write/read successful\n');

%% Test 4: DH.SETCONTSAMPLEPERIOD
fprintf('\nTest 4: Testing DH.SETCONTSAMPLEPERIOD...\n');

new_sampleperiod = 2000000; % 2ms
dhfun(DH.SETCONTSAMPLEPERIOD, test_filename, blkid, new_sampleperiod);

period_read = dhfun(DH.GETCONTSAMPLEPERIOD, test_filename, blkid);
assert(period_read == new_sampleperiod, 'Sample period not updated');
fprintf('  ✓ Sample period updated successfully\n');

%% Test 5: DH.SETCONTCALINFO
fprintf('\nTest 5: Testing DH.SETCONTCALINFO...\n');

calinfo = [0.001, 0.002, 0.0015, 0.0018]';
dhfun(DH.SETCONTCALINFO, test_filename, blkid, calinfo);

calinfo_read = dhfun(DH.GETCONTCALINFO, test_filename, blkid);
assert(all(abs(calinfo_read - calinfo) < 1e-10), 'Calibration info mismatch');
fprintf('  ✓ Calibration info set successfully\n');

%% Test 6: DH.WRITECONTINDEX
fprintf('\nTest 6: Testing DH.WRITECONTINDEX...\n');

% Create test index data
index_times = int64([0; 1000000000; 2000000000]); % 0s, 1s, 2s
index_offsets = int64([1; 1000; 1500]); % 1-based offsets

dhfun(DH.WRITECONTINDEX, test_filename, blkid, 1, 3, index_times, index_offsets);

% Read back index
[times_read, offsets_read] = dhfun(DH.READCONTINDEX, test_filename, blkid, 1, 3);
assert(isequal(times_read, index_times), 'Index times mismatch');
assert(isequal(offsets_read, index_offsets), 'Index offsets mismatch');
fprintf('  ✓ Index data written and read successfully\n');

% Test partial index write
dhfun(DH.WRITECONTINDEX, test_filename, blkid, 2, 2, int64(5000000000), int64(2000));
[time_partial, offset_partial] = dhfun(DH.READCONTINDEX, test_filename, blkid, 2, 2);
assert(time_partial == 5000000000, 'Partial index time mismatch');
assert(offset_partial == 2000, 'Partial index offset mismatch');
fprintf('  ✓ Partial index write successful\n');

%% Test 7: Error handling - duplicate CONT block
fprintf('\nTest 7: Testing error handling...\n');

try
    dhfun(DH.CREATECONT, test_filename, blkid, 100, 2, 1000000, 1);
    error('Should have thrown error for duplicate CONT block');
catch ME
    assert(contains(ME.identifier, 'BlockExists'), 'Wrong error for duplicate block');
    fprintf('  ✓ Duplicate block creation properly rejected\n');
end

%% Test 8: Data dimension validation
fprintf('\nTest 8: Testing data validation...\n');

try
    wrong_data = int16(rand(2, 50)); % Wrong dimensions (expecting 100 samples)
    dhfun(DH.WRITECONT, test_filename, blkid, 1, 100, 1, 2, wrong_data);
    error('Should have thrown error for wrong data dimensions');
catch ME
    assert(contains(ME.identifier, 'InvalidDataSize'), 'Wrong error for invalid data size');
    fprintf('  ✓ Invalid data dimensions properly rejected\n');
end

%% Test 9: Calibration info length validation
fprintf('\nTest 9: Testing calibration validation...\n');

try
    wrong_calinfo = [0.001, 0.002]; % Wrong length
    dhfun(DH.SETCONTCALINFO, test_filename, blkid, wrong_calinfo);
    error('Should have thrown error for wrong calinfo length');
catch ME
    assert(contains(ME.identifier, 'InvalidLength'), 'Wrong error for invalid calinfo length');
    fprintf('  ✓ Invalid calibration length properly rejected\n');
end

%% Test 10: Create second CONT block
fprintf('\nTest 10: Testing multiple CONT blocks...\n');

blkid2 = 200;
dhfun(DH.CREATECONT, test_filename, blkid2, 1024, 2, 500000, 1);

% Verify both blocks exist
cont_list = dhfun(DH.ENUMCONT, test_filename);
assert(ismember(blkid, cont_list), 'First CONT block not found');
assert(ismember(blkid2, cont_list), 'Second CONT block not found');
fprintf('  ✓ Multiple CONT blocks created successfully\n');

%% Summary
fprintf('\n');
fprintf('=================================\n');
fprintf('All tests passed successfully! ✓\n');
fprintf('=================================\n');

%% Helper function for cleanup
function cleanupTestFile(filename)
if isfile(filename)
    delete(filename);
    fprintf('\nCleaned up test file.\n');
end
end
