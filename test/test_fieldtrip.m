try
    ft_defaults
    fieldtripIsAvailable = true;
catch
    fieldtripIsAvailable = false;
end

addpath('..')
filename = 'test_data.dh5';

%% test ft_read_header
header = dh.ft_read_header(filename);
assert(isequal(header, daq_hdf5(filename)));
% assert(header.nTrials == 385);
% assert(header.Fs == 1000.0);
% assert(length(header.label) == 7);
assert(length(header.label) == length(header.chanunit));
assert(length(header.label) == length(header.chantype));

%% test ft_read_events
header = dh.ft_read_header(filename);
events = dh.ft_read_event(filename, header);
% assert(length(events) == 10845);


%% test ft_read_data
header = dh.ft_read_header(filename);

dat = dh.ft_read_data(filename, header, 1, 200, 1);
if fieldtripIsAvailable
    cfg = [];
    cfg.datafile = filename;

end

%% test ft_read_cont
data = dh.ft_read_cont(filename);


%% browse data for testing
if fieldtripIsAvailable
    data = dh.ft_read_cont(filename);
    header = dh.ft_read_header(filename);
    events = dh.ft_read_event(filename, header);

    vblTrigger = 10;

    cfg = [];
    cfg.dataset = filename;
    cfg.dataformat = 'daq_hdf5';
    cfg.headerformat = 'daq_hdf5';
    cfg.eventformat = 'daq_hdf5';
    cfg.viewmode = 'vertical';
%     cfg.channel =  {'CONT100/0'  'CONT101/0'  'CONT102/0'  'CONT103/0'};
    cfg.event = events;
    cfg.plotevents = 'yes';
    cfg.ploteventlabels = 'no';
    ft_databrowser(cfg, data)



    noVBL = events(~arrayfun(@(x) strcmp('trigger', x.type) && abs(x.value) == vblTrigger, events));

    cfg = []; cfg.event = noVBL; cfg.hdr = header;
    [trl, event] = dh.trialfun_general(cfg);

    cfg = [];
    cfg.trl = trl;
    trials = ft_redefinetrial(cfg, data);

    %%
    cfg = [];
    tl = ft_timelockanalysis(cfg, trials);
    % fig = figure;
    % plot(tl.time, tl.avg);
    plotCfg = [];
    plotCfg.layout = 'ordered';
    plotCfg.showlabels = 'yes';
    ft_multiplotER(plotCfg, tl)
    %%

    cfg= [];
    cfg.viewmode = 'vertical';
%     cfg.channel =  {'CONT100/0'  'CONT101/0'  'CONT102/0'  'CONT103/0'};
    cfg.event = noVBL;
    cfg.plotevents = 'yes';
    ft_databrowser(cfg, trials)

end

