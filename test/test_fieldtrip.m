try 
    ft_defaults
    fieldtripIsAvailable = true;
catch 
    fieldtripIsAvailable = false;
end

addpath('..')
filename = 'test_data.dh5';

%% test read_header
header = dh.ft_read_header(filename);
assert(isequal(header, daq_hdf5(filename)));
assert(header.nTrials == 385);
assert(header.Fs == 1000.0);
assert(length(header.label) == 7);
assert(length(header.label) == length(header.chanunit));
assert(length(header.label) == length(header.chantype));

%% test read_events


%% test read_data


