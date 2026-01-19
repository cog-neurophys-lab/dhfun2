% Manual test for dh.open interactive confirmation
% This test requires user interaction and cannot be automated
%
% Run this script manually to test the interactive confirmation feature

addpath('..')

test_filename = 'test_open_manual.dh5';

% Clean up any existing test file
if isfile(test_filename)
    delete(test_filename);
end

% Create a file first
fprintf('Creating initial test file...\n');
fid = dh.open(test_filename, 'w', 'forceDelete', true);
dh.close(fid);
fprintf('File created: %s\n\n', test_filename);

%% Test 1: User confirms deletion (type 'y')
fprintf('=== Test 1: Interactive confirmation - DELETE ===\n');
fprintf('When prompted, type "y" to confirm deletion.\n\n');

try
    fid = dh.open(test_filename, 'w'); % Should prompt
    dh.close(fid);
    fprintf('✓ File was overwritten successfully (user typed "y")\n\n');
catch ME
    fprintf('✗ Unexpected error: %s\n\n', ME.message);
end

%% Test 2: User cancels deletion (type 'n')
fprintf('=== Test 2: Interactive confirmation - CANCEL ===\n');
fprintf('When prompted, type "n" to cancel the operation.\n\n');

try
    fid = dh.open(test_filename, 'w'); % Should prompt
    dh.close(fid);
    fprintf('✗ File was overwritten (expected operation to be cancelled)\n\n');
catch ME
    if contains(ME.message, 'cancelled')
        fprintf('✓ Operation cancelled by user as expected\n\n');
    else
        fprintf('✗ Unexpected error: %s\n\n', ME.message);
    end
end

%% Test 3: Verify forceDelete bypasses prompt
fprintf('=== Test 3: forceDelete=true bypasses prompt ===\n');
try
    fid = dh.open(test_filename, 'w', 'forceDelete', true);
    dh.close(fid);
    fprintf('✓ File overwritten without prompt when forceDelete=true\n\n');
catch ME
    fprintf('✗ Unexpected error: %s\n\n', ME.message);
end

% Clean up
fprintf('Cleaning up...\n');
if isfile(test_filename)
    delete(test_filename);
end
fprintf('Manual test complete!\n');
