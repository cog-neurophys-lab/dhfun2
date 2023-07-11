%  [TIME,EVENT] = dhfun(DH.READEV2, FID, RBEG, REND);
%
%  Read contents of the EV02 dataset in the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%
%  TIME - variable to store 'time' field of EV01 records
%  EVENT - variable to store 'event' field of EV01 records
function [time, event] = readev2(fid, rbeg, rend)

filename = get_filename(fid);

switch nargin
    case 1
        ev2 = h5read(filename, '/EV02');
    case 3
        ev2 = h5read(filename, '/EV02', rbeg, rend-rbeg+1);
    otherwise
        error('Wrong number of input arguments. Should be 1 or 3')
end

time = ev2.time;
event = ev2.event;