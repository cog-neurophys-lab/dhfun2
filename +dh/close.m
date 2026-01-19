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

% If operation parameters are provided, add operation before closing
if ~isempty(varargin)
    % Get file name from file identifier
    filename = H5F.get_name(fid);

    % Parse input arguments
    if length(varargin) >= 1
        operation_name = varargin{1};
    else
        error('Operation name must be provided');
    end

    % Build arguments for createoperation
    create_args = {filename, operation_name};

    % Add operator name if provided
    if length(varargin) >= 2 && ~isempty(varargin{2})
        create_args = [create_args, {'Operator', varargin{2}}];
    end

    % Add tool name if provided
    if length(varargin) >= 3 && ~isempty(varargin{3})
        create_args = [create_args, {'Tool', varargin{3}}];
    end

    % Add operation info struct fields as additional attributes
    if length(varargin) >= 4 && isstruct(varargin{4})
        operation_info = varargin{4};
        fields = fieldnames(operation_info);
        for i = 1:length(fields)
            create_args = [create_args, {fields{i}, operation_info.(fields{i})}];
        end
    end

    % Create the operation entry
    dh.createoperation(create_args{:});
end

H5F.close(fid);




