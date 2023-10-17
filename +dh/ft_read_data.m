function data = ft_read_data(filename, hdr, begsample, endsample, chanindx)

conts = dh.enumcont(filename);
selectedConts = conts(chanindx);

[nSamples, nChanInCont] = dh.getcontsize(filename, selectedConts);
nChannels = sum(nChanInCont);

if ~all(nSamples >= endsample-begsample+1)
    error('Not all channels have enough samples');
end

data = zeros(length(nChannels), endsample-begsample+1);

iChannel = 1;
for iCont = 1:length(chanindx)
    [time, ~] = dh.readcontindex(filename, selectedConts(iCont));
    if length(time) > 1
        warning('More than one data segment in CONT%d. This is not supported for Fieldtrip', selectedConts(iCont));
    end
    data(iChannel,:) = dh.readcont(filename, selectedConts(iCont), begsample, endsample);
end

end