%  dhfun(DH.SETCONTCALINFO,FID,BLKID,CALINFO);
%
%  Write calibration info for a CONTx dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a continuous nTrode
%  CALINFO - double column array with calibration
%            info. Must have the same length as
%            the number of channels within this
%            CONTx nTrode.
%
%  Remarks:
%
%  File must be opened in read-write mode ('r+') for
%  this function to succeed. Each value of the
%  CALINFO array represents calibration
%  data for the corresponding channel. It is voltage per
%  unit. To get the voltage magnitude, one must multiply
%  channel data with the corresponding channel's calinfo.
%
function setcontcalinfo(fid, blkid, calinfo)

arguments
    fid
    blkid double {mustBePositive, mustBeInteger}
    calinfo double {mustBeVector}
end

filename = get_filename(fid);
groupPath = "/CONT" + blkid;

% Verify that calinfo length matches number of channels
[~, nChannels] = dh.getcontsize(fid, blkid);

if length(calinfo) ~= nChannels
    error('dhfun2:dh:setcontcalinfo:InvalidLength', ...
        'CALINFO must have length %d (number of channels) but got %d', ...
        nChannels, length(calinfo));
end

% Ensure calinfo is a column vector
if isrow(calinfo)
    calinfo = calinfo';
end

% Write the Calibration attribute
h5writeatt(filename, groupPath, 'Calibration', double(calinfo));

end