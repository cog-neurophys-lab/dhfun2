function filtered = filter_by_name(structArray, selectedName)
% filtered = filter_by_name(structArray, selectedName)

filtered = structArray(cellfun(@(name) string(name) == selectedName, {structArray.Name}));

end
