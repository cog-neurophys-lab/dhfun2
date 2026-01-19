%% WAVELET Interface Tests for dhfun2
% Each cell can be run independently

%% Shared setup - Run this cell first or it will be included in each test cell
addpath('..');
testDataFile = 'test_data.dh5';
testTempFile = 'test_wavelet_temp.dh5';
DH = dh.constants();
fprintf('Setup complete. Test file: %s\n', testDataFile);

%% Test DH.ENUMWAVELET - Enumerate wavelet blocks
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
fid = dhfun(DH.OPEN, testDataFile, 'r');
try
    waveletIds = dhfun(DH.ENUMWAVELET, fid);
    assert(~isempty(waveletIds), 'Should find WAVELET blocks');
    assert(all(ismember([1, 1001], waveletIds)), 'Should find WAVELET1 and WAVELET1001');
    assert(issorted(waveletIds), 'Wavelet IDs should be sorted');
    fprintf('✓ ENUMWAVELET: Found %d WAVELET blocks: %s\n', ...
        length(waveletIds), mat2str(waveletIds));
    finally
    dhfun(DH.CLOSE, fid);
end

%% Test DH.GETWAVELETSIZE - Get dimensions of wavelet data
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
fid = dhfun(DH.OPEN, testDataFile, 'r');
try
    [nchan, nsamp, nfreq] = dhfun(DH.GETWAVELETSIZE, fid, 1);
    assert(nfreq > 0 && nsamp > 0 && nchan > 0, 'Dimensions should be positive');
    assert(nfreq == 35, 'WAVELET1 should have 35 frequency bins');
    assert(nchan == 1, 'WAVELET1 should have 1 channel');
    fprintf('✓ GETWAVELETSIZE: WAVELET1 has %d channels x %d samples x %d freqs\n', ...
        nchan, nsamp, nfreq);
    finally
    dhfun(DH.CLOSE, fid);
end

%% Test DH.GETWAVELETINDEXSIZE - Get number of recording regions
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
fid = dhfun(DH.OPEN, testDataFile, 'r');
try
    nreg = dhfun(DH.GETWAVELETINDEXSIZE, fid, 1);
    assert(nreg > 0, 'Should have at least one recording region');
    assert(nreg == 385, 'WAVELET1 should have 385 regions');
    fprintf('✓ GETWAVELETINDEXSIZE: WAVELET1 has %d recording regions\n', nreg);
    finally
    dhfun(DH.CLOSE, fid);
end

%% Test DH.GETWAVELETSAMPLEPERIOD - Get sample period
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
fid = dhfun(DH.OPEN, testDataFile, 'r');
try
    samplePeriod = dhfun(DH.GETWAVELETSAMPLEPERIOD, fid, 1);
    assert(samplePeriod > 0, 'Sample period should be positive');
    assert(samplePeriod == 10000000, 'WAVELET1 should have 10ms sample period');
    fprintf('✓ GETWAVELETSAMPLEPERIOD: %d ns (%.1f ms)\n', ...
        samplePeriod, samplePeriod/1e6);
    finally
    dhfun(DH.CLOSE, fid);
end

%% Test DH.GETWAVELETFAXIS - Get frequency axis
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
fid = dhfun(DH.OPEN, testDataFile, 'r');
try
    faxis = dhfun(DH.GETWAVELETFAXIS, fid, 1);
    assert(~isempty(faxis) && length(faxis) == 35, 'Should have 35 frequencies');
    assert(faxis(1) == 5.0 && faxis(end) == 160.0, 'Range should be 5-160 Hz');
    assert(all(diff(faxis) > 0), 'Frequencies should be monotonically increasing');
    fprintf('✓ GETWAVELETFAXIS: %d frequencies from %.1f to %.1f Hz\n', ...
        length(faxis), faxis(1), faxis(end));
    finally
    dhfun(DH.CLOSE, fid);
end

%% Test DH.READWAVELETINDEX - Read index (time, offset, scaling)
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
fid = dhfun(DH.OPEN, testDataFile, 'r');
try
    [time, offset, scaling] = dhfun(DH.READWAVELETINDEX, fid, 1);
    assert(~isempty(time) && length(time) == 385, 'Should have 385 time entries');
    assert(all(offset > 0) && all(scaling > 0), 'Offsets and scaling should be positive');

    % Read a subset
    [time2, ~, ~] = dhfun(DH.READWAVELETINDEX, fid, 1, 1, 5);
    assert(length(time2) == 5 && isequal(time2, time(1:5)), 'Subset should match');

    fprintf('✓ READWAVELETINDEX: Read %d index entries\n', length(time));
    fprintf('  First region: time=%d ns, offset=%d, scaling=%g\n', ...
        time(1), offset(1), scaling(1));
    finally
    dhfun(DH.CLOSE, fid);
end

%% Test DH.READWAVELET - Read wavelet data
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
fid = dhfun(DH.OPEN, testDataFile, 'r');
try
    [a_all, phi_all] = dhfun(DH.READWAVELET, fid, 1);
    assert(~isempty(a_all) && isequal(size(a_all), size(phi_all)), 'Data should match');

    [nfreq, nsamp, nchan] = size(a_all);
    assert(nfreq == 35 && nchan == 1, 'Should have correct dimensions');
    assert(isa(a_all, 'uint16') && isa(phi_all, 'int8'), 'Should have correct types');

    % Read a subset
    [a_sub, phi_sub] = dhfun(DH.READWAVELET, fid, 1, 1, 1, 1, 100, 1, 10);
    assert(isequal(size(a_sub), [10, 100]) || isequal(size(a_sub), [10, 100, 1]), ...
        'Subset should have correct size');

    fprintf('✓ READWAVELET: Read %dx%dx%d wavelet data\n', nfreq, nsamp, nchan);
    fprintf('  Amplitude range: [%d, %d] (uint16)\n', min(a_all(:)), max(a_all(:)));
    fprintf('  Phase range: [%d, %d] (int8)\n', min(phi_all(:)), max(phi_all(:)));
    finally
    dhfun(DH.CLOSE, fid);
end

%% Test DH.GETWAVELETMORLETPARAMS - Get Morlet parameters (if present)
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
fid = dhfun(DH.OPEN, testDataFile, 'r');
try
    params = dhfun(DH.GETWAVELETMORLETPARAMS, fid, 1);
    if ~isempty(params.w0)
        fprintf('✓ GETWAVELETMORLETPARAMS: w0=%g, st_hl=%g\n', params.w0, params.st_hl);
    else
        fprintf('✓ GETWAVELETMORLETPARAMS: No Morlet params in test file (OK)\n');
    end
    finally
    dhfun(DH.CLOSE, fid);
end

%% Test DH.CREATEWAVELET - Create new wavelet block
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
testTempFile = 'test_wavelet_temp.dh5';
copyfile(testDataFile, testTempFile);
fid = dhfun(DH.OPEN, testTempFile, 'r+');
try
    blkid = 9999;
    channels = 2; samples = 100;
    faxis = logspace(log10(5), log10(100), 10)';
    sampleperiod = 5000000; indexsize = 3;

    dhfun(DH.CREATEWAVELET, fid, blkid, channels, samples, faxis, sampleperiod, indexsize);

    waveletIds = dhfun(DH.ENUMWAVELET, fid);
    assert(any(waveletIds == blkid), 'New WAVELET block should be enumerated');

    [nc, ns, nf] = dhfun(DH.GETWAVELETSIZE, fid, blkid);
    assert(nc == channels && ns == samples && nf == length(faxis), 'Correct dimensions');

    fprintf('✓ CREATEWAVELET: Created WAVELET%d (%dx%dx%d)\n', blkid, nc, ns, nf);
    finally
    dhfun(DH.CLOSE, fid);
    if exist(testTempFile, 'file'), delete(testTempFile); end
end

%% Test DH.WRITEWAVELETINDEX - Write index data
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
testTempFile = 'test_wavelet_temp.dh5';
copyfile(testDataFile, testTempFile);
fid = dhfun(DH.OPEN, testTempFile, 'r+');
try
    blkid = 9999;
    dhfun(DH.CREATEWAVELET, fid, blkid, 2, 100, logspace(log10(5), log10(100), 10)', 5000000, 3);

    time = int64([0; 1000000000; 2000000000]);
    offset = int64([1; 34; 67]);
    scaling = [0.5; 0.6; 0.7];
    dhfun(DH.WRITEWAVELETINDEX, fid, blkid, 1, 3, time, offset, scaling);

    [time_r, offset_r, scaling_r] = dhfun(DH.READWAVELETINDEX, fid, blkid);
    assert(isequal(time_r, double(time)) && isequal(offset_r, double(offset)), 'Data should match');

    fprintf('✓ WRITEWAVELETINDEX: Wrote 3 index entries\n');
    finally
    dhfun(DH.CLOSE, fid);
    if exist(testTempFile, 'file'), delete(testTempFile); end
end

%% Test DH.WRITEWAVELET - Write wavelet data
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
testTempFile = 'test_wavelet_temp.dh5';
copyfile(testDataFile, testTempFile);
fid = dhfun(DH.OPEN, testTempFile, 'r+');
try
    blkid = 9999;
    dhfun(DH.CREATEWAVELET, fid, blkid, 2, 100, logspace(log10(5), log10(100), 10)', 5000000, 3);

    a_write = double(uint16(rand(5, 10, 1) * 65535));
    phi_write = double(int8((rand(5, 10, 1) - 0.5) * 254)) * pi / 127.0;
    dhfun(DH.WRITEWAVELET, fid, blkid, 1, 1, 1, 10, 1, 5, a_write, phi_write);

    fprintf('✓ WRITEWAVELET: Wrote 5x10x1 data\n');
    finally
    dhfun(DH.CLOSE, fid);
    if exist(testTempFile, 'file'), delete(testTempFile); end
end

%% Test DH.SETWAVELETSAMPLEPERIOD - Modify sample period
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
testTempFile = 'test_wavelet_temp.dh5';
copyfile(testDataFile, testTempFile);
fid = dhfun(DH.OPEN, testTempFile, 'r+');
try
    blkid = 9999;
    dhfun(DH.CREATEWAVELET, fid, blkid, 2, 100, logspace(log10(5), log10(100), 10)', 5000000, 3);

    newPeriod = int32(12345678);
    dhfun(DH.SETWAVELETSAMPLEPERIOD, fid, blkid, newPeriod);
    period_read = dhfun(DH.GETWAVELETSAMPLEPERIOD, fid, blkid);
    assert(period_read == newPeriod, 'Sample period should match');

    fprintf('✓ SETWAVELETSAMPLEPERIOD: Set to %d ns\n', newPeriod);
    finally
    dhfun(DH.CLOSE, fid);
    if exist(testTempFile, 'file'), delete(testTempFile); end
end

%% Test DH.SETWAVELETFAXIS - Modify frequency axis
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
testTempFile = 'test_wavelet_temp.dh5';
copyfile(testDataFile, testTempFile);
fid = dhfun(DH.OPEN, testTempFile, 'r+');
try
    blkid = 9999;
    dhfun(DH.CREATEWAVELET, fid, blkid, 2, 100, logspace(log10(5), log10(100), 10)', 5000000, 3);

    newFaxis = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]';
    dhfun(DH.SETWAVELETFAXIS, fid, blkid, newFaxis);
    faxis_read = dhfun(DH.GETWAVELETFAXIS, fid, blkid);
    assert(max(abs(faxis_read - newFaxis)) < 1e-10, 'Frequency axis should match');

    fprintf('✓ SETWAVELETFAXIS: Set new frequency axis\n');
    finally
    dhfun(DH.CLOSE, fid);
    if exist(testTempFile, 'file'), delete(testTempFile); end
end

%% Test DH.SETWAVELETMORLETPARAMS - Set Morlet parameters
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
testTempFile = 'test_wavelet_temp.dh5';
copyfile(testDataFile, testTempFile);
fid = dhfun(DH.OPEN, testTempFile, 'r+');
try
    blkid = 9999;
    dhfun(DH.CREATEWAVELET, fid, blkid, 2, 100, logspace(log10(5), log10(100), 10)', 5000000, 3);

    w0 = 6.0; st_hl = 4.0;
    dhfun(DH.SETWAVELETMORLETPARAMS, fid, blkid, w0, st_hl);
    params = dhfun(DH.GETWAVELETMORLETPARAMS, fid, blkid);
    assert(params.w0 == w0 && params.st_hl == st_hl, 'Parameters should match');

    fprintf('✓ SETWAVELETMORLETPARAMS: Set w0=%g, st_hl=%g\n', w0, st_hl);
    finally
    dhfun(DH.CLOSE, fid);
    if exist(testTempFile, 'file'), delete(testTempFile); end
end

%% Test with multiple WAVELET blocks
addpath('..'); DH = dh.constants(); testDataFile = 'test_data.dh5';
fid = dhfun(DH.OPEN, testDataFile, 'r');
try
    waveletIds = dhfun(DH.ENUMWAVELET, fid);
    for id = waveletIds(:)'
        [nc, ns, nf] = dhfun(DH.GETWAVELETSIZE, fid, id);
        faxis = dhfun(DH.GETWAVELETFAXIS, fid, id);
        period = dhfun(DH.GETWAVELETSAMPLEPERIOD, fid, id);
        fprintf('  WAVELET%d: %dx%dx%d, %.1f-%.1f Hz, period=%d ns\n', ...
            id, nc, ns, nf, faxis(1), faxis(end), period);
    end
    fprintf('✓ Multi-block test: Successfully read %d WAVELET blocks\n', length(waveletIds));
    finally
    dhfun(DH.CLOSE, fid);
end

%% All tests complete
fprintf('\n========================================\n');
fprintf('All WAVELET interface tests passed! ✓\n');
fprintf('========================================\n');
