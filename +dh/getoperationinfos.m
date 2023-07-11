% [OPNAMES,OPINFOS] = dhfun(DH.GETOPERATIONINFOS,FID);
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
function [opnames, opinfos] = getoperationinfos(fid)


filename = get_filename(fid);

info = h5info(filename, '/Operations');

opnames = cell(length(info.Groups), 1);
opinfos = cell(length(info.Groups), 1);

iOp = 1;
for operation = info.Groups'
    
    % Group '/Operations/000_Recording'         
    name = string(operation.Name).split('_');    
    opnames{iOp} = name(end).char();


    opinfo = [];
    for attributes = operation.Attributes'
        fieldName = string(attributes.Name).replace(' ', '_').char();                
        opinfo.(fieldName) = attributes.Value;
    end
    opinfos{iOp} = opinfo;
    
    iOp = iOp+1;
end

