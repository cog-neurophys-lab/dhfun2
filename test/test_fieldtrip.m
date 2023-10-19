try
    ft_defaults
    fieldtripIsAvailable = true;
catch
    fieldtripIsAvailable = false;
end

addpath('..')

test_dataset1.filename = '20101110_task_merged_csd.dh5';
test_dataset1.channelsOfInterest = [57, 63, 144];
test_dataset1.trialdef.alignTrigger = 5;
test_dataset1.trialdef.startTrigger = 5;
test_dataset1.trialdef.endTrigger = -11;
test_dataset1.trialdef.tPreStartTrigger = 0;
test_dataset1.trialdef.tPostEndTrigger = 0;
test_dataset1.vblTrigger = 14;
test_dataset1.offset = 0.8;
test_dataset1.includedStimulusNo = [3:15];
test_dataset1.includedOutcomes = [1, 5, 6]; % 1=Hit

test_dataset2.filename = 'test_data.dh5';
test_dataset2.channelsOfInterest = 1;
test_dataset2.vblTrigger = 10;
test_dataset2.trialdef.alignTrigger = 9;
test_dataset2.trialdef.startTrigger = 9;
test_dataset2.trialdef.endTrigger = 16;
test_dataset2.offset = 0.0;
test_dataset2.trialdef.tPreStartTrigger = -0.5;
test_dataset2.trialdef.tPostEndTrigger = 0;
test_dataset2.includedStimulusNo = 40;
test_dataset2.includedOutcomes = [0]; % 0=Hit

dataset = test_dataset2;
filename = dataset.filename;
channelsOfInterest = dataset.channelsOfInterest;
vblTrigger = dataset.vblTrigger;

%% test ft_read_header
header = dh.ft_read_header(filename);
assert(isequal(header, daq_hdf5(filename)));
assert(length(header.label) == length(header.chanunit));
assert(length(header.label) == length(header.chantype));

%% test ft_read_events
header = dh.ft_read_header(filename, channelsOfInterest);
events = dh.ft_read_event(filename, header);


%% test ft_read_data
header = dh.ft_read_header(filename, channelsOfInterest);
dat = dh.ft_read_data(filename, header, 1, 200, 1);


%% test ft_read_cont
% data = dh.ft_read_cont(filename);
data = dh.ft_read_cont(filename, channelsOfInterest);
assert(length(data.label) == length(channelsOfInterest))


%% test application of Fieldtrip functions on data
if fieldtripIsAvailable
    data = dh.ft_read_cont(filename, channelsOfInterest);
    header = dh.ft_read_header(filename, channelsOfInterest);
    events = dh.ft_read_event(filename, header);
    
    % remove vertical blank events as we don't want to see them
    eventsWithoutVBL = events(~arrayfun(@(x) strcmp('trigger', x.type) && abs(x.value) == vblTrigger, events));
    
    % browse raw data
    cfg = [];
    cfg.viewmode = 'vertical';
    cfg.event = eventsWithoutVBL;
    cfg.plotevents = 'yes';
    ft_databrowser(cfg, data)
    
    % cut data into trials
    cfg = [];
    cfg.event = eventsWithoutVBL;
    cfg.hdr = header;
    cfg.trialdef = dataset.trialdef;
    [trl, event] = dh.trialfun_general(cfg);
    
    cfg = [];
    cfg.trl = trl;
    trials = ft_redefinetrial(cfg, data);
  
    % trial selection
    selectCfg = [];
    selectCfg.trials = ismember(trials.trialinfo(:,3), dataset.includedOutcomes) & ...
        ismember(trials.trialinfo(:,2), dataset.includedStimulusNo);
    trials = ft_selectdata(selectCfg, trials);

    % shift 0 by offset
    cfg = [];
    cfg.offset = -round(dataset.offset*data.hdr.Fs);
    trials = ft_redefinetrial(cfg, trials);
    
    % remove average
    preprocCfg = [];
    preprocCfg.demean = 'yes';
    trials = ft_preprocessing(preprocCfg, trials);
    
    % browse epoched data for channels of interest only
    cfg= [];
    cfg.viewmode = 'vertical';
    cfg.event = eventsWithoutVBL;
    cfg.plotevents = 'yes';
    ft_databrowser(cfg, trials)
    
    
    % average over trials
    cfg = [];
    tl = ft_timelockanalysis(cfg, trials);
    
    % plot all channels
    plotCfg = [];
    plotCfg.layout = 'ordered';
    plotCfg.xlim = [-0.5 0.5];
    plotCfg.showlabels = 'yes';
    ft_multiplotER(plotCfg, tl)
    
    
    % powerspectra
    powerCfg = [];
    powerCfg.method = 'mtmfft';
    powerCfg.taper = 'dpss';
    powerCfg.foilim = [1 150];
    powerCfg.tapsmofrq = 5;
    powerCfg.pad = 'nextpow2';
    powerSpectrum = ft_freqanalysis(powerCfg, trials);

    figure; loglog(powerSpectrum.freq, powerSpectrum.powspctrm);
    xlabel('Frequency (Hz)')
    ylabel('Power (a.u.)')
    
    % wavelet analysis
    waveletCfg = [];
    waveletCfg.method = 'wavelet';
    waveletCfg.width = 6;
    waveletCfg.output = 'pow';
    waveletCfg.toi = -0.8:0.05:1;
    % waveletCfg.foi = 1:2:150;
    waveletCfg.foi = logspace(log10(5), log10(250), 50);
    waveletCfg.pad = 'nextpow2';
    tfr = ft_freqanalysis(waveletCfg, trials);
    
    % baseline normalization
    baseCfg = [];
    baseCfg.baseline = [-0.5 0.0];
    baseCfg.baselinetype = 'db';
    basePow = ft_freqbaseline(baseCfg, tfr);
    
    % plot all time-frequency spectra
    plotCfg = [];
    plotCfg.layout = 'ordered';
    plotCfg.showlabels = 'yes';
    plotCfg.masknans = 'yes';
    plotCfg.zlim = [-5, 5];
    ft_multiplotTFR(plotCfg, basePow);
end

