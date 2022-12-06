function [ImpeAna, dataName, dataDir]=read_KeysightE4990A(traceName)
if ~size(traceName,1)
    error('Empty File Name Detected, Exit Now.');
end
[dataDir, dataName, ~] = fileparts(traceName);
opt01 = detectImportOptions(traceName);
if (strcmp(opt01.VariableNames(1), 'Frequency_Hz_'))
else
    error('Something Wrong with the Format of the Data File!');
end
opt01.VariableNames(1) = {'Freq'};
ImpeAna=readtable(traceName, opt01);