%  dhfun(DH.WRITECONT, FID, BLKID, SAMBEG, SAMEND, CHNBEG, CHNEND, DATA);
%
%  Write contents of a CONTx data block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a continuous nTrode
%  SAMBEG,SAMEND - range of sample numbers to write. Samples from
%                  SAMBEG to SAMEND will be written inclusively.
%  CHNBEG,CHNEND - range of channel numbers to write. Channels from
%                  CHNBEG to CHNEND will be written inclusively.
%  DATA - the data to be written. An int16 matrix sized
%         [SAMEND-SAMBEG+1,CHNEND-CHNBEG+1] is required
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed

function writecont(fid, blkid, sambeg, samend, chnbeg, chnend, data)

filename = get_filename(fid);

assert(size(data) == [samend-sambeg+1,chnend-chnbeg+1])

h5write(filename, "/CONT" + blkid + "/DATA", data, [sambeg, chnbeg], [samend-sambeg+1, chnend-chnbeg+1])

end