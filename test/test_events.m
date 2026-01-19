function tests = test_events
%TEST_EVENTS Test suite for EV02 event trigger write/read functionality
%
%   This test suite validates the creation and manipulation of EV02
%   datasets in DAQ-HDF5 files according to the specification.
%
%   Run with: runtests('test_events')
%
% See also: dh.createev2, dh.writeev2, dh.readev2

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% Add parent directory to path
addpath('..');

% Store constants
testCase.TestData.DH = dh.constants();
end

function setup(testCase)
% Create a unique temporary test file for each test
testCase.TestData.testFile = sprintf('test_events_temp_%d.dh5', randi(1000000));

% Clean up any existing test file
if isfile(testCase.TestData.testFile)
    delete(testCase.TestData.testFile);
end

% Create a new minimal DH5 file
dh.createfile(testCase.TestData.testFile);
end

function teardown(testCase)
% Clean up test file after each test
if isfield(testCase.TestData, 'testFile') && isfile(testCase.TestData.testFile)
    delete(testCase.TestData.testFile);
end
end

%% Test 1: Create EV02 dataset
function testCreateEV02(testCase)
DH = testCase.TestData.DH;
filename = testCase.TestData.testFile;

numRecords = 100;

% Create EV02 dataset
dhfun(DH.CREATEEV2, filename, numRecords);

% Verify dataset was created by checking size
ev2size = dhfun(DH.GETEV2SIZE, filename);
verifyEqual(testCase, ev2size, numRecords, ...
    'EV02 dataset should have correct size');
end

%% Test 2: Write and read full EV02 dataset
function testWriteReadFullEV02(testCase)
DH = testCase.TestData.DH;
filename = testCase.TestData.testFile;

numRecords = 50;

% Create EV02 dataset
dhfun(DH.CREATEEV2, filename, numRecords);

% Generate test data
% Event times: 0s, 100ms, 200ms, ... (in nanoseconds)
test_times = int64((0:numRecords-1)' * 100000000);
% Event codes: alternating pattern
test_events = int32(mod(0:numRecords-1, 10)' + 1);

% Open file for writing
fid = dhfun(DH.OPEN, filename, 'r+');

try
    % Write all events
    dhfun(DH.WRITEEV2, fid, 1, numRecords, test_times, test_events);

    % Read back all events
    [times_read, events_read] = dhfun(DH.READEV2, fid);

    % Verify data matches
    verifyEqual(testCase, times_read, double(test_times), ...
        'Event times should match written values');
    verifyEqual(testCase, events_read, test_events, ...
        'Event codes should match written values');
catch ME
    dhfun(DH.CLOSE, fid);
    rethrow(ME);
end

dhfun(DH.CLOSE, fid);
end

%% Test 3: Write and read partial EV02 dataset
function testWriteReadPartialEV02(testCase)
DH = testCase.TestData.DH;
filename = testCase.TestData.testFile;

numRecords = 100;

% Create EV02 dataset
dhfun(DH.CREATEEV2, filename, numRecords);

% Open file for writing
fid = dhfun(DH.OPEN, filename, 'r+');

try
    % Write first batch (records 1-30)
    batch1_times = int64((0:29)' * 1000000); % 0-29ms
    batch1_events = int32((1:30)');
    dhfun(DH.WRITEEV2, fid, 1, 30, batch1_times, batch1_events);

    % Write second batch (records 31-70)
    batch2_times = int64((30:69)' * 1000000); % 30-69ms
    batch2_events = int32((31:70)');
    dhfun(DH.WRITEEV2, fid, 31, 70, batch2_times, batch2_events);

    % Write third batch (records 71-100)
    batch3_times = int64((70:99)' * 1000000); % 70-99ms
    batch3_events = int32((71:100)');
    dhfun(DH.WRITEEV2, fid, 71, 100, batch3_times, batch3_events);

    % Read back specific ranges and verify
    [times_read1, events_read1] = dhfun(DH.READEV2, fid, 1, 30);
    verifyEqual(testCase, times_read1, double(batch1_times), ...
        'First batch times should match');
    verifyEqual(testCase, events_read1, batch1_events, ...
        'First batch events should match');

    [times_read2, events_read2] = dhfun(DH.READEV2, fid, 31, 70);
    verifyEqual(testCase, times_read2, double(batch2_times), ...
        'Second batch times should match');
    verifyEqual(testCase, events_read2, batch2_events, ...
        'Second batch events should match');

    [times_read3, events_read3] = dhfun(DH.READEV2, fid, 71, 100);
    verifyEqual(testCase, times_read3, double(batch3_times), ...
        'Third batch times should match');
    verifyEqual(testCase, events_read3, batch3_events, ...
        'Third batch events should match');
catch ME
    dhfun(DH.CLOSE, fid);
    rethrow(ME);
end

dhfun(DH.CLOSE, fid);
end

%% Test 4: Write with double precision times (automatic conversion)
function testWriteEV02WithDoubleTimes(testCase)
DH = testCase.TestData.DH;
filename = testCase.TestData.testFile;

numRecords = 20;

% Create EV02 dataset
dhfun(DH.CREATEEV2, filename, numRecords);

% Generate test data with double precision times
test_times_double = (0:numRecords-1)' * 1e9; % 0s, 1s, 2s, ... in nanoseconds
test_events = int32((1:numRecords)');

% Open file for writing
fid = dhfun(DH.OPEN, filename, 'r+');

try
    % Write events (should auto-convert double to int64)
    dhfun(DH.WRITEEV2, fid, 1, numRecords, test_times_double, test_events);

    % Read back
    [times_read, events_read] = dhfun(DH.READEV2, fid);

    % Verify (allowing for precision loss in conversion)
    verifyEqual(testCase, times_read, test_times_double, ...
        'Event times should match within precision');
    verifyEqual(testCase, events_read, test_events, ...
        'Event codes should match');
catch ME
    dhfun(DH.CLOSE, fid);
    rethrow(ME);
end

dhfun(DH.CLOSE, fid);
end

%% Test 5: Error handling - mismatched array lengths
function testEV02ErrorHandling(testCase)
DH = testCase.TestData.DH;
filename = testCase.TestData.testFile;

numRecords = 50;

% Create EV02 dataset
dhfun(DH.CREATEEV2, filename, numRecords);

fid = dhfun(DH.OPEN, filename, 'r+');

try
    % Try to write with mismatched array lengths
    test_times = int64((1:10)');
    test_events = int32((1:15)'); % Different length!

    % This should throw an error
    verifyError(testCase, ...
        @() dhfun(DH.WRITEEV2, fid, 1, 10, test_times, test_events), ...
        'dhfun2:dh:writeev2:InvalidEventLength');
catch ME
    dhfun(DH.CLOSE, fid);
    rethrow(ME);
end

dhfun(DH.CLOSE, fid);
end

%% Test 6: Using existing test_data.dh5 file
function testReadExistingEV02(testCase)
DH = testCase.TestData.DH;

% Check if test_data.dh5 exists and has EV02
if ~isfile('test_data.dh5')
    verifyFail(testCase, 'test_data.dh5 not found');
    return;
end

try
    ev2size = dhfun(DH.GETEV2SIZE, 'test_data.dh5');

    if ev2size > 0
        % Read some events from existing file
        fid = dhfun(DH.OPEN, 'test_data.dh5', 'r');

        try
            % Read first 10 events (or all if less than 10)
            numToRead = min(10, ev2size);
            [times, events] = dhfun(DH.READEV2, fid, 1, numToRead);

            % Verify types and sizes
            verifyEqual(testCase, length(times), numToRead, ...
                'Should read correct number of time values');
            verifyEqual(testCase, length(events), numToRead, ...
                'Should read correct number of event values');
            verifyClass(testCase, times, 'double', ...
                'Times should be returned as double');
            verifyClass(testCase, events, 'int32', ...
                'Events should be returned as int32');
        catch ME
            dhfun(DH.CLOSE, fid);
            rethrow(ME);
        end

        dhfun(DH.CLOSE, fid);
    end
catch
    % If test_data.dh5 doesn't have EV02, skip this test
    assumeFail(testCase, 'test_data.dh5 does not contain EV02 dataset');
end
end
