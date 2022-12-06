function FreqSig=read_Keysight9020(traceName)
if ~size(traceName,1)
    error('Empty File Name Detected, Exit Now.');
end
[dataDir, dataName, ~] = fileparts(traceName);
opt01 = detectImportOptions(traceName);
opt01.DataLines = [46 Inf];
opt01.VariableNames(1:2) = {'Freq','Amp'};
traceDataBuff=readtable(traceName, opt01);
FreqSig.Freq = traceDataBuff.Freq;
FreqSig.Amp = traceDataBuff.Amp;