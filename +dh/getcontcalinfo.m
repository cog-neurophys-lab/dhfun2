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

contInfo = dh.getcontinfo(fid, blkid);
out = filter_by_name(contInfo.Attributes, "Calibration").Value;

end