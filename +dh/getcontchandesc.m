%  [GCN,BCN,ABW,MAV,MIV,AC0] = dhfun(DH.GETCONTCHANDESC,FID,BLKID)
%
%  Get the A/D descriptive information for each channel
%  in a CONT block
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of CONT Ntrode
%
%  return values:
%
%  Six arrays are returned by this function, each of them
%  has length equal to number of channels in this CONT
%  block.
%
%  GCN - (int16 array) GlobalChanNumber
%  BCN - (int16 array) BoardChanNo
%  ABW - (int16 array) ADCBitWidth
%  MAV - (float array) MaxVoltageRange
%  MIV - (float array) MinVoltageRange
%  AC0 - (float array) AmplifChan0
%
%  Remarks:
%
%  The values returned by this function are normally set
%  by the data acquisition program at the time of recording.
%  They characterize A/D conversion process for each channel.
%  Value of the amplification factor (AmplifChan0) can sometimes
%  be zero. In this case it should be supposed that no
%  extra amplification was done to the signal (i.e. amplification
%  factor of 1).

function [GCN,BCN,ABW,MAV,MIV,AC0] = getcontchandesc(fid, blkid)

filename = get_filename(fid);
channelAttributes = h5readatt(filename, "/CONT" + blkid, 'Channels');

GCN = [channelAttributes.GlobalChanNumber];
BCN = [channelAttributes.BoardChanNo];
ABW = [channelAttributes.ADCBitWidth];
MAV = [channelAttributes.MaxVoltageRange];
MIV = [channelAttributes.MinVoltageRange];
AC0 = [channelAttributes.AmplifChan0];