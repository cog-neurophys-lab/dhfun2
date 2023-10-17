%  PERIOD = DHFUN.GETCONTSAMPLEPERIOD(FID, BLKID);
%
%  Get sample period for a given continuous nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier(s) of continuous nTrode
%
%  PERIOD - variable to store the sample period
%           (integer, given in nanoseconds)


function period = getcontsampleperiod(fid, blkid)

arguments
    fid
    blkid double {mustBeInteger}
end

filename = get_filename(fid);
period = zeros(1, length(blkid));
for iCont = 1:length(blkid)
    period(iCont) = h5readatt(filename, "/CONT" + blkid(iCont), 'SamplePeriod');
end
