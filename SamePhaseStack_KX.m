function stackSeri = SamePhaseStack_KX(sigFreq, sampRate, dataSeri)
dataLen = max(size(dataSeri));
if sampRate ~= floor(sampRate)
    warning('Sample Rate Should Be a Integer! Decimal abandoned!');
    sampRate = floor(sampRate)
end
if sigFreq ~= floor(sigFreq)
    warning('signal Frequency Should Be a Integer! Decimal abandoned!');
    sigFreq = floor(sigFreq);
end

stackLen = sampRate/sigFreq;
if stackLen ~= floor(stackLen)
    error('Can not stack that, due to signal and sample rate mismatch');
end

stackC = dataLen/stackLen;
if stackC ~= floor(stackC)
    error('Can not stack that, due to stack and record length mismatch');
end

stackBuff = zeros(stackLen, 1);
for i=1:stackC
    stackBuff = stackBuff+dataSeri((i-1)*stackLen+1:i*stackLen);
end
stackSeri = stackBuff/stackC;
end