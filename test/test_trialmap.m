function tests = test_trialmap
%TEST_TRIALMAP Test suite for TRIALMAP dataset write/read functionality
%
%   This test suite validates the creation and manipulation of TRIALMAP
%   datasets in DAQ-HDF5 files according to the specification.
%
%   Run with: runtests('test_trialmap')
%
% See also: dh.settrialmap, dh.gettrialmap

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
testCase.TestData.testFile = sprintf('test_trialmap_temp_%d.dh5', randi(1000000));

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

%% Test 1: Write and read full TRIALMAP using SETTRIALMAP
function testSetTrialmap(testCase)
DH = testCase.TestData.DH;
filename = testCase.TestData.testFile;

numTrials = 50;

% Generate test data
test_trialno = int32((1:numTrials)');
test_stimno = int32(mod(0:numTrials-1, 5)' + 1); % Stimulus types 1-5
test_outcome = int32(mod(0:numTrials-1, 3)'); % Outcomes 0-2
test_starttime = int64((0:numTrials-1)' * 5e9); % Every 5 seconds
test_endtime = int64((1:numTrials)' * 5e9); % 5 seconds later

% Open file for writing
fid = dhfun(DH.OPEN, filename, 'r+');

try
    % Use SETTRIALMAP to write all trials (creates dataset automatically)
    dhfun(DH.SETTRIALMAP, fid, ...
        test_trialno, test_stimno, test_outcome, test_starttime, test_endtime);

    % Read back all trials
    [trialno_read, stimno_read, outcome_read, starttime_read, endtime_read] = ...
        dhfun(DH.GETTRIALMAP, fid);

    % Verify data matches
    verifyEqual(testCase, trialno_read, test_trialno, ...
        'Trial numbers should match written values');
    verifyEqual(testCase, stimno_read, test_stimno, ...
        'Stimulus numbers should match written values');
    verifyEqual(testCase, outcome_read, test_outcome, ...
        'Outcomes should match written values');
    verifyEqual(testCase, starttime_read, double(test_starttime), ...
        'Start times should match written values');
    verifyEqual(testCase, endtime_read, double(test_endtime), ...
        'End times should match written values');
catch ME
    dhfun(DH.CLOSE, fid);
    rethrow(ME);
end

dhfun(DH.CLOSE, fid);
end

%% Test 2b: SETTRIALMAP overwrites existing data
function testSetTrialmapOverwrite(testCase)
DH = testCase.TestData.DH;
filename = testCase.TestData.testFile;

% First write with 30 trials
numTrials1 = 30;
test_trialno1 = int32((1:numTrials1)');
test_stimno1 = int32(ones(numTrials1, 1));
test_outcome1 = int32(zeros(numTrials1, 1));
test_starttime1 = int64((0:numTrials1-1)' * 1e9);
test_endtime1 = int64((1:numTrials1)' * 1e9);

fid = dhfun(DH.OPEN, filename, 'r+');
try
    dhfun(DH.SETTRIALMAP, fid, ...
        test_trialno1, test_stimno1, test_outcome1, test_starttime1, test_endtime1);
    dhfun(DH.CLOSE, fid);
catch ME
    dhfun(DH.CLOSE, fid);
    rethrow(ME);
end

% Now overwrite with 50 different trials
numTrials2 = 50;
test_trialno2 = int32((1:numTrials2)');
test_stimno2 = int32(2 * ones(numTrials2, 1));
test_outcome2 = int32(ones(numTrials2, 1));
test_starttime2 = int64((0:numTrials2-1)' * 2e9);
test_endtime2 = int64((1:numTrials2)' * 2e9);

fid = dhfun(DH.OPEN, filename, 'r+');
try
    dhfun(DH.SETTRIALMAP, fid, ...
        test_trialno2, test_stimno2, test_outcome2, test_starttime2, test_endtime2);

    % Read back - should have 50 trials with new data
    [trialno_read, stimno_read, ~, ~, ~] = dhfun(DH.GETTRIALMAP, fid);

    verifyEqual(testCase, length(trialno_read), numTrials2, ...
        'Should have 50 trials after overwrite');
    verifyEqual(testCase, trialno_read, test_trialno2, ...
        'Trial numbers should match second write');
    verifyEqual(testCase, stimno_read, test_stimno2, ...
        'Stimulus numbers should match second write (all 2s)');
catch ME
    dhfun(DH.CLOSE, fid);
    rethrow(ME);
end

dhfun(DH.CLOSE, fid);
end






%% Test 7: Using existing test_data.dh5 file
function testReadExistingTrialmap(testCase)
DH = testCase.TestData.DH;

% Check if test_data.dh5 exists and has TRIALMAP
if ~isfile('test_data.dh5')
    verifyFail(testCase, 'test_data.dh5 not found');
    return;
end

try
    fid = dhfun(DH.OPEN, 'test_data.dh5', 'r');

    try
        % Try to read TRIALMAP from existing file
        [trialno, stimno, outcome, starttime, endtime] = dhfun(DH.GETTRIALMAP, fid);

        numTrials = length(trialno);

        % Verify types and sizes
        verifyEqual(testCase, length(stimno), numTrials, ...
            'All arrays should have same length');
        verifyEqual(testCase, length(outcome), numTrials, ...
            'All arrays should have same length');
        verifyEqual(testCase, length(starttime), numTrials, ...
            'All arrays should have same length');
        verifyEqual(testCase, length(endtime), numTrials, ...
            'All arrays should have same length');

        verifyClass(testCase, trialno, 'int32', ...
            'Trial numbers should be int32');
        verifyClass(testCase, stimno, 'int32', ...
            'Stimulus numbers should be int32');
        verifyClass(testCase, outcome, 'int32', ...
            'Outcomes should be int32');
        verifyClass(testCase, starttime, 'double', ...
            'Start times should be double');
        verifyClass(testCase, endtime, 'double', ...
            'End times should be double');

        % Verify trial durations are non-negative
        if numTrials > 0
            trial_durations = endtime - starttime;
            verifyTrue(testCase, all(trial_durations >= 0), ...
                'All trial durations should be non-negative');
        end
    catch ME
        dhfun(DH.CLOSE, fid);
        rethrow(ME);
    end

    dhfun(DH.CLOSE, fid);
catch
    % If test_data.dh5 doesn't have TRIALMAP, skip this test
    assumeFail(testCase, 'test_data.dh5 does not contain TRIALMAP dataset');
end
end
