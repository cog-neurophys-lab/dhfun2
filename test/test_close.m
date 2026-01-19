function tests = test_close
%TEST_CLOSE Test suite for dh.close with operation logging
%
%   This test suite validates the close function's ability to
%   add operation entries when closing files.
%
%   Run with: runtests('test_close')
%
% See also: dh.close, dh.createoperation, dh.getoperationinfos

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% Add parent directory to path
addpath('..');
end

function setup(testCase)
% Create a unique temporary test file for each test
testCase.TestData.testFile = sprintf('test_close_temp_%d.dh5', randi(1000000));

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

%% Test 1: Close without operation (basic close)
function testCloseWithoutOperation(testCase)
filename = testCase.TestData.testFile;

% Open file
fid = dh.open(filename, 'r+');

% Close without adding operation
dh.close(fid);

% Verify file is closed by checking we can open it again
fid2 = dh.open(filename, 'r');
dh.close(fid2);
end

%% Test 2: Close with operation name only
function testCloseWithOperationName(testCase)
filename = testCase.TestData.testFile;

% Open file
fid = dh.open(filename, 'r+');

% Close with operation name
dh.close(fid, 'TestOperation');

% Read back operations
[opnames, opinfos] = dh.getoperationinfos(filename);

% Find our operation (should be the last one, after 'FileCreation')
foundOp = false;
for i = 1:length(opnames)
    if strcmp(opnames{i}, 'TestOperation')
        foundOp = true;
        % Verify default tool is MATLAB
        verifyEqual(testCase, opinfos{i}.Tool, 'MATLAB');
        % Verify operator is set (should be USERNAME)
        verifyTrue(testCase, isfield(opinfos{i}, 'Operator_name'));
        % Verify date is present
        verifyTrue(testCase, isfield(opinfos{i}, 'Date'));
    end
end
verifyTrue(testCase, foundOp, 'Operation not found in file');
end

%% Test 3: Close with operation name and operator
function testCloseWithOperatorName(testCase)
filename = testCase.TestData.testFile;

% Open file
fid = dh.open(filename, 'r+');

% Close with operation name and operator
dh.close(fid, 'DataProcessing', 'TestOperator');

% Read back operations
[opnames, opinfos] = dh.getoperationinfos(filename);

% Find our operation
foundOp = false;
for i = 1:length(opnames)
    if strcmp(opnames{i}, 'DataProcessing')
        foundOp = true;
        verifyEqual(testCase, opinfos{i}.Operator_name, 'TestOperator');
    end
end
verifyTrue(testCase, foundOp, 'Operation not found in file');
end

%% Test 4: Close with operation name, operator, and tool
function testCloseWithToolName(testCase)
filename = testCase.TestData.testFile;

% Open file
fid = dh.open(filename, 'r+');

% Close with operation name, operator, and tool
dh.close(fid, 'Filtering', 'JohnDoe', 'FilterTool v2.0');

% Read back operations
[opnames, opinfos] = dh.getoperationinfos(filename);

% Find our operation
foundOp = false;
for i = 1:length(opnames)
    if strcmp(opnames{i}, 'Filtering')
        foundOp = true;
        verifyEqual(testCase, opinfos{i}.Operator_name, 'JohnDoe');
        verifyEqual(testCase, opinfos{i}.Tool, 'FilterTool v2.0');
    end
end
verifyTrue(testCase, foundOp, 'Operation not found in file');
end

%% Test 5: Close with operation info struct
function testCloseWithOperationInfo(testCase)
filename = testCase.TestData.testFile;

% Open file
fid = dh.open(filename, 'r+');

% Create operation info struct
opinfo = struct();
opinfo.FilterType = 'Butterworth';
opinfo.Cutoff = '100 Hz';
opinfo.Order = '4';

% Close with full parameters
dh.close(fid, 'Filtering', 'TestUser', 'MyFilter v1.0', opinfo);

% Read back operations
[opnames, opinfos] = dh.getoperationinfos(filename);

% Find our operation
foundOp = false;
for i = 1:length(opnames)
    if strcmp(opnames{i}, 'Filtering')
        foundOp = true;
        verifyEqual(testCase, opinfos{i}.Operator_name, 'TestUser');
        verifyEqual(testCase, opinfos{i}.Tool, 'MyFilter v1.0');
        verifyEqual(testCase, opinfos{i}.FilterType, 'Butterworth');
        verifyEqual(testCase, opinfos{i}.Cutoff, '100 Hz');
        verifyEqual(testCase, opinfos{i}.Order, '4');
    end
end
verifyTrue(testCase, foundOp, 'Operation not found in file');
end

%% Test 6: Multiple operations via multiple open/close cycles
function testMultipleOperations(testCase)
filename = testCase.TestData.testFile;

% First operation
fid = dh.open(filename, 'r+');
dh.close(fid, 'Operation1');

% Second operation
fid = dh.open(filename, 'r+');
dh.close(fid, 'Operation2');

% Third operation
fid = dh.open(filename, 'r+');
dh.close(fid, 'Operation3');

% Read back operations
[opnames, ~] = dh.getoperationinfos(filename);

% Count our operations (plus the initial FileCreation)
opCount = sum(contains(opnames, 'Operation'));
verifyEqual(testCase, opCount, 3, 'Should have 3 operations');
end

%% Test 7: Close with empty operator/tool (should use defaults)
function testCloseWithEmptyParameters(testCase)
filename = testCase.TestData.testFile;

% Open file
fid = dh.open(filename, 'r+');

% Close with empty operator and tool
dh.close(fid, 'TestOp', [], []);

% Read back operations
[opnames, opinfos] = dh.getoperationinfos(filename);

% Find our operation
foundOp = false;
for i = 1:length(opnames)
    if strcmp(opnames{i}, 'TestOp')
        foundOp = true;
        % Should use defaults
        verifyEqual(testCase, opinfos{i}.Tool, 'MATLAB');
        verifyTrue(testCase, isfield(opinfos{i}, 'Operator_name'));
    end
end
verifyTrue(testCase, foundOp, 'Operation not found in file');
end
