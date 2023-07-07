addpath('..')

filename = 'test_data.dh5';

%% Test enumspikes
idSpike = dhfun.enumspike(filename);
assert(idSpike == 0)


%% Test enumcont
idCont = dhfun.enumcont(filename);
assert(isequal(idCont, [1, 1001, 60, 61, 62, 63, 64]))

%% Test readcontindex
[timeSelection, offsetSelection] = dhfun.readcontindex(filename, 1, 1, 5);

assert(isequal(size(timeSelection), [5, 1]))

[timeAll, offsetAll] = dhfun.readcontindex(filename, 1);


%% Test readcont
data = dhfun.readcont(filename, 1);
assert(isequal(data(1:5), int16([-348   -290   -201   -224   -289])));

%% Test getcontsize
[nSamples, nChannels] = dhfun.getcontsize(filename, 1);
assert(nSamples == 1443184);
assert(nChannels == 1);