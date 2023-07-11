addpath('..')

filename = 'test_data.dh5';
DH = dh.constants();

%  ----- General information, debugging ------------
%
%% Test DH.GETVERSION
version = dhfun(DH.GETVERSION, filename);
assert(version == 2)

%% Test DH.LISTOPENFIDS

%
%  --- General file service ------------------------
%
%% Test DH.OPEN / CLOSE
fid = dhfun(DH.OPEN, filename, 'r');
dhfun(DH.CLOSE, fid);

%% Test DH.GETFIDINFO


%% Test DH.GETOPERATIONINFOS
[opname, opinfo] = dhfun(DH.GETOPERATIONINFOS, filename);
assert(isequal(opname{1}, 'Recording'))
assert(opinfo{1}.Date.Year == 2010)

%% Test DH.GETDAQVERSION (-)


%
%  --- DAQ-HDF V1 continuous recordings ------------
%
%% Test DH.CREATECR (-)

%% Test DH.READCR

%% Test DH.WRITECR

%% Test DH.GETCRSIZE

%% Test DH.GETCRADCBITWIDTH

%% Test DH.GETCRSAMPLEPERIOD

%% Test DH.GETCRSTARTTIME

%% Test DH.GETCRMAXVOLTAGERANGE

%% Test DH.GETCRMINVOLTAGERANGE

%% Test DH.GETCRCALINFO

%% Test DH.SETCRCALINFO (-)

%
%  --- DAQ-HDF V1 event triggers -------------------
%
%% Test DH.CREATEEV (-)

%% Test DH.READEV

%% Test DH.WRITEEV

%% Test DH.GETEVSIZE

%
%  --- DAQ-HDF all versions TD01 records -----------
%
%% Test DH.CREATETD

%% Test DH.READTD

%% Test DH.WRITETD

%% Test DH.GETTDSIZE

%
%  --- DAQ-HDF V2 CONT nTrodes ---------------------
%
%% Test DH.CREATECONT / WRITECONT
blkid = 5398745;
nSamples = 2048;
nChannels = 8;
sampleperiod = 1000000;
indexsize = 5;

% CREATECONT
% dhfun(DH.CREATECONT, filename, blkid, nSamples, nChannels, sampleperiod, indexsize);
% assert(sampleperiod == dh.getcontsampleperiod(filename, blkid))
% assert(indexsize == dh.getcontindexsize(filename, blkid))
% [NSAMP, NCHAN] = dhfun(DH.GETCONTSIZE, fid, blkdid);
% assert(nchannels == nchan)
% assert(nSamples == NSAMP)

% WRITECONT
% data = rand(nsamp, nchan);
% dhfun(DH.WRITECONT, fileanme, blkid, 1, nSamples, 1, nSamples, data);


%% Test DH.ENUMCONT
idCont = dhfun(DH.ENUMCONT, filename);
assert(isequal(idCont, [1, 1001, 60, 61, 62, 63, 64]))

%% Test DH.READCONT
blkid = 1;
data = dhfun(DH.READCONT, filename, blkid);
assert(isequal(data(1:5), int16([-348   -290   -201   -224   -289])));

%% Test DH.READCONTINDEX
[timeSelection, offsetSelection] = dhfun(DH.READCONTINDEX, filename, 1, 1, 5);
assert(isequal(size(timeSelection), [5, 1]))

%% Test DH.WRITECONTINDEX

%% Test DH.GETCONTSIZE
blkid = 1;
[nSamples, nChannels] = dhfun(DH.GETCONTSIZE, filename, blkid);
assert(nSamples == 1443184);
assert(nChannels == 1);

%% Test DH.GETCONTINDEXSIZE
blkid = 1;
items = dhfun(DH.GETCONTINDEXSIZE, filename, blkid);
assert(items == 385)

%% Test DH.GETCONTSAMPLEPERIOD
blkid = 1;
period = dhfun(DH.GETCONTSAMPLEPERIOD, filename, blkid);
assert(period == 1000000)

%% Test DH.SETCONTSAMPLEPERIOD

%% Test DH.GETCONTCALINFO
blkid = 1;
cal = dhfun(DH.GETCONTCALINFO, filename, blkid);
assert(abs(cal - 0.000000101725260416666673195878968418565113651652609405573457) < eps)

%% Test DH.SETCONTCALINFO

%% Test DH.GETCONTCHANDESC
blkid = 1;
[GCN,BCN,ABW,MAV,MIV,AC0] = dhfun(DH.GETCONTCHANDESC, filename, blkid);


%% Test DH.SETCONTCHANDESC (-)

%
%  --- DAQ-HDF V2 SPIKE nTrodes --------------------
%
%% Test DH.CREATESPIKE

%% Test DH.ENUMSPIKE
idSpike = dhfun(DH.ENUMSPIKE, filename);
assert(idSpike == 0)

%% Test DH.READSPIKE


%% Test DH.WRITESPIKE

%% Test DH.READSPIKEINDEX

%% Test DH.WRITESPIKEINDEX

%% Test DH.ISCLUSTERINFO_PRESENT

%% Test DH.READSPIKECLUSTER

%% Test DH.WRITESPIKECLUSTER

%% Test DH.GETSPIKESIZE

%% Test DH.GETNUMBERSPIKES

%% Test DH.GETSPIKESAMPLEPERIOD

%% Test DH.GETSPIKEPARAMS

%% Test DH.GETSPIKECHANDESC (-)

%% Test DH.SETSPIKECHANDESC (-)

%
%  --- WAVELET interface ---------------------------
%% Test DH.CREATEWAVELET

%% Test DH.ENUMWAVELET
idWavelets = dhfun(DH.ENUMWAVELET, filename);
assert(isequal(idWavelets, [1, 1001]))

%% Test DH.READWAVELET
blkid = 1;
chnbeg = 1; chnend =  1;
frqbeg = 1; frqend = 10;
sambeg = 1; samend = 20;
[a, phi] = dhfun(DH.READWAVELET, filename, blkid);
assert(isequal(size(a),size(phi)))
[a, phi] = dhfun(DH.READWAVELET, filename, blkid, ...
    chnbeg,chnend,sambeg,samend,frqbeg,frqend);
assert(isequal(size(a), [frqend-frqbeg+1, samend-sambeg+1]))
% TODO: check multi-channel case (3D array)


%% Test DH.WRITEWAVELET

%% Test DH.READWAVELETINDEX
blkid = 1;
[time, offset, scaling] = dhfun(DH.READWAVELETINDEX, filename, blkid);
assert(length(time) == length(offset))
assert(length(offset) == length(scaling))

[time, offset, scaling] = dhfun(DH.READWAVELETINDEX, filename, blkid, 5, 10);
assert(length(time) == 6)

%% Test DH.WRITEWAVELETINDEX

%% Test DH.GETWAVELETSIZE
blkid = 1;
[nChannels, nSamples, nFreqs] = dhfun(DH.GETWAVELETSIZE, filename, blkid);
assert(nChannels == 1)
assert(nSamples == 144117)
assert(nFreqs == 35)

%% Test DH.GETWAVELETINDEXSIZE
blkid = 1;
nRecords = dhfun(DH.GETWAVELETINDEXSIZE, filename, blkid);
assert(nRecords == 385)

%% Test DH.GETWAVELETSAMPLEPERIOD
blkid = 1;
sampleperiod = dhfun(DH.GETWAVELETSAMPLEPERIOD, filename, blkid);

%% Test DH.SETWAVELETSAMPLEPERIOD

%% Test DH.GETWAVELETCHANDESC        (-)

%% Test DH.SETWAVELETCHANDESC        (-)

%% Test DH.GETWAVELETFAXIS
blkid = 1;
faxis = dhfun(DH.GETWAVELETFAXIS, filename, blkid);
assert(length(faxis) == 35)

%% Test DH.SETWAVELETFAXIS

%% Test DH.GETWAVELETMORLETPARAMS

%% Test DH.SETWAVELETMORLETPARAMS

%
%  --- DAQ-HDF V2 EV02 triggers --------------------
%
%% Test DH.CREATEEV2

%% Test DH.READEV2
[time, event] = dhfun(DH.READEV2, filename);
assert(length(time) == 10460)
assert(length(event) == length(time))
[time, event] = dhfun(DH.READEV2, filename, 1, 20);
assert(length(time) == 20)

%% Test DH.WRITEEV2

%% Test DH.GETEV2SIZE
nRecords = dhfun(DH.GETEV2SIZE, filename);
assert(nRecords == 10460);


%
%  ---------- TRIALMAP interface -------------------
%
%% Test DH.GETTRIALMAP
[trialno,stimno,outcome,starttime,endtime] = dhfun(DH.GETTRIALMAP, filename);
assert(isequal(trialno(1:5), int32(295:299)'))

%% Test DH.SETTRIALMAP

%
%  ---------- MARKER interface ---------------------
%
%% Test DH.ENUMMARKERS

%% Test DH.GETMARKER

%% Test DH.SETMARKER

%
%  ---------- INTERVAL interface -------------------
%
%% Test DH.ENUMINTERVALS

%% Test DH.GETINTERVAL

%% Test DH.SETINTERVAL
















