% DH.CREATECONT(FID,BLKID,SAMPLES,CHANNELS,SAMPLEPERIOD,INDEXSIZE)
%
%  Create a new CONT block in a V2 file.
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of the new CONT Ntrode
%  SAMPLES   - length of the continuously recorded data, in samples
%  CHANNELS  - number of channels in this nTrode
%  SAMPLEPERIOD - sampling time interval for this nTrode,
%              measured in nanoseconds.
%  INDEXSIZE - number of items in this CONT block's index,
%              also known as number of continuous regions
%              in this piecewise-continuous recording.
%
%  Remarks:
%
%  For every CONT block in a DAQ-HDF file, its sizes must be
%  known at the time of creation. Once a CONT block was created,
%  its sises cannot be changed.
%
%  INDEX dataset of this CONT block will contain zeros at
%  the time of creation. The application should fill the
%  INDEX dataset with correct values as soon as possible.
%  Some DAQ-HDF reading programs may not be prepared for invalid
%  contents of CONTn/INDEX dataset.
%
%  The freshly created CONT block will have no CHAN_DESC
%  attribute specified (that attribute contains A/D descriptive
%  information for each channel in the CONT block).
%  The application should set this attribute, because many
%  programs which read DAQ-HDF files depend on the presence of it.
%
%  This function will fail if the file was not opened for
%  write access.
%
%  If a CONT block with the same BLKID already exists in the
%  file, this function will fail. The existing CONT block contents
%  will be preserved.
function createcont(fid,blkid,samples,channels,sampleperiod,indexsize)

filename = get_filename(fid);


h5create(filename, "/CONT" + blkid + "/DATA", [samples channels])
h5create(filename, "/CONT" + blkid + "/INDEX", [indexsize 2])

% TODO: write sampleperiod to CONTn/SAMPLEPERIOD
h5writeatt(filename, "/CONT" + blkid, "SAMPLEPERIOD", sampleperiod);