function [cap, frq]=nameSolveCapFreq(traceName, capPoint, frqPoint)
if ~size(traceName,1)
    error('Empty File Name Detected, Exit Now.');
end
traceName = char(traceName);

cap = str2num(traceName(floor(abs(capPoint(1):capPoint(2)))));
frq = str2num(traceName(floor(abs(frqPoint(1):frqPoint(2)))));