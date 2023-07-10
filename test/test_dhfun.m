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
fid = dhfun(DH.OPEN, filename);
dhfun(DH.CLOSE, fid);

%% Test DH.GETFIDINFO
dhfun(DH.GETFIDINFO, fid);

%% Test DH.GETOPERATIONINFOS
dhfun(DH.GETOPERATIONINFOS, fid);

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
dhfun(DH.CREATECONT, filename, blkid, nSamples, nChannels, sampleperiod, indexsize);
assert(sampleperiod == dh.getcontsampleperiod(filename, blkid))
assert(indexsize == dh.getcontindexsize(filename, blkid))
[NSAMP, NCHAN] = dhfun(DH.GETCONTSIZE, fid, blkdid);
assert(nchannels == nchan)
assert(nSamples == NSAMP)

% WRITECONT
data = rand(nsamp, nchan);
dhfun(DH.WRITECONT, fileanme, blkid, 1, nSamples, 1, nSamples, data);


%% Test DH.ENUMCONT
idCont = dhfun(DH.ENUMCONT, filename);
assert(isequal(idCont, [1, 1001, 60, 61, 62, 63, 64]))

%% Test DH.READCONT
data = dhfun(DH.READCONT, filename, 1);
assert(isequal(data(1:5), int16([-348   -290   -201   -224   -289])));

%% Test DH.READCONTINDEX
[timeSelection, offsetSelection] = dhfun(DH.READCONTINDEX, filename, 1, 1, 5);
assert(isequal(size(timeSelection), [5, 1]))

%% Test DH.WRITECONTINDEX

%% Test DH.GETCONTSIZE
[nSamples, nChannels] = dhfun(DH.GETCONTSIZE, filename, 1);
assert(nSamples == 1443184);
assert(nChannels == 1);

%% Test DH.GETCONTINDEXSIZE
items = dhfun(DH.GETCONTINDEXSIZE, filename, 1);
assert(items == 385)

%% Test DH.GETCONTSAMPLEPERIOD
period = dhfun(DH.GETCONTSAMPLEPERIOD, filename, 1);
assert(period == 1000000)

%% Test DH.SETCONTSAMPLEPERIOD

%% Test DH.GETCONTCALINFO
cal = dhfun(DH.GETCONTCALINFO, filename, 1);
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

%% Test DH.READWAVELET

%% Test DH.WRITEWAVELET

%% Test DH.READWAVELETINDEX

%% Test DH.WRITEWAVELETINDEX

%% Test DH.GETWAVELETSIZE

%% Test DH.GETWAVELETINDEXSIZE

%% Test DH.GETWAVELETSAMPLEPERIOD

%% Test DH.SETWAVELETSAMPLEPERIOD

%% Test DH.GETWAVELETCHANDESC        (-)

%% Test DH.SETWAVELETCHANDESC        (-)

%% Test DH.GETWAVELETFAXIS

%% Test DH.SETWAVELETFAXIS

%% Test DH.GETWAVELETMORLETPARAMS

%% Test DH.SETWAVELETMORLETPARAMS

%
%  --- DAQ-HDF V2 EV02 triggers --------------------
%
%% Test DH.CREATEEV2

%% Test DH.READEV2

%% Test DH.WRITEEV2

%% Test DH.GETEV2SIZE

%
%  ---------- TRIALMAP interface -------------------
%
%% Test DH.GETTRIALMAP

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


%% Test open
fid = dh.open(filename, 'r');













