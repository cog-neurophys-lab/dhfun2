% Test script for operation-related functions
% Tests: dh.createoperation and dh.getoperationinfos

addpath('..')

DH = dh.constants();

% Create a temporary test file
test_filename = 'test_createoperation_temp.dh5';

% Clean up any existing test file
if isfile(test_filename)
    delete(test_filename);
end

% Use onCleanup to ensure temp file is deleted even if tests fail
cleanup = onCleanup(@() cleanupTestFile(test_filename));

%% Test 1: Create minimal file
fprintf('Test 1: Creating minimal DH5 file...\n');
create_minimal_dh5(test_filename);

% Verify initial operation
[opnames, opinfos] = dhfun(DH.GETOPERATIONINFOS, test_filename);
assert(length(opnames) == 1, 'Should have 1 operation');
assert(strcmp(opnames{1}, 'FileCreation'), 'First operation should be FileCreation');
assert(strcmp(opinfos{1}.Tool, 'create_minimal_dh5'), 'Tool mismatch');
fprintf('  ✓ Initial operation created successfully\n');

%% Test 2: Add operation with default parameters
fprintf('\nTest 2: Adding operation with default parameters...\n');
dh.createoperation(test_filename, 'TestOperation1');

[opnames, opinfos] = dhfun(DH.GETOPERATIONINFOS, test_filename);
assert(length(opnames) == 2, 'Should have 2 operations');
assert(strcmp(opnames{2}, 'TestOperation1'), 'Second operation name mismatch');
assert(strcmp(opinfos{2}.Tool, 'MATLAB'), 'Default tool should be MATLAB');
assert(~isempty(opinfos{2}.Operator_name), 'Operator name should not be empty');
assert(isfield(opinfos{2}, 'Date'), 'Date field should exist');
fprintf('  ✓ Operation with defaults created successfully\n');

%% Test 3: Add operation with custom Tool and Operator
fprintf('\nTest 3: Adding operation with custom Tool and Operator...\n');
dh.createoperation(test_filename, 'FilterData', ...
    'Tool', 'FilterToolbox v2.1', ...
    'Operator', 'TestUser');

[opnames, opinfos] = dhfun(DH.GETOPERATIONINFOS, test_filename);
assert(length(opnames) == 3, 'Should have 3 operations');
assert(strcmp(opnames{3}, 'FilterData'), 'Third operation name mismatch');
assert(strcmp(opinfos{3}.Tool, 'FilterToolbox v2.1'), 'Custom tool mismatch');
assert(strcmp(opinfos{3}.Operator_name, 'TestUser'), 'Custom operator mismatch');
fprintf('  ✓ Operation with custom parameters created successfully\n');

%% Test 4: Add operation with additional custom attributes
fprintf('\nTest 4: Adding operation with custom attributes...\n');
dh.createoperation(test_filename, 'Processing', ...
    'Tool', 'CustomProcessor v1.0', ...
    'FilterType', 'Butterworth', ...
    'Cutoff', '100 Hz', ...
    'Order', '4');

% Verify the operation was added
[opnames, opinfos] = dhfun(DH.GETOPERATIONINFOS, test_filename);
assert(length(opnames) == 4, 'Should have 4 operations');
assert(strcmp(opnames{4}, 'Processing'), 'Fourth operation name mismatch');

% Verify custom attributes exist (check via h5info since they may not appear in dhfun output)
info = h5info(test_filename, '/Operations/003_Processing');
attr_names = {info.Attributes.Name};
assert(any(strcmp(attr_names, 'FilterType')), 'FilterType attribute missing');
assert(any(strcmp(attr_names, 'Cutoff')), 'Cutoff attribute missing');
assert(any(strcmp(attr_names, 'Order')), 'Order attribute missing');

% Read custom attributes
filter_type = h5readatt(test_filename, '/Operations/003_Processing', 'FilterType');
assert(strcmp(filter_type, 'Butterworth'), 'FilterType value mismatch');
fprintf('  ✓ Operation with custom attributes created successfully\n');

%% Test 5: Verify operation numbering
fprintf('\nTest 5: Verifying operation numbering...\n');
info = h5info(test_filename, '/Operations');
group_names = {info.Groups.Name};

% Check that operations are numbered sequentially
expected_names = {'/Operations/000_FileCreation', ...
    '/Operations/001_TestOperation1', ...
    '/Operations/002_FilterData', ...
    '/Operations/003_Processing'};

for i = 1:length(expected_names)
    assert(any(strcmp(group_names, expected_names{i})), ...
        sprintf('Expected operation %s not found', expected_names{i}));
end
fprintf('  ✓ Operations numbered correctly\n');

%% Test 6: Verify Date structure
fprintf('\nTest 6: Verifying Date attribute structure...\n');
[~, opinfos] = dhfun(DH.GETOPERATIONINFOS, test_filename);
date = opinfos{1}.Date;
assert(isfield(date, 'Year'), 'Date missing Year field');
assert(isfield(date, 'Month'), 'Date missing Month field');
assert(isfield(date, 'Day'), 'Date missing Day field');
assert(isfield(date, 'Hour'), 'Date missing Hour field');
assert(isfield(date, 'Minute'), 'Date missing Minute field');
assert(isfield(date, 'Second'), 'Date missing Second field');
assert(date.Year >= 2026, 'Year should be 2026 or later');
assert(date.Month >= 1 && date.Month <= 12, 'Month out of range');
assert(date.Day >= 1 && date.Day <= 31, 'Day out of range');
fprintf('  ✓ Date structure valid\n');

%% Summary
fprintf('\n=================================\n');
fprintf('All tests passed! ✓\n');
fprintf('=================================\n');

%% Test 7: Test getoperationinfos with existing file
fprintf('\nTest 7: Testing dh.getoperationinfos with existing file...\n');
[opnames_existing, opinfos_existing] = dhfun(DH.GETOPERATIONINFOS, '../test/test_data.dh5');
assert(~isempty(opnames_existing), 'Should have operations in test_data.dh5');
assert(length(opnames_existing) == length(opinfos_existing), 'Opnames and opinfos should have same length');

% Verify first operation is 'Recording'
assert(strcmp(opnames_existing{1}, 'Recording'), 'First operation should be Recording');
assert(isfield(opinfos_existing{1}, 'Date'), 'Should have Date field');
assert(isfield(opinfos_existing{1}, 'Operator_name'), 'Should have Operator_name field');

% Verify Date structure
date = opinfos_existing{1}.Date;
assert(isstruct(date), 'Date should be a struct');
assert(isfield(date, 'Year'), 'Date should have Year');
assert(isfield(date, 'Month'), 'Date should have Month');
fprintf('  ✓ getoperationinfos works with existing file\n');

%% Test 8: Test getoperationinfos returns operations in order
fprintf('\nTest 8: Testing operation order...\n');
% The test file has 4 operations numbered 000-003
[opnames_test, ~] = dhfun(DH.GETOPERATIONINFOS, test_filename);
assert(strcmp(opnames_test{1}, 'FileCreation'), 'First should be FileCreation');
assert(strcmp(opnames_test{2}, 'TestOperation1'), 'Second should be TestOperation1');
assert(strcmp(opnames_test{3}, 'FilterData'), 'Third should be FilterData');
assert(strcmp(opnames_test{4}, 'Processing'), 'Fourth should be Processing');
fprintf('  ✓ Operations returned in correct order\n');

%% Test 9: Test getoperationinfos with file containing special characters in attributes
fprintf('\nTest 9: Testing attribute name handling...\n');
% Verify that attribute names with spaces are converted to underscores
assert(isfield(opinfos_existing{1}, 'Operator_name'), 'Space should be converted to underscore');
assert(isfield(opinfos_existing{1}, 'Subject_name'), 'Space should be converted to underscore');
fprintf('  ✓ Attribute names with spaces handled correctly\n');

%% Test 10: Test getoperationinfos with empty operations group
fprintf('\nTest 10: Testing with file with no operations...\n');
% Create a minimal file without operations
temp_no_ops = 'test_no_ops_temp.dh5';
fid_temp = H5F.create(temp_no_ops, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
attr_space = H5S.create('H5S_SCALAR');
attr = H5A.create(fid_temp, 'FILEVERSION', 'H5T_NATIVE_INT', attr_space, 'H5P_DEFAULT');
H5A.write(attr, 'H5ML_DEFAULT', int32(2));
H5A.close(attr);
H5S.close(attr_space);
H5G.create(fid_temp, '/Operations', 'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');
H5F.close(fid_temp);

[opnames_empty, opinfos_empty] = dhfun(DH.GETOPERATIONINFOS, temp_no_ops);
assert(isempty(opnames_empty), 'Should have no operations');
assert(isempty(opinfos_empty), 'Should have no operation infos');
delete(temp_no_ops);
fprintf('  ✓ Empty operations group handled correctly\n');

%% Final Summary
fprintf('\n=================================\n');
fprintf('All operation tests passed! ✓\n');
fprintf('=================================\n');

%% Helper function
function cleanupTestFile(filename)
if isfile(filename)
    delete(filename);
end
end
