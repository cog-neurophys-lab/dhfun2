function tests = test_open
%TEST_OPEN Test suite for dh.open with forceDelete functionality
%
%   This test suite validates the open function's ability to
%   create/open files and handle the forceDelete option.
%
%   Run with: runtests('test_open')
%
%   NOTE: Interactive confirmation prompt cannot be tested automatically.
%   Run manual_test_open_interactive.m to manually test the interactive confirmation.
%
% See also: dh.open, dh.close, manual_test_open_interactive

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% Add parent directory to path
addpath('..');
end

function setup(testCase)
% Create a unique temporary test file for each test
testCase.TestData.testFile = sprintf('test_open_temp_%d.dh5', randi(1000000));

% Clean up any existing test file
if isfile(testCase.TestData.testFile)
    delete(testCase.TestData.testFile);
end
end

function teardown(testCase)
% Clean up test file
if isfield(testCase.TestData, 'testFile') && isfile(testCase.TestData.testFile)
    delete(testCase.TestData.testFile);
end
end

function testOpenExistingFileForReading(testCase)
% Test opening an existing file for reading

fid = dh.open('test_data.dh5', 'r');
testCase.assertNotEmpty(fid, 'Failed to open file for reading');
dh.close(fid);
end

function testOpenExistingFileForUpdating(testCase)
% Test opening an existing file for updating

fid = dh.open('test_data.dh5', 'r+');
testCase.assertNotEmpty(fid, 'Failed to open file for updating');
dh.close(fid);
end

function testCreateNewFileWithForceDelete(testCase)
% Test creating a new file with forceDelete=true

fid = dh.open(testCase.TestData.testFile, 'w', 'forceDelete', true);
testCase.assertNotEmpty(fid, 'Failed to create new file');
dh.close(fid);

% Verify file exists
testCase.assertTrue(isfile(testCase.TestData.testFile), 'File was not created');
end

function testOverwriteExistingFileWithForceDelete(testCase)
% Test overwriting an existing file with forceDelete=true

% Create a file first
fid = dh.open(testCase.TestData.testFile, 'w', 'forceDelete', true);
dh.close(fid);

% Overwrite it without prompting
fid = dh.open(testCase.TestData.testFile, 'w', 'forceDelete', true);
testCase.assertNotEmpty(fid, 'Failed to overwrite file with forceDelete=true');
dh.close(fid);
end

function testCreateFileWithoutForceDeleteOnNonexistent(testCase)
% Test creating a file without forceDelete when file doesn't exist

% File doesn't exist, so no prompt should occur
fid = dh.open(testCase.TestData.testFile, 'w');
testCase.assertNotEmpty(fid, 'Failed to create file when it does not exist');
dh.close(fid);
end
