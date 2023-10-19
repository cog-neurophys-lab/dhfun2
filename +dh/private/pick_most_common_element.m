function [mostCommon, iOutput] = pick_most_common_element(input)
    uniqueInput = unique(input);
    [count, index] = histc(input,uniqueInput);
    [~, iMax] = max(count);
    iOutput = index == iMax;
    mostCommon = uniqueInput(iMax);
end