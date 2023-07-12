function contMap = get_cont_map(filename, blockId)
% GET_CONT_MAP Returns a structure with the tStart and end times of all
% continuous data segments in the specified block.
% 
% The fields of the output struct are:
%   tStart:     The start time of the segment in nanoseconds
%   tEnd:       The end time of the segment in nanoseconds
%   iStart:     The start index of the segment
%   iEnd:       The end index of the segment
%   scaling:    The scaling factor for the segment
%   samper:     The sampling period of the segment in nanoseconds
%

contMap = struct('tStart', [], 'tEnd', [], 'iStart', [], 'iEnd', [], 'scaling', [], 'samper', []);

[nsam, ~] = dh.getcontsize(filename, blockId);
nsam = double(nsam);
[contMap.tStart, contMap.iStart] = dh.readcontindex(filename, blockId);

contMap.tStart = double(contMap.tStart);
contMap.samper = double(dh.getcontsampleperiod(filename, blockId));

try
    scaling = dh.getcontcalinfo(filename, blockId);
catch
    warning('dhfun2:dh.get_cont_map:NoCalibrationFound', 'No calibration information found. Assuming no scaling.')
    scaling = 1;
end

contMap.iEnd = [contMap.iStart(2:end)-1;nsam];
contMap.tEnd = contMap.tStart+double(contMap.iEnd-contMap.iStart)*contMap.samper;
contMap.scaling = ones(size(contMap.tStart)).*scaling;


