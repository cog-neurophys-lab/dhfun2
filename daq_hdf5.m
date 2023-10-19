function varargout = daq_hdf5(filename, hdr, begsample, endsample, chanindx)
% DAQ_HDF5 reads time series data from a DAQ-HDF5 (DH5) file containing neurophysiological
% data to be used with the MATLAB toolbox FieldTrip (http://www.fieldtriptoolbox.org).  See
% https://github.com/cog-neurophys-lab/DAQ-HDF5 for the format specification.
%
% Use as
%   hdr = daq_hdf5(filename);
%   dat = daq_hdf5(filename, hdr, begsample, endsample, chanindx);
%   evt = daq_hdf5(filename, hdr);
% to read the header, the data or the event information.
%
% See also FT_FILETYPE, FT_READ_HEADER, FT_READ_DATA, FT_READ_EVENT

switch nargin
    
    case 1
        % read the header
        hdr = dh.ft_read_header(filename);
        varargout = {hdr};
        
    case 2
        % read the events
        evt = dh.ft_read_event(filename, hdr);
        varargout = {evt};
        
    case 5
        % read the data
        dat = dh.ft_read_data(filename, hdr, begsample, endsample, chanindx);
        varargout = {dat};
end

end

