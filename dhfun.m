%  Matlab library to access DAQ-HDF files V2.12 from 01.06.2006
%
%  DAQ versions supported: 1.0, 2.0, 3.1, 3.2, 3.3 (no interface for RECP)
%
%  usage:
%
%  [<outputs>] = dhfun(<function number>, <arguments>)
%
%
%  Function reference:
%
%  ----- General information, debugging ------------
%
%  DH.GETVERSION
%  DH.LISTOPENFIDS
%
%  --- General file service ------------------------
%
%  DH.OPEN
%  DH.CLOSE
%  DH.GETFIDINFO
%  DH.GETOPERATIONINFOS
%  DH.GETDAQVERSION (-)
%
%  --- DAQ-HDF V1 continuous recordings ------------
%
%  DH.CREATECR (-)
%  DH.READCR
%  DH.WRITECR
%  DH.GETCRSIZE
%  DH.GETCRADCBITWIDTH
%  DH.GETCRSAMPLEPERIOD
%  DH.GETCRSTARTTIME
%  DH.GETCRMAXVOLTAGERANGE
%  DH.GETCRMINVOLTAGERANGE
%  DH.GETCRCALINFO
%  DH.SETCRCALINFO (-)
%
%  --- DAQ-HDF V1 event triggers -------------------
%
%  DH.CREATEEV (-)
%  DH.READEV
%  DH.WRITEEV
%  DH.GETEVSIZE
%
%  --- DAQ-HDF all versions TD01 records -----------
%
%  DH.CREATETD
%  DH.READTD
%  DH.WRITETD
%  DH.GETTDSIZE
%
%  --- DAQ-HDF V2 CONT nTrodes ---------------------
%
%  DH.CREATECONT
%  DH.ENUMCONT
%  DH.READCONT
%  DH.WRITECONT
%  DH.READCONTINDEX
%  DH.WRITECONTINDEX
%  DH.GETCONTSIZE
%  DH.GETCONTINDEXSIZE
%  DH.GETCONTSAMPLEPERIOD
%  DH.SETCONTSAMPLEPERIOD
%  DH.GETCONTCALINFO
%  DH.SETCONTCALINFO
%  DH.GETCONTCHANDESC
%  DH.SETCONTCHANDESC (-)
%
%  --- DAQ-HDF V2 SPIKE nTrodes --------------------
%
%  DH.CREATESPIKE
%  DH.ENUMSPIKE
%  DH.READSPIKE
%  DH.WRITESPIKE
%  DH.READSPIKEINDEX
%  DH.WRITESPIKEINDEX
%  DH.ISCLUSTERINFO_PRESENT
%  DH.READSPIKECLUSTER
%  DH.WRITESPIKECLUSTER
%  DH.GETSPIKESIZE
%  DH.GETNUMBERSPIKES
%  DH.GETSPIKESAMPLEPERIOD
%  DH.GETSPIKEPARAMS
%  DH.GETSPIKECHANDESC (-)
%  DH.SETSPIKECHANDESC (-)
%
%  --- WAVELET interface ---------------------------
%  DH.CREATEWAVELET
%  DH.ENUMWAVELET
%  DH.READWAVELET
%  DH.WRITEWAVELET
%  DH.READWAVELETINDEX
%  DH.WRITEWAVELETINDEX
%  DH.GETWAVELETSIZE
%  DH.GETWAVELETINDEXSIZE
%  DH.GETWAVELETSAMPLEPERIOD
%  DH.SETWAVELETSAMPLEPERIOD
%  DH.GETWAVELETCHANDESC        (-)
%  DH.SETWAVELETCHANDESC        (-)
%  DH.GETWAVELETFAXIS
%  DH.SETWAVELETFAXIS
%  DH.GETWAVELETMORLETPARAMS
%  DH.SETWAVELETMORLETPARAMS
%
%  --- DAQ-HDF V2 EV02 triggers --------------------
%
%  DH.CREATEEV2
%  DH.READEV2
%  DH.WRITEEV2
%  DH.GETEV2SIZE
%
%  ---------- TRIALMAP interface -------------------
%
%  DH.GETTRIALMAP
%  DH.SETTRIALMAP
%
%  ---------- MARKER interface ---------------------
%
%  DH.ENUMMARKERS
%  DH.GETMARKER
%  DH.SETMARKER
%
%  ---------- INTERVAL interface -------------------
%
%  DH.ENUMINTERVALS
%  DH.GETINTERVAL
%  DH.SETINTERVAL
%
%
%  -------------------------------------------------
%
%  Functions marked with (-) are not implemented.
%  They will be implemented on demand.
%
%  =================================================
%
%
%
%
%  Function descriptions:
%
%
%  -------------------------------------------------
%
%
%  FID = dhfun(DH.OPEN,FILENAME,ACCESS, <FID_ORIGINAL> );
%
%  Open a DAQ-HDF file
%
%  arguments:
%
%  FILENAME - character string
%  ACCESS - character string, access mode. Possible values:
%   'r' - read existing
%   'w' - create new or truncate existing file, read and write
%   'r+' - update existing file, read and write
%  FID_ORIGINAL - (optional) file identifier of another opened
%      DAQ-HDF file used when creating a derivative file.
%
%
%  FID - file identifier, should be stored in a variable for further
%  operations with this file
%
%  Remarks:
%
%  Write functions (such as WRITECONT) succeed only on
%  files opened for writing (modes 'w' and 'r+').
%
%  Truncation mode ('w') creates an empty DAQ-HDF file of
%  version 2. The file can be populated by functions like
%  CREATECONT, etc. A DAQ-HDF file can be created as a
%  derivative of another DAQ-HDF file. In this case,
%  file identifier of the original file must be supplied.
%  For derivative files, processing history of the original
%  file is copied, and original file name is saved in a
%  processing history entry when the target file is closed.
%
%  All files opened by this function must be closed when they
%  are no longer needed, using the function DH.CLOSE. Failure
%  to do so (for example, in case of a user program error)
%  will cause the files to remain open and blocked by the
%  operating system, wasting the system resources.
%
%  When the DHFUN mex file is unloaded, it closes all open
%  files. User can unload the mex file by executing
%  'clear dhfun' command from Matlab. This will cause
%  all files opened by DHFUN to be closed.
%
%  -------------------------------------------------
%
%  dhfun(DH.CLOSE,FID, <OPERATION_NAME,OPERATOR_NAME,TOOL_NAME,OPERATION_INFO> );
%
%  Close a DAQ-HDF file, optionally adding a processing history
%  entry. Arguments which are enclosed in angle brackets are optional.
%
%  arguments:
%
%  FID - file identifier to close. FID is returned by previous open
%        operation
%  OPERATION_NAME - (string) name of the processing history entry
%        to be added. Typically, it is a title of the operation
%        performed on the DAQ-HDF file, such as 'Filtering',
%        'Resampling'.
%  OPERATOR_NAME - (string) name of the user who initiated the
%        operation
%  TOOL_NAME - (string) name of the program which performed the
%        operation, such as 'My processing program V1.0'
%  OPERATION_INFO - (scalar struct) additional information which
%        should be written into processing history of the DAQ-HDF file.
%
%  Remarks:
%
%  When 2 input arguments are provided, the file is closed without
%  adding a processing history entry. A processing history entry
%  cannot be added into a file opened for read access.
%
%  OPERATION_INFO structure can contain fields with any names and
%  content. Fields themselves may be multi-dimensional arrays.
%  The following Matlab data types are currently supported:
%
%      uint8
%      int8
%      uint16
%      int16
%      uint32
%      int32
%      uint64
%      int64
%      char (only row vectors of chars, 'single strings')
%      single
%      double
%
%  Structs, logicals, cell arrays and other data types are not
%  supported. It is possible that support of structs and logicals
%  will be added in future.
%
%  Besides the above mentioned information, current date and time,
%  and current version of DHFUN library are also added to the
%  processing history entry. If the file was created as a derivative
%  (see description of DH.OPEN), original file name is added
%  to the processing history entry, too.
%
%  -------------------------------------------------
%
%  OUTPUT = dhfun(DH.READCR,FID,SAMBEG,SAMEND,CHNBEG,CHNEND);
%
%  Read contents of the CR01 dataset in the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  SAMBEG,SAMEND - range of sample numbers to read. Samples from
%                  SAMBEG to SAMEND will be read inclusively.
%  CHNBEG,CHNEND - range of channel numbers to read. Channels from
%                  CHNBEG to CHNEND will be read inclusively.
%
%  OUTPUT - output variable. A matrix sized [SAMEND-SAMBEG+1,CHNEND-CHNBEG+1]
%           will be returned.
%
%  -------------------------------------------------
%
%  [TIME,EVENT,PATTERN] = dhfun(DH.READEV,FID,RBEG,REND);
%
%  Read contents of the EV01 dataset in the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%
%  TIME - variable to store 'time' field of EV01 records
%  EVENT - variable to store 'event' field of EV01 records
%  PATTERN - variable to store 'pattern' field of EV01 records
%
%  -------------------------------------------------
%
%  [TIME,TRIALNO,STIMNO,RES1,RES2] = dhfun(DH.READTD,FID,RBEG,REND);
%
%  Read contents of the TD01 dataset in the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%
%  TIME - variable to store 'time' field of TD01 records
%  TRIALNO - variable to store 'TrialNo' field of TD01 records
%  STIMNO - variable to store 'StimNo' field of TD01 records
%  RES1 - variable to store 'reserved1' field of TD01 records
%  RES2 - variable to store 'reserved2' field of TD01 records
%
%  -------------------------------------------------
%
%  dhfun(DH.WRITECR,FID,SAMBEG,SAMEND,CHNBEG,CHNEND,DATA)
%
%  Write contents of the CR01 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%  SAMBEG,SAMEND - range of sample numbers to write. Samples from
%                  SAMBEG to SAMEND will be written inclusively.
%  CHNBEG,CHNEND - range of channel numbers to write. Channels from
%                  CHNBEG to CHNEND will be written inclusively.
%
%  DATA - the data to be written. An int16 matrix sized
%         [SAMEND-SAMBEG+1,CHNEND-CHNBEG+1] is required
%
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed
%
%  -------------------------------------------------
%
%  dhfun(DH.WRITEEV,FID, RBEG, REND, TIME, EVENT, PATTERN)
%
%  Write contents of the EV01 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%  RBEG, REND - range of record numbers to write. Records from
%               RBEG to REND will be written inclusively.
%  TIME - 'time' member of the EV01 structure. Should be a column
%         array of doubles, sized according to number of
%         records to write.
%  EVENT - 'event' member of the EV01 structure. Should be a
%          column array of int32, sized according to number of
%          records to write.
%  PATTERN - 'pattern' member of the EV01 structure. Should be a
%          column array of uint32, sized according to number of
%          records to write.
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed
%
%  -------------------------------------------------
%
%  dhfun(DH.WRITETD,FID,RBEG,REND,TIME,TRIALNO,STIMNO,RESERVED1,RESERVED2);
%
%  Write contents of the TD01 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%  RBEG, REND - range of record numbers to write. Records from
%               RBEG to REND will be written inclusively.
%  TIME      - 'time' member of the TD01 structure. Should be a column
%              array of doubles, sized according to number of
%              records to write.
%  TRIALNO   - 'TrialNo' member of the TD01 structure. Should be a
%              column array of int32, sized according to number of
%              records to write.
%  STIMNO    - 'StimNo' member of the TD01 structure. Should be a
%              column array of int32, sized according to number of
%              records to write.
%  RESERVED1 - 'reserved1' member of the TD01 structure. Should be a
%              column array of uint32, sized according to number of
%              records to write.
%  RESERVED2 - 'reserved2' member of the TD01 structure. Should be a
%              column array of uint32, sized according to number of
%              records to write.
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed
%
%  -------------------------------------------------
%
%  [SAMPLES,CHANNELS] = dhfun(DH.GETCRSIZE,FID);
%
%  Get number of samples and number of channels in the
%  CR01 dataset of the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  SAMPLES - variable to store number of samples
%  CHANNELS - variable to store number of channels
%
%  -------------------------------------------------
%
%  REC = dhfun(DH.GETEVSIZE,FID);
%
%  Get number of records in the EV01 dataset of the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  REC - variable to store number of records
%
%  -------------------------------------------------
%
%  REC = dhfun(DH.GETTDSIZE,FID);
%
%  Get number of records in the TD01 dataset of the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  REC - variable to store number of records
%
%  -------------------------------------------------
%
%  ABW = dhfun(DH.GETCRADCBITWIDTH,FID);
%
%  Read value of the ADCBitWidth attribute of CR01 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  ABW - variable to store output value
%
%  -------------------------------------------------
%
%  SP = dhfun(DH.GETCRSAMPLEPERIOD,FID);
%
%  Read value of the SamplePeriod attribute of CR01 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  SP - variable to store output value
%
%  -------------------------------------------------
%
%  ST = dhfun(DH.GETCRSTARTTIME,FID);
%
%  Read value of the StartTime attribute of CR01 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  ST - variable to store output value
%
%  -------------------------------------------------
%
%  MVR = dhfun(DH.GETCRMAXVOLTAGERANGE,FID);
%
%  Read value of the MaxVoltageRange attribute of CR01 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  MVR - variable to store output value
%
%  -------------------------------------------------
%
%  MVR = dhfun(DH.GETCRMINVOLTAGERANGE,FID);
%
%  Read value of the MinVoltageRange attribute of CR01 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  MVR - variable to store output value
%
%  -------------------------------------------------
%
%  OUT = dhfun(DH.GETCRCALINFO,FID);
%
%  Read calibration info array of CR01 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  OUT - variable to store output array
%
%  Remarks:
%
%  Output array will contain as many elements as number of
%  channels in CR01 dataset. Each value represent calibration
%  data for the corresponding channel. It is voltage per
%  measuring unit.
%
%  -------------------------------------------------
%
%  dhfun(DH.SETCRCALINFO,FID ...);
%
%  Set or update calibration info array of the CR01 dataset.
%
%  Remarks:
%
%  Function is not implemented, and the argument list is undefined.
%
%  -------------------------------------------------
%
%  dhfun(DH.GETVERSION);
%
%  Returns DHFUN version number as a floating-point value
%
%  -------------------------------------------------
%
%  dhfun(DH.GETDAQVERSION, FID ...);
%
%  Get initial DAQ program and file versions from recording
%
%  Remarks:
%
%  Function is not implemented, and the argument list is undefined.
%
%  -------------------------------------------------
%
%  OUTPUT = dhfun(DH.READCONT, FID, BLKID, SAMBEG, SAMEND, CHNBEG, CHNEND);
%
%  Read contents of a CONTx data block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  SAMBEG,SAMEND - range of sample numbers to read. Samples from
%                  SAMBEG to SAMEND will be read inclusively.
%  CHNBEG,CHNEND - range of channel numbers to read. Channels from
%                  CHNBEG to CHNEND will be read inclusively.
%
%  OUTPUT - output variable. A matrix sized [SAMEND-SAMBEG+1,CHNEND-CHNBEG+1]
%           will be returned.
%
%  -------------------------------------------------
%
%  [TIME, OFFSET] = dhfun(DH.READCONTINDEX, FID, BLKID, RBEG, REND);
%
%  Read contents of a CONTx index block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%
%  TIME, OFFSET - variables to store 'time' and 'offset'
%          fields of index items. TIME is given in nanoseconds
%          (double array), and OFFSET is given in samples
%          (int32 array). Offset is 1-based and references
%          to the beginning of cont dataset.
%
%  Remarks:
%
%  Index allows to calculate range of samples for a particular
%  range of time. Each index item is associated a contiguous
%  section of recording, where individual offsets can be
%  calculated given starting time and sample period. Between
%  these contiguous sections there are gaps. Ending time for
%  a section is calculated using the start offset for the next
%  section. Be sure to check that a time range does not
%  include gaps.
%
%  Gaps usually do not exist in files recorded without
%  using space-saving "trial-based" mode. In this case index contains
%  of only 1 item which gives the start time of continuous recording.
%
%  -------------------------------------------------
%
%  [NSAMP, NCHAN] = dhfun(DH.GETCONTSIZE, FID, BLKID);
%
%  Get number of samples and number of channels for a
%  given continuous nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%
%  NSAMP - variable to store number of samples
%  NCHAN - variable to store number of channels
%
%  -------------------------------------------------
%
%  ITEMS = dhfun(DH.GETCONTINDEXSIZE, FID, BLKID);
%
%  Get number of items in the index of the CONTx block
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%
%  ITEMS - variable to store number of items in the index
%
%  -------------------------------------------------
%
%  PERIOD = dhfun(DH.GETCONTSAMPLEPERIOD, FID, BLKID);
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
%
%  -------------------------------------------------
%
%  OUTPUT = dhfun(DH.READSPIKE, FID, BLKID, SAMBEG, SAMEND, CHNBEG, CHNEND);
%
%  Read contents of a SPIKEx data block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a spike nTrode
%  SAMBEG,SAMEND - range of sample numbers to read. Samples from
%                  SAMBEG to SAMEND will be read inclusively.
%  CHNBEG,CHNEND - range of channel numbers to read. Channels from
%                  CHNBEG to CHNEND will be read inclusively.
%
%  OUTPUT - output variable. A matrix sized [SAMEND-SAMBEG+1,CHNEND-CHNBEG+1]
%           will be returned.
%
%  Remarks:
%
%  Starting and ending samples for a single spike or for a group
%  of spikes can be calculated using spike length obtained from
%  function DH.GETSPIKEPARAMS. To obtain time when a particular
%  spike has been triggered, use DH.READSPIKEINDEX
%
%  -------------------------------------------------
%
%  TIME = dhfun(DH.READSPIKEINDEX, FID, BLKID, RBEG, REND);
%
%  Read contents of a SPIKEx index block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike nTrode
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%  TIME - variable to store read data. A vector sized
%         [REND-RBEG+1] will be returned. Each item
%         corresponds to a single spike and specifies
%         its trigger time given in nanoseconds.
%
%  Remarks:
%
%  Use this function to determine spike occurence times
%
%  -------------------------------------------------
%
%  NCHAN = dhfun(DH.GETSPIKESIZE, FID, BLKID);
%
%  Get number of channels in a given SPIKEx nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike Ntrode
%
%  NCHAN - variable to store number of channels
%
%  -------------------------------------------------
%
%  NSPIKES = dhfun(DH.GETNUMBERSPIKES, FID, BLKID);
%
%  Get number of spikes in a given SPIKEx nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike Ntrode
%
%  NSPIKES - variable to store number of spikes
%
%  -------------------------------------------------
%
%  PERIOD = dhfun(DH.GETSPIKESAMPLEPERIOD, FID, BLKID);
%
%  Get sample period for a given spike nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike Ntrode
%
%  PERIOD - variable to store sample period
%           given in integer (nanoseconds)
%
%  -------------------------------------------------
%
%  [TOTAL, PRETRIG, LOCKOUT] = dhfun(DH.GETSPIKEPARAMS, FID, BLKID);
%
%  Get spike-specific parameters of a spike nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of spike Ntrode
%
%  TOTAL - variable to store number of samples
%          recorded for every spike
%
%  PRETRIG - variable to store number of preTrig samples
%
%  LOCKOUT - variable to store number of lockOut samples
%
%  -------------------------------------------------
%
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
%
%  -------------------------------------------------
%
%  REC = dhfun(DH.GETEV2SIZE, FID);
%
%  Get number of records in the EV02 dataset of the file
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  REC - variable to store number of records
%
%  -------------------------------------------------
%
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
%
%  -------------------------------------------------
%
%  dhfun(DH.WRITESPIKE, FID, BLKID, SAMBEG, SAMEND, CHNBEG, CHNEND, DATA);
%
%  Write contents of a SPIKEx data block from V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a spike nTrode
%  SAMBEG,SAMEND - range of sample numbers to write. Samples from
%                  SAMBEG to SAMEND will be written inclusively.
%  CHNBEG,CHNEND - range of channel numbers to write. Channels from
%                  CHNBEG to CHNEND will be written inclusively.
%  DATA - the data to be written. An int16 matrix sized
%         [SAMEND-SAMBEG+1,CHNEND-CHNBEG+1] is required
%
%  Remarks:
%
%  Starting and ending samples for a single spike or for a group
%  of spikes can be calculated using spike length obtained from
%  function DH.GETSPIKEPARAMS. To obtain time when a particular
%  spike has been triggered, use DH.READSPIKEINDEX
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed
%
%  -------------------------------------------------
%
%  OUTPUT = dhfun(DH.ENUMCONT, FID);
%
%  Enumerate CONTx block identifers in a V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  OUTPUT - variable to store CONTx block identifiers
%           a vector will be returned. All identifiers
%           are sorted in ascending order.
%           Empty matrix is returned if there are no
%           CONT blocks in the file
%
%  Remarks:
%
%  Identifiers returned by this function are safe for
%  using in any CONT-block related functions
%
%  -------------------------------------------------
%
%  OUTPUT = dhfun(DH.ENUMSPIKE, FID);
%
%  Enumerate SPIKEx block identifers in a V3.x file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  OUTPUT - variable to store SPIKEx block identifiers
%           a vector will be returned. All identifiers
%           are sorted in ascending order.
%           Empty matrix is returned if there are no
%           SPIKE blocks in the file
%
%  Remarks:
%
%  Identifiers returned by this function are safe for
%  using in any SPIKE-block related functions
%
%  -------------------------------------------------
%
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
%
%  -------------------------------------------------
%
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
%  -------------------------------------------------
%
%  dhfun(DH.WRITEEV2,FID, RBEG, REND, TIME, EVENT)
%
%  Write contents of the EV02 dataset
%
%  arguments:
%
%  FID - file identifier returned by open function
%  RBEG, REND - range of record numbers to write. Records from
%               RBEG to REND will be written inclusively.
%  TIME - 'time' member of the EV02 structure. Should be a column
%         array of doubles, sized according to number of
%         records to write.
%  EVENT - 'event' member of the EV02 structure. Should be a
%          column array of int32, sized according to number of
%          records to write.
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed
%
%  -------------------------------------------------
%
%  [TRIALNO,STIMNO,OUTCOME,STARTTIME,ENDTIME] = dhfun(DH.GETTRIALMAP,FID)
%
%  Read the entire contents of the TRIALMAP dataset
%
%  arguments:
%  FID - file identifier returned by open function
%  TRIALNO - TrialNo member of TRIALMAP_ITEM struct
%            usually corresponds to the TrialNo member of
%            TD01 item associated with a particular trial
%  STIMNO - StimNo member of TRIALMAP_ITEM struct
%            usually corresponds to the StimNo member of
%            TD01 item associated with a particular trial
%  OUTCOME - Outcome member of TRIALMAP_ITEM struct
%            contains trial outcome code
%  STARTTIME - StartTime member of TRIALMAP_ITEM struct
%            contains start time of trial in nanoseconds
%  ENDTIME  - EndTime member of TRIALMAP_ITEM struct
%            contains end time of trial in nanoseconds
%
%  Remarks:
%
%  Each output argument is returned as array with elements
%  corresponding to individual trials
%
%  -------------------------------------------------
%
%  dhfun(DH.SETTRIALMAP,FID,TRIALNO,STIMNO,OUTCOME,STARTTIME,ENDTIME)
%
%  Write the entire contents of the TRIALMAP dataset
%
%  arguments:
%  FID - file identifier returned by open function
%  TRIALNO - TrialNo member of TRIALMAP_ITEM struct
%            usually corresponds to the TrialNo member of
%            TD01 item associated with a particular trial
%  STIMNO - StimNo member of TRIALMAP_ITEM struct
%            usually corresponds to the StimNo member of
%            TD01 item associated with a particular trial
%  OUTCOME - Outcome member of TRIALMAP_ITEM struct
%            contains trial outcome code
%  STARTTIME - StartTime member of TRIALMAP_ITEM struct
%            contains start time of trial in nanoseconds
%  ENDTIME  - EndTime member of TRIALMAP_ITEM struct
%            contains end time of trial in nanoseconds
%
%  Each input argument (except FID) must be a column array
%  with the same number of elements.
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed.
%  If the TRIALMAP dataset does not exist in the file, it will be created.
%  Any existing TRIALMAP dataset will be deleted and then
%  re-created with a new number of items. Repeated overwriting of
%  TRIALMAP will produce multiple deleted datasets and, consequently,
%  increase in HDF-file size.
%
%  -------------------------------------------------
%
%  [NAMES] = dhfun(DH.ENUMMARKERS,FID)
%
%  Enumerate marker sets in the file
%
%  arguments:
%  FID - file identifier returned by open function
%
%  NAMES - returned cell array of strings which are
%          the names of existing marker sets within
%          the file
%
%  Remarks:
%
%  This function will return an empty cell array
%  if there are no marker sets in the given file.
%
%  -------------------------------------------------
%
%  [TIMES] = dhfun(DH.GETMARKER,FID,MARKERNAME)
%
%  Read the marker set (times of occurence of a
%  marker given its name)
%
%  arguments:
%  FID - file identifier returned by open function
%  MARKERNAME - name of the marker set to read.
%     One can enumerate existing marker sets
%     using DH.ENUMMARKERS
%
%  TIMES - double array of marker occurence times,
%  given in nanoseconds elapsed since acquisition
%  start
%
%  Remarks:
%
%  Markerset will be loaded in memory entirely.
%  Length of the TIMES array will determine the
%  number of occurences of this marker.
%
%  --------------------------------------------------
%
%  dhfun(DH.SETMARKER,FID,MARKERNAME,TIMES)
%
%  Write the marker set (times of occurence of a
%  marker given its name)
%
%  arguments:
%  FID - file identifier returned by open function
%  MARKERNAME - name of the marker set to write.
%  TIMES - double array of marker occurence times,
%      given in nanoseconds elapsed since acquisition
%      start
%
%  Remarks:
%
%  File must be opened in read-write mode ('r+') for
%  this function to succeed. If a markerset with
%  given name already exists in the file, it will
%  be completely overwritten. Length of the TIMES
%  argument will determine the size of the new
%  markerset. Technically, the old markerset
%  being overwritten is first deleted, and then
%  the new one is created. Disk space occupied
%  by the old markerset is never reused, so a
%  repeated overwriting of markersets will make
%  the HDF file to grow.
%
%  --------------------------------------------------
%
%  [NAMES] = dhfun(DH.ENUMINTERVALS,FID)
%
%  Enumerate interval sets in the file
%
%  arguments:
%  FID - file identifier returned by open function
%
%  NAMES - returned cell array of strings which are
%          the names of existing interval sets within
%          the file
%
%  Remarks:
%
%  This function will return an empty cell array
%  if there are no interval sets in the given file.
%
%  --------------------------------------------------
%
%  [TSTART,TEND] = dhfun(DH.GETINTERVAL,FID,INTERVALNAME)
%
%  Read the interval set (start and end times of
%  every occurence of this interval)
%
%  arguments:
%  FID - file identifier returned by open function
%  INTERVALNAME - name of the interval set to read.
%     One can enumerate existing interval sets
%     using DH.ENUMINTERVALS
%
%  TSTART - double array of interval start times,
%           given in nanoseconds
%  TEND -   double array of interval end times,
%           given in nanoseconds
%
%  Remarks:
%
%  Interval set will be loaded in memory entirely.
%  Length of the TSTART and TEND arrays will determine
%  the number of occurences of this interval. Both
%  these arrays will have the same length.
%
%  --------------------------------------------------
%
%  dhfun(DH.SETINTERVAL,FID,INTERVALNAME,TSTART,TEND)
%
%  Write the interval set (start and end times of
%  every occurence of this interval)
%
%  arguments:
%  FID - file identifier returned by open function
%  INTERVALNAME - name of the interval set to write.
%  TSTART - double array of interval start times,
%           given in nanoseconds
%  TEND -   double array of interval end times,
%           given in nanoseconds
%
%  Remarks:
%
%  File must be opened in read-write mode ('r+') for
%  this function to succeed. TSTART and TEND
%  arguments must have the same size. If an interval
%  set with given name already exists in the file,
%  it will be completely overwritten. Length of
%  the TSTART and TEND arrays will determine the
%  size of the new interval set. Technically,
%  the old interval set being overwritten is
%  first deleted, and then the new one is created.
%  Disk space occupied by the old interval set is
%  never reused, so a repeated overwriting of
%  interval sets will make the HDF file grow.
%
%  --------------------------------------------------
%
%  [CLUS] = dhfun(DH.READSPIKECLUSTER,FID,BLKID,RBEG,REND)
%
%  Read the spike cluster information
%  (every spike has a cluster number)
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of spike Ntrode
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%  CLUS      - Cluster number for each spike in the
%              requested range
%
%  --------------------------------------------------
%
%  dhfun(DH.WRITESPIKECLUSTER,FID,BLKID,RBEG,REND,CLUS)
%
%  Write spike cluster information
%  (every spike has an associated cluster number)
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of spike Ntrode
%  RBEG,REND - range of record numbers to write. Records from
%              RBEG to REND will be written inclusively.
%  CLUS      - (UINT8 array) Cluster number for each spike in the
%              requested range
%
%  Remarks:
%
%  This function will fail if the file was not opened for
%  writing. If spike cluster info dataset was not present in
%  the file, it will be created, initially filled with zeros.
%  Otherwise, it will be overwritten in the range [RBEG,REND].
%
%  --------------------------------------------------
%
%  dhfun(DH.WRITESPIKEINDEX,FID,BLKID,RBEG,REND,DATA)
%
%  Write spike timestamp indexes. Every spike has an
%  associated timestamp which is sometimes referred to
%  as index.
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of spike Ntrode
%  RBEG,REND - range of record numbers to write. Records from
%              RBEG to REND will be written inclusively.
%  DATA      - (double array) Timestamps to write. They must
%              be specified in nanoseconds. Numbers are
%              truncated to int64s prior to writing.
%
%  Remarks:
%
%  This function will fail if the file was not opened for
%  writing.
%
%  --------------------------------------------------
%
%  [RESULT] = dhfun(DH.ISCLUSTERINFO_PRESENT,FID,BLKID)
%
%  Check if there is cluster information for a given
%  Spike nTrode.
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of spike Ntrode
%
%  RESULT    - output variable to receive the result.
%              zero means that there is no cluster info,
%              nonzero means the opposite.
%
%  Remarks:
%
%  Use this function to check whether there is cluster
%  information for a spike nTrode before trying to read it.
%  Read functions fail if there is no cluster info.
%
%  --------------------------------------------------
%
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
%
%  --------------------------------------------------
%
%  dhfun(DH.SETCONTCHANDESC,FID,BLKID,GCN,BCN,ABW,MAV,MIV,AC0)
%
%  This function is supposed to modify the A/D descriptive
%  information about a CONT block, which is returned by
%  DH.GETCONTCHANDESC. However, it is not yet implemented.
%
%  --------------------------------------------------
%
%  [GCN,BCN,ABW,MAV,MIV,AC0] = dhfun(DH.GETSPIKECHANDESC,FID,BLKID)
%
%  This function is supposed to return A/D descriptive
%  information for each channel in a SPIKE block,
%  however it is not yet implemented
%
%  --------------------------------------------------
%
%  dhfun(DH.SETSPIKECHANDESC,FID,BLKID,GCN,BCN,ABW,MAV,MIV,AC0)
%
%  This function is supposed to modify the A/D descriptive
%  information about a SPIKE block, which is returned by
%  DH.GETSPIKECHANDESC. However, it is not yet implemented.
%
%  --------------------------------------------------
%
%  dhfun(DH.CREATECR,FID,...)
%
%  This function is supposed to create a CR01 dataset in
%  a V1 file opened for write access. However, it is not yet
%  implemented.
%
%  --------------------------------------------------
%
%  dhfun(DH.CREATECONT,FID,BLKID,SAMPLES,CHANNELS,SAMPLEPERIOD,INDEXSIZE)
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
%
%  --------------------------------------------------
%
%  dhfun(DH.CREATESPIKE,FID,BLKID,SPIKES,CHANNELS,SAMPLEPERIOD,SPIKESAMPLES,PRETRIGSAMPLES,LOCKOUTSAMPLES)
%
%
%  Create a new SPIKE block in a V2 file.
%
%  arguments:
%  FID       - file identifier returned by open function
%  BLKID     - identifier of the new CONT Ntrode
%  SPIKES    - number of recorded spikes for this nTrode
%  CHANNELS  - number of channels in this nTrode
%  SAMPLEPERIOD - sampling time interval for this nTrode,
%              measured in nanoseconds.
%  SPIKESAMPLES - number of samples recorded for every spike
%  PRETRIGSAMPLES - number of preTrig samples
%  LOCKOUTSAMPLES - number of lockOut samples
%
%  Remarks:
%
%  For every SPIKE block in a DAQ-HDF file, its sizes must be
%  known at the time of creation. Once a SPIKE block was created,
%  its sises cannot be changed.
%
%  INDEX dataset of this SPIKE block (spike timestamps) will
%  contain zeros at the time of creation. The application
%  should fill the INDEX dataset with correct values.
%  Some DAQ-HDF reading programs may not be prepared for invalid
%  contents of SPIKEn/INDEX dataset.
%
%  The freshly created SPIKE block will have no CHAN_DESC
%  attribute specified (that attribute contains A/D descriptive
%  information for each channel in the SPIKE block).
%  The application should set this attribute, because many
%  programs which read DAQ-HDF files depend on the presence of it.
%
%  This function will fail if the file was not opened for
%  write access.
%
%  If a SPIKE block with the same BLKID already exists in the
%  file, this function will fail. The existing SPIKE block contents
%  will be preserved.
%
%  --------------------------------------------------
%
%  dhfun(DH.CREATEEV,FID,...)
%
%  This function is supposed to create an EV01 dataset
%  in a V1 file opened for write access. However, it is
%  not yet implemented.
%
%  --------------------------------------------------
%
%  dhfun(DH.CREATEEV2,FID,EVENTS)
%
%  Create a new EV02 dataset in a V2 file.
%
%  arguments:
%  FID       - file identifier returned by open function
%  EVENTS    - number of events in the new EV02 dataset
%
%  Remarks:
%
%  For the EV02 dataset in a DAQ-HDF file, its size must be
%  known at the time of creation. Once the dataset is created,
%  its sise cannot be changed.
%
%  The newly created dataset will contain zeros.
%
%  This function will fail if the file was not opened for
%  write access or if EV02 dataset already exists in the file.
%  If EV02 dataset already existed, its contents are preserved.
%
%  --------------------------------------------------
%
%  dhfun(DH.CREATETD,FID,RECORDS)
%
%  Create a new TD01 dataset in a V2 file.
%
%  arguments:
%  FID       - file identifier returned by open function
%  EVENTS    - number of records in the new TD01 dataset
%
%  Remarks:
%
%  For the TD01 dataset in a DAQ-HDF file, its size must be
%  known at the time of creation. Once the dataset is created,
%  its sise cannot be changed.
%
%  The newly created dataset will contain zeros.
%
%  This function will fail if the file was not opened for
%  write access or if TD01 dataset already exists in the file.
%  If TD01 dataset already existed, its contents are preserved.
%
%  --------------------------------------------------
%
%  dhfun(DH.WRITECONTINDEX, FID, BLKID, RBEG, REND, TIME, OFFSET);
%
%  Write contents of a CONTx index block in V2 file
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  RBEG,REND - range of record numbers to write. Records from
%              RBEG to REND will be written inclusively.
%  TIME, OFFSET - variables holding 'time' and 'offset'
%          fields of index items. TIME is given in nanoseconds
%          (double array), and OFFSET is given in samples
%          (int32 array). Offset is 1-based and references
%          to the beginning of cont dataset.
%
%  Remarks:
%
%  This function will only succeed if the file was opened
%  for writing.
%
%  For additional information, see DH.READCONTINDEX
%
%  -------------------------------------------------
%
%  dhfun(DH.SETCONTSAMPLEPERIOD, FID, BLKID, SAMPLEPERIOD)
%
%  Set sample period for a given continuous nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  SAMPLEPERIOD - variable to store the sample period
%           (integer, given in nanoseconds)
%
%  Remarks:
%
%  This function will fail if the file was not opened for
%  write access.
%
%  -------------------------------------------------
%
%  dhfun(DH.CREATEWAVELET,FID,BLKID,CHANNELS,SAMPLES,FAXIS,SAMPLEPERIOD,INDEXSIZE)
%
%  Creates a new wavelet block
%
%  Arguments:
%  FID - file identifier
%  BLKID     - identifier of the new WAVELET nTrode
%  CHANNELS  - number of channels in this nTrode
%  SAMPLES   - length of the continuously recorded data, in samples
%  FAXIS     - frequency axis of the wavelet setup, in ascending order
%  SAMPLEPERIOD - sampling time interval for this nTrode,
%              measured in nanoseconds.
%  INDEXSIZE - number of items in this WAVELET block's index,
%              also known as number of continuous regions
%              in this piecewise-continuous recording.
%
%  Remarks:
%
%  Wavelet data is produced from CONT data and it has a very close nature.
%  It is piecewise-continuous, can be multichannel, but each sampling
%  instant has multiple 'frequency bin' values.
%
%  For every WAVELET block in a DAQ-HDF file, its sizes must be
%  known at the time of creation. Once a WAVELET block is created,
%  its sises cannot be changed.
%
%  INDEX dataset of this WAVELET block will contain zeros at
%  the time of creation. Application should fill the
%  INDEX dataset with correct values as soon as possible.
%  Some DAQ-HDF reading programs may not be prepared for invalid
%  contents of WAVELETn/INDEX dataset.
%
%  The freshly created WAVELET block will have no CHAN_DESC
%  attribute specified.
%
%  This function will fail if the file was not opened for
%  write access.
%
%  If a WAVELET block with the same BLKID already exists in the
%  file, this function will fail. The existing WAVELET block contents
%  will be preserved.
%
%  -------------------------------------------------
%
%  BLKIDS = dhfun(DH.ENUMWAVELET,FID);
%
%  Enumerate WAVELETx block identifers
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKIDS - variable to store WAVELETx block identifiers.
%           A vector will be returned. All identifiers
%           are sorted in ascending order.
%           Empty matrix is returned if there are no
%           CONT blocks in the file
%
%  Remarks:
%
%  Identifiers returned by this function are safe for
%  using in any WAVELET-block related functions.
%
%  -------------------------------------------------
%
%  [A,PHI] = dhfun(DH.READWAVELET,FID,BLKID,CHNBEG,CHNEND,SAMBEG,SAMEND,FRQBEG,FRQEND);
%
%  Read contents of a WAVELETx data block
%
%  Arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet block
%  CHNBEG,CHNEND - range of channel numbers to read. Channels from
%                  CHNBEG to CHNEND will be read inclusively.
%  SAMBEG,SAMEND - range of sample numbers to read. Samples from
%                  SAMBEG to SAMEND will be read inclusively.
%  FRQBEG,FRQEND - range of frequency bins to read. Frequency
%                  bins from FRQBEG to FRQEND will be read inclusively.
%
%  Outputs:
%
%  A - (uint16) variable to store the magnitude values. A 3-dimensional array
%      sized [FRQEND-FRQBEG+1,SAMEND-SAMBEG+1,CHNEND-CHNBEG+1] will be returned.
%      If only one channel was requested, the return value will be a
%      2D matrix. Magnitude values are unsigned, scaled,
%      and take integer values from 0 to 65535. To translate them into
%      native floating-point representation, information from wavelet
%      index must be used (see DH.READWAVELETINDEX).
%  PHI - (int8) variable to store the phase values. It will have the same
%      sizes as A. Phase values are scaled and take integer values from
%      -127 to 127. To translate them into radians, use the following
%      formula: phi_rad = phi*pi/127.0;
%
%  -------------------------------------------------
%
%  dhfun(DH.WRITEWAVELET,FID,BLKID,CHNBEG,CHNEND,SAMBEG,SAMEND,FRQBEG,FRQEND,A,PHI)
%
%  Write contents of a WAVELETx data block
%
%  Arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet block
%  CHNBEG,CHNEND - range of channel numbers to write. Channels from
%                  CHNBEG to CHNEND will be written inclusively.
%  SAMBEG,SAMEND - range of sample numbers to write. Samples from
%                  SAMBEG to SAMEND will be written inclusively.
%  FRQBEG,FRQEND - range of frequency bins to write. Frequency
%                  bins from FRQBEG to FRQEND will be written inclusively.
%
%  A - (uint16) magnitude values. A 3-dimensional array
%      sized [FRQEND-FRQBEG+1,SAMEND-SAMBEG+1,CHNEND-CHNBEG+1] is required.
%      If only one channel was requested, the array should be a
%      2D matrix.
%
%  PHI - (int8) phase values. It should have the same sizes as A.
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed.
%
%  Magnitude and phase information in DAQ-HDF files is scaled to
%  save disk space. See DH.READWAVELET for details.
%
%  -------------------------------------------------
%
%  [time,offset,scaling] = dhfun(DH.READWAVELETINDEX,FID,BLKID,RBEG,REND);
%
%  Read contents of a WAVELETx index block
%
%  Arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet nTrode
%  RBEG,REND - range of record numbers to read. Records from
%              RBEG to REND will be read inclusively.
%
%  Outputs:
%
%  TIME, OFFSET, SCALING - variables to store 'time', 'offset'
%          and 'scaling' fields of index items. TIME is given
%          in nanoseconds (double array), OFFSET is given in samples
%          (int32 array), and SCALING is a double array. Offset is
%          1-based and references to the beginning of wavelet dataset.
%
%  Remarks:
%
%  Index allows to calculate range of samples for a particular
%  range of time. Each index item is associated a contiguous
%  section of recording, where individual offsets can be
%  calculated given starting time and sample period. Between
%  these contiguous sections there are gaps. Ending time for
%  a section is calculated using the start offset for the next
%  section. Be sure to check that a time range does not
%  include gaps. The index system is similar to that of CONT blocks.
%
%  SCALING values are used to restore floating-point values of
%  wavelet magnitude. All values within contiguous regions of
%  recording must be multiplied by corresponding values of
%  SCALING.
%
%  To restore the value of an arbitrary sample within wavelet block,
%  one must first find to which region does it belong. Then the
%  region's scaling value must be fetched and multipied by that sample's
%  raw value (16-bit unsigned integer).
%
%  -------------------------------------------------
%
%  dhfun(DH.WRITEWAVELETINDEX,FID,BLKID,RBEG,REND,TIME,OFFSET,SCALING);
%
%  Write contents of a WAVELETx index block
%
%  Arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of continuous nTrode
%  RBEG,REND - range of record numbers to write. Records from
%              RBEG to REND will be written inclusively.
%  TIME (double), OFFSET (int32), SCALING (double) - new
%          values for 'time', 'offset' and 'scaling'
%          fields of index items. TIME is given in nanoseconds,
%          OFFSET is given in samples. Offset is 1-based and
%          references to the beginning of wavelet dataset.
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed.
%
%  For more information, see DH.READWAVELETINDEX
%
%  -------------------------------------------------
%
%  [NCHAN,NSAM,NF] = dhfun(DH.GETWAVELETSIZE,FID,BLKID);
%
%  Get number of samples, number of channels and number of frequency
%  bins for a given wavelet nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of wavelet nTrode
%
%  Outputs:
%
%  NCHAN - variable to store number of channels
%  NSAMP - variable to store number of samples
%  NF - variable to store number of frequency bins
%
%
%  -------------------------------------------------
%
%  NITEMS = dhfun(DH.GETWAVELETINDEXSIZE, FID, BLKID);
%
%  Get number of items in the index of a WAVELETx block
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%
%  Output:
%
%  NITEMS - variable to store number of items in the index
%
%  -------------------------------------------------
%
%  SAMPER = dhfun(DH.GETWAVELETSAMPLEPERIOD, FID, BLKID);
%
%  Get sample period for a given wavelet nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%
%  Output:
%
%  SAMPER - variable to store the sample period
%           (given in nanoseconds)
%
%  -------------------------------------------------
%
%  dhfun(DH.SETWAVELETSAMPLEPERIOD, FID, BLKID, SAMPER);
%
%  Set sample period for a given wavelet nTrode
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%  SAMPER - new sample period (given in nanoseconds)
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed.
%
%  -------------------------------------------------
%
%  [...] = dhfun(DH.GETWAVELETCHANDESC,FID,BLKID,...)
%
%  dhfun(DH.SETWAVELETCHANDESC,FID,BLKID,...)
%
%  These functions are unimplemented, and argument list for them
%  is not yet specified.
%
%  -------------------------------------------------
%
%  FAXIS = dhfun(DH.GETWAVELETFAXIS,FID,BLKID);
%
%  Get frequency axis of a wavelet nTrode.
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%
%  Output:
%
%  FAXIS - (double vector) frequency axis of the requested
%          wavelet nTrode
%
%  -------------------------------------------------
%
%  dhfun(DH.SETWAVELETFAXIS,FID,BLKID,FAXIS);
%
%  Set frequency axis of a wavelet nTrode.
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%  FAXIS - (double vector) new frequency axis of the requested
%          wavelet nTrode
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed.
%
%  -------------------------------------------------
%
%  [W0,ST_HL] = dhfun(DH.GETWAVELETMORLETPARAMS,FID,BLKID);
%
%  Get parameters of the Morlet's wavelet system used to obtain
%  a wavelet block's data.
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%
%  Output
%  W0    - (scalar) Time/frequency resolution parameter
%  ST_HL - (scalar) FIR Wavelet truncation parameter
%
%  Remarks:
%
%  The values of W0 and ST_HL are not required for reading and
%  interpreting wavelet data, they rather store information
%  about how this wavelet block was produced from signal data.
%
%  -------------------------------------------------
%
%  dhfun(DH.SETWAVELETMORLETPARAMS,FID,BLKID,W0,ST_HL);
%
%  Set parameters of the Morlet's wavelet system used to obtain
%  a wavelet block's data.
%
%  arguments:
%
%  FID - file identifier returned by open function
%  BLKID - identifier of a wavelet nTrode
%  W0    - (scalar) Time/frequency resolution parameter
%  ST_HL - (scalar) FIR Wavelet truncation parameter
%
%  Remarks:
%
%  File must be opened with write access enabled (modes 'r+' and 'w')
%  for the write operation to succeed.
%
%  -------------------------------------------------
%
%  FIDS = dhfun(DH.LISTOPENFIDS);
%
%  Get identifiers of all files that are currently opened with
%  DHFUN.
%
%  Output:
%
%  FIDS - vector of integers, file identifiers. Any of the
%         returned FIDS can be used to access the respective
%         DAQ-HDF files. If no files were opened, this function
%         returns an empty matrix.
%
%  Remarks:
%
%  It is recommended that this function is used for debug purposes
%  only, such as from the command line, and not used in released
%  applications. Doing otherwise makes the application program structure
%  unclear and prone to errors and compatibility issues.
%
%  -------------------------------------------------
%
%  FILEINFO = dhfun(DH.GETFIDINFO,FID);
%
%  Get information about an opened file.
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  Output:
%
%  FILEINFO - structure with fields:
%       name (string) - filename, as it was supplied to the open function.
%       -- more fields may be added in future
%
%  Remarks:
%
%  It is recommended that this function is used for debugging and
%  error handling purposes only. Doing otherwise makes the application
%  program structure unclear and prone to errors and compatibility issues.
%
%  It is possible that more fields with additional information will be added
%  to the FILEINFO structure in future versions of DHFUN.
%
%  -------------------------------------------------
%
%  [OPNAMES,OPINFOS] = dhfun(DH.GETOPERATIONINFOS,FID);
%
%  Get processing history of an opened DAQ-HDF file
%
%  arguments:
%
%  FID - file identifier returned by open function
%
%  Outputs:
%  OPNAMES (cell vector of strings) - operation names,
%       in the same order as they appear in the DAQ-HDF file
%  OPINFOS (cell vector of struct scalars) - operation
%       information, whatever data is written about them
%       in the DAQ-HDF file.
%
%  Remarks:
%
%  Each item of OPNAMES corresponds to an item of OPINFOS.
%  OPINFOS items are, in general, structs with a different
%  set of fields. Sometimes, field names may contain spaces,
%  which makes it more difficult to access them from Matlab.
%  The following HDF data types are supported in processing
%  history entries, and translated to the corresponding Matlab
%  data types:
%
%  H5T_STRING scalars
%  H5T_INTEGER scalars and arrays (signed and unsigned, 8, 16, 32 and 64-bit)
%  H5T_FLOAT scalars and arrays (32 and 64-bit)
%  H5T_COMPOUND scalars and arrays (struct arrays, converted to Matlab struct arrays).
%      Supported field types are:
%          H5T_INTEGER scalars (signed and unsigned, 8, 16, 32 and 64-bit)
%          H5T_FLOAT scalars (32 and 64-bit)
%      This means, for instance, that nested structures and
%      structures of arrays are not allowed.
%
%  More advanced datatype support may be added in future, if
%  a need arises.
%
%  -------------------------------------------------
%
%
%  (c) 2001-2006 Michael Borisov, Bremen Brain Research Institute.
%  (c) 2023 Joscha Schmiedt, Bremen, Brain Research Institute

function varargout = dhfun(varargin)
persistent DH;
if isempty(DH)
    DH = dh.constants();
end

FUNCTION = varargin{1};
varargin = varargin(2:end);


switch FUNCTION
    
    %  ----- General information, debugging ------------
    case DH.GETVERSION
        varargout = {dh.getversion(varargin{:})};
        
        
    case DH.LISTOPENFIDS
        varargout = {[]};
    
    %
    %  --- General file service ------------------------
    %
    case DH.OPEN
        varargout = {dh.open(varargin{:})};
        
    case DH.CLOSE
        dh.close(varargin{:});
        
    case DH.GETFIDINFO
        error('Not implemented yet');
        
    case DH.GETOPERATIONINFOS
        varargout = cell(1,2);
        [varargout{:}] = dh.getoperationinfos(varargin{:});
        

        
    case DH.GETDAQVERSION
        error('Not implemented yet');
        
    %
    %  --- DAQ-HDF V1 continuous recordings ------------
    %
    case DH.CREATECR
        error('Not implemented yet');
        
    case DH.READCR
        error('Not implemented yet');
        
    case DH.WRITECR
        error('Not implemented yet');
        
    case DH.GETCRSIZE
        error('Not implemented yet');
        
    case DH.GETCRADCBITWIDTH
        error('Not implemented yet');
        
    case DH.GETCRSAMPLEPERIOD
        error('Not implemented yet');
        
    case DH.GETCRSTARTTIME
        error('Not implemented yet');
        
    case DH.GETCRMAXVOLTAGERANGE
        error('Not implemented yet');
        
    case DH.GETCRMINVOLTAGERANGE
        error('Not implemented yet');
        
    case DH.GETCRCALINFO
        error('Not implemented yet');
        
    case DH.SETCRCALINFO
        error('Not implemented yet');
    
    %
    %  --- DAQ-HDF V1 event triggers -------------------
    %
    case DH.CREATEEV
        error('Not implemented yet');
        
    case DH.READEV
        error('Not implemented yet');

    case DH.WRITEEV
        error('Not implemented yet');
        
    case DH.GETEVSIZE
        error('Not implemented yet');
        
    %
    %  --- DAQ-HDF all versions TD01 records -----------
    %
    case DH.CREATETD
        error('Not implemented yet');
        
    case DH.READTD
        error('Not implemented yet');
        
    case DH.WRITETD
        error('Not implemented yet');
        
    case DH.GETTDSIZE
        error('Not implemented yet');
    
    %
    %  --- DAQ-HDF V2 CONT nTrodes ---------------------
    %
    case DH.CREATECONT
        error('Not implemented yet');
        
    case DH.ENUMCONT
        varargout = {dh.enumcont(varargin{:})};
        
    case DH.READCONT
        varargout = {dh.readcont(varargin{:})};
        
    case DH.WRITECONT
        error('Not implemented yet');
        
    case DH.READCONTINDEX
        [time, offset] = dh.readcontindex(varargin{:});
        varargout = {time, offset};
        
    case DH.WRITECONTINDEX
        error('Not implemented yet');
        
    case DH.GETCONTSIZE
         [nsamp, nchan] = dh.getcontsize(varargin{:});
         varargout = {nsamp, nchan};
        
    case DH.GETCONTINDEXSIZE
        varargout = {dh.getcontindexsize(varargin{:})};        
        
    case DH.GETCONTSAMPLEPERIOD
        varargout = {dh.getcontsampleperiod(varargin{:})};
        
    case DH.SETCONTSAMPLEPERIOD
        error('Not implemented yet');
        
    case DH.GETCONTCALINFO
        varargout = {dh.getcontcalinfo(varargin{:})};
        
    case DH.SETCONTCALINFO
        error('Not implemented yet');
        
    case DH.GETCONTCHANDESC
        varargout = cell(1,6);
        [varargout{:}] = dh.getcontchandesc(varargin{:});
        
    case DH.SETCONTCHANDESC
        error('Not implemented yet');
        
    %
    %  --- DAQ-HDF V2 SPIKE nTrodes --------------------
    %
    case DH.CREATESPIKE
        error('Not implemented yet');
        
    case DH.ENUMSPIKE
        varargout = {dh.enumspike(varargin{:})};
        
    case DH.READSPIKE
        varargout = {dh.readspike(varargin{:})};
        
    case DH.WRITESPIKE
        error('Not implemented yet');
        
    case DH.READSPIKEINDEX
        varargout = {dh.readspikeindex(varargin{:})};
        
    case DH.WRITESPIKEINDEX
        error('Not implemented yet');
        
    case DH.ISCLUSTERINFO_PRESENT
        varargout = {dh.isclusterinfo_present(varargin{:})};
        
    case DH.READSPIKECLUSTER
        varargout = {dh.readspikecluster(varargin{:})};
        
    case DH.WRITESPIKECLUSTER
        error('Not implemented yet');
        
    case DH.GETSPIKESIZE
        varargout = {dh.getspikesize(varargin{:})};
        
    case DH.GETNUMBERSPIKES
        varargout = {dh.getnumberspikes(varargin{:})};
        
    case DH.GETSPIKESAMPLEPERIOD
        varargout = {dh.getspikesampleperiod(varargin{:})};
        
    case DH.GETSPIKEPARAMS
        varargout = cell(1,3);
        [varargout{:}] = dh.getspikeparams(varargin{:});
        
    case DH.GETSPIKECHANDESC
        error('Not implemented yet');
        
    case DH.SETSPIKECHANDESC
        error('Not implemented yet');

    %
    %  --- WAVELET interface ---------------------------
    %
    case DH.CREATEWAVELET
        error('Not implemented yet');
        
    case DH.ENUMWAVELET
        varargout = {dh.enumwavelet(varargin{:})};
        
    case DH.READWAVELET
        varargout = cell(1,2);
        [varargout{:}] = dh.readwavelet(varargin{:});
        
    case DH.WRITEWAVELET
        error('Not implemented yet');
        
    case DH.READWAVELETINDEX
        varargout = cell(1,3);
        [varargout{:}] = dh.readwaveletindex(varargin{:});        
        
    case DH.WRITEWAVELETINDEX
        error('Not implemented yet');
        
    case DH.GETWAVELETSIZE
        varargout = cell(1,3);
        [varargout{:}] = dh.getwaveletsize(varargin{:});
        
    case DH.GETWAVELETINDEXSIZE
        varargout = {dh.getwaveletindexsize(varargin{:})};
        
    case DH.GETWAVELETSAMPLEPERIOD
        varargout = {dh.getwaveletsampleperiod(varargin{:})};
        
    case DH.SETWAVELETSAMPLEPERIOD
        error('Not implemented yet');
        
    case DH.GETWAVELETCHANDESC
        error('Not implemented yet');
        
    case DH.SETWAVELETCHANDESC
        error('Not implemented yet');
        
    case DH.GETWAVELETFAXIS
        varargout = {dh.getwaveletfaxis(varargin{:})};        
        
    case DH.SETWAVELETFAXIS
        error('Not implemented yet');
        
    case DH.GETWAVELETMORLETPARAMS
        error('Not implemented yet');
        
    case DH.SETWAVELETMORLETPARAMS
        error('Not implemented yet');
        
    %
    %  --- DAQ-HDF V2 EV02 triggers --------------------
    %
    case DH.CREATEEV2
        error('Not implemented yet');
        
    case DH.READEV2
        varargout = cell(1,2);
        [varargout{:}] = dh.readev2(varargin{:});

        
    case DH.WRITEEV2
        error('Not implemented yet');
        
    case DH.GETEV2SIZE
        varargout = {dh.getev2size(varargin{:})};
        
    %
    %  ---------- TRIALMAP interface -------------------
    %
    case DH.GETTRIALMAP
        varargout = cell(1,5);
        [varargout{:}] = dh.gettrialmap(varargin{:});        
        
    case DH.SETTRIALMAP
        error('Not implemented yet');
        
    %
    %  ---------- MARKER interface ---------------------
    %
    case DH.ENUMMARKERS
        error('Not implemented yet');
        
    case DH.GETMARKER
        error('Not implemented yet');
        
    case DH.SETMARKER
        error('Not implemented yet');
        
    %
    %  ---------- INTERVAL interface -------------------
    %
    case DH.ENUMINTERVALS
        error('Not implemented yet');
        
    case DH.GETINTERVAL
        error('Not implemented yet');
        
    case DH.SETINTERVAL
        error('Not implemented yet');
        
        

        
        
end
