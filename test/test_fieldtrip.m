addpath('..')

filename = 'test_data.dh5';


%% test read_cont_as_ft
data = dh.read_cont_as_ft(filename, 1);
assert(isfield(data, 'hdr'))
assert(isfield(data, 'trial'))
assert(isfield(data, 'time'))
assert(isfield(data, 'label'))