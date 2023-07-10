addpath('..')

filename = 'test_data.dh5';
DH = dh.constants();

%% Test open
fid = dh.open(filename, 'r');

%% Test enumspikes
idSpike = dhfun(DH.ENUMSPIKE, filename);
assert(idSpike == 0)

%% Test enumcont
idCont = dhfun(DH.ENUMCONT, filename);
assert(isequal(idCont, [1, 1001, 60, 61, 62, 63, 64]))

%% Test readcontindex
[timeSelection, offsetSelection] = dh.readcontindex(filename, 1, 1, 5);

assert(isequal(size(timeSelection), [5, 1]))

[timeAll, offsetAll] = dh.readcontindex(filename, 1);


%% Test readcont
data = dh.readcont(filename, 1);
assert(isequal(data(1:5), int16([-348   -290   -201   -224   -289])));

%% Test getcontsize
[nSamples, nChannels] = dh.getcontsize(filename, 1);
assert(nSamples == 1443184);
assert(nChannels == 1);

%% Test getcontindexsize
items = dh.getcontindexsize(filename, 1);
assert(items == 385)

%% Test getcontsampleperiod
period = dh.getcontsampleperiod(filename, 1);
assert(period == 1000000)