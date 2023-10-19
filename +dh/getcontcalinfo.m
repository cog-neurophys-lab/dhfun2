%  OUT = dhfun(DH.GETCONTCALINFO,FID,BLKID);
%
%  Read calibration info of a CONTx dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a continuous nTrode
%
%  OUT - variable to store output array
%
%  Remarks:
%
%  Output array will contain as many elements as number of
%  channels in a CONTx nTrode. Each value represent calibration
%  data for the corresponding channel. It is voltage per
%  unit. To get the voltage magnitude, one must multiply
%  channel data with the corresponding channel's calinfo.
function out = getcontcalinfo(fid, blkid)

filename = get_filename(fid);
try 
    out = h5readatt(filename, "/CONT" + blkid, 'Calibration');
catch
    warning('dhfun2:dh:NoCalibrationInFile', ...
        'CONT block %d of file %s \ndoes not contain calibration information. Assuming 1.', blkid, filename)
    out = 1;


end