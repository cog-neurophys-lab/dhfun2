function createoperation(filename, operation_name, varargin)
%CREATEOPERATION Add an operation entry to the Operations group
%
%   CREATEOPERATION(FILENAME, OPERATION_NAME) adds an operation entry
%   to the /Operations group with the given name and current date/time.
%
%   CREATEOPERATION(FILENAME, OPERATION_NAME, 'Tool', TOOL) specifies
%   the tool name (default: 'MATLAB')
%
%   CREATEOPERATION(FILENAME, OPERATION_NAME, 'Operator', OPERATOR)
%   specifies the operator name (default: current USERNAME)
%
%   Additional name-value pairs can be provided to add custom attributes
%   to the operation entry.
%
% Example:
%   dh.createoperation('file.dh5', 'FileCreation', 'Tool', 'create_minimal_dh5');
%   dh.createoperation('file.dh5', 'Filtering', 'Tool', 'filter_v1.0', ...
%                      'FilterType', 'Butterworth', 'Cutoff', '100 Hz');
%
% See also: dh.open

% Parse input arguments
p = inputParser;
p.KeepUnmatched = true;  % Allow additional parameters
addRequired(p, 'filename', @ischar);
addRequired(p, 'operation_name', @ischar);
addParameter(p, 'Tool', 'MATLAB', @ischar);
addParameter(p, 'Operator', get_default_operator(), @ischar);
parse(p, filename, operation_name, varargin{:});

tool_name = p.Results.Tool;
operator_name = p.Results.Operator;

% Get any unmatched (additional) attributes
extra_attrs = p.Unmatched;

% Open the file
plist = 'H5P_DEFAULT';
file_id = H5F.open(filename, 'H5F_ACC_RDWR', plist);

try
    % Create /Operations group if it doesn't exist
    try
        ops_group = H5G.open(file_id, '/Operations');
    catch
        ops_group = H5G.create(file_id, '/Operations', plist, plist, plist);
    end

    % Find the next operation number
    info = h5info(filename, '/Operations');
    op_num = length(info.Groups);

    % Create operation subgroup with 3-digit number
    op_name = sprintf('%03d_%s', op_num, operation_name);
    op_group = H5G.create(ops_group, op_name, plist, plist, plist);

    % Create string type for attributes
    str_type = H5T.copy('H5T_C_S1');
    H5T.set_size(str_type, 'H5T_VARIABLE');
    attr_space = H5S.create('H5S_SCALAR');

    % Write Tool attribute
    attr = H5A.create(op_group, 'Tool', str_type, attr_space, plist);
    H5A.write(attr, str_type, {tool_name});
    H5A.close(attr);

    % Write Operator name attribute
    attr = H5A.create(op_group, 'Operator name', str_type, attr_space, plist);
    H5A.write(attr, str_type, {operator_name});
    H5A.close(attr);

    H5S.close(attr_space);
    H5T.close(str_type);

    % Write Date attribute
    date_type = H5T.create('H5T_COMPOUND', 7);
    H5T.insert(date_type, 'Year', 0, 'H5T_NATIVE_SHORT');
    H5T.insert(date_type, 'Month', 2, 'H5T_NATIVE_SCHAR');
    H5T.insert(date_type, 'Day', 3, 'H5T_NATIVE_SCHAR');
    H5T.insert(date_type, 'Hour', 4, 'H5T_NATIVE_SCHAR');
    H5T.insert(date_type, 'Minute', 5, 'H5T_NATIVE_SCHAR');
    H5T.insert(date_type, 'Second', 6, 'H5T_NATIVE_SCHAR');

    attr_space = H5S.create('H5S_SCALAR');
    attr = H5A.create(op_group, 'Date', date_type, attr_space, plist);

    % Get current date and time
    c = clock;
    date_data.Year = int16(c(1));
    date_data.Month = int8(c(2));
    date_data.Day = int8(c(3));
    date_data.Hour = int8(c(4));
    date_data.Minute = int8(c(5));
    date_data.Second = int8(floor(c(6)));

    H5A.write(attr, date_type, date_data);
    H5A.close(attr);
    H5S.close(attr_space);
    H5T.close(date_type);

    % Write any extra attributes as strings
    if ~isempty(fieldnames(extra_attrs))
        str_type = H5T.copy('H5T_C_S1');
        H5T.set_size(str_type, 'H5T_VARIABLE');
        attr_space = H5S.create('H5S_SCALAR');

        fields = fieldnames(extra_attrs);
        for i = 1:length(fields)
            attr = H5A.create(op_group, fields{i}, str_type, attr_space, plist);
            value = extra_attrs.(fields{i});
            if ~ischar(value)
                value = num2str(value);
            end
            H5A.write(attr, str_type, {value});
            H5A.close(attr);
        end

        H5S.close(attr_space);
        H5T.close(str_type);
    end

    H5G.close(op_group);
    H5G.close(ops_group);

catch ME
    H5F.close(file_id);
    rethrow(ME);
end

H5F.close(file_id);

    function operator = get_default_operator()
        operator = getenv('USER');  % Linux/macOS
        if isempty(operator)
            operator = getenv('USERNAME');  % Windows
        end
        if isempty(operator)
            operator = 'unknown';
        end
    end


end
