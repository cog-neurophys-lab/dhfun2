%  dhfun.close(FID, <OPERATION_NAME,OPERATOR_NAME,TOOL_NAME,OPERATION_INFO> );
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

function close(fid, varargin)

arguments 
    fid double
end




