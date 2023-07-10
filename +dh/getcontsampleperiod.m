%  PERIOD = DHFUN.GETCONTSAMPLEPERIOD(FID, BLKID);
%
%  Get sample period for a given continuous nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%
%  PERIOD - variable to store the sample period
%           (integer, given in nanoseconds)


function period = getcontsampleperiod(fid, blkid)

arguments
    fid
    blkid double {mustBeInteger}
end

filename = get_filename(fid);

contGroups = dh.enumcont(filename);
if ~ismember(blkid, contGroups)
    error('No such CONT block')
end

contAttributes = dh.getcontinfo(filename, blkid).Attributes;
iSamplePeriodAttribute = cellfun(@(name) string(name) == "SamplePeriod", {contAttributes.Name});
period = contAttributes(iSamplePeriodAttribute).Value;
