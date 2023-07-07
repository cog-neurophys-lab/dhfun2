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

function idCont = enumcont(filename)

arguments
    filename char
end

info = h5info(filename);
spikeGroups = info.Groups( ...
    cellfun(@(x) string(x).startsWith("/CONT") , {info.Groups.Name}) ...
    );

idCont = cellfun(@(x) str2double(x(6:end)), {spikeGroups.Name});

end