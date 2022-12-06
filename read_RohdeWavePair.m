function OSCdata=read_RohdeWavePair(kaixinName)
if ~size(kaixinName,1)
    error('Empty File Name Detected, Exit Now.');
end
[dataDir, dataName, ~] = fileparts(kaixinName);
% fileCut = strsplit(kaixinName,'.');
% if ~size(cell2mat(fileCut(1)),1)
%     netName = strcat('.',cell2mat(fileCut(2)));
% else
%     netName = cell2mat(fileCut(1));
% end
% dataName = strsplit(netName,'/');
dataName = erase(dataName, '.Wfm');
waveName = strcat(dataDir, '/', dataName,'.Wfm.csv');
infoName = strcat(dataDir, '/', dataName,'.csv');
opt01 = detectImportOptions(waveName);
% opt01.DataRange = 5;
opt01.DataLines = [1 Inf];

switch size(opt01.VariableNames,2)
    case 1
        opt01.VariableNames(1) = {'Chn01'};
        chnC = 1;
    case 2
        opt01.VariableNames(1:2) = {'Chn01','Chn02'};
        chnC = 2;
    case 3
        opt01.VariableNames(1:3) = {'Chn01','Chn02','Chn03'};
        chnC = 3;
    case 4
        opt01.VariableNames(1:4) = {'Chn01','Chn02','Chn03','Chn04'};
        chnC = 4;
    otherwise
        error('WaveForm file size exceeded! Check again!');
end

OSCdataChn = readtable(waveName, opt01);

% Read other parameters
fileT = fopen(infoName,'r');
RecordL = 20000;
Resol = 2e-007;
xRange = [-0.002,0.002];
while ~feof(fileT)
    fileLi = fgetl(fileT);
    identy = strfind(fileLi,'Resolution');
    if identy==1
        ResolBuff = strsplit(fileLi,':');
        Resol = str2double(cell2mat(ResolBuff(2)));
        break
    end
end
while ~feof(fileT)
    fileLi = fgetl(fileT);
    identy = strfind(fileLi,'XStart');
    if identy==1
        RecordLBuff = strsplit(fileLi,':');
        xRange(1) = str2double(cell2mat(RecordLBuff(2)));
        break
    end
end
while ~feof(fileT)
    fileLi = fgetl(fileT);
    identy = strfind(fileLi,'XStop');
    if identy==1
        RecordLBuff = strsplit(fileLi,':');
        xRange(2) = str2double(cell2mat(RecordLBuff(2)));
        break
    end
end
while ~feof(fileT)
    fileLi = fgetl(fileT);
    identy = strfind(fileLi,'SignalRecordLength');
    if identy==1
        RecordLBuff = strsplit(fileLi,':');
        RecordL = str2double(cell2mat(RecordLBuff(2)));
        break
    end
end
fclose(fileT);

% Output Data
OSCdata.Name = dataName;
OSCdata.FullName = strcat(dataDir, '/', dataName);
% OSCdata.FigName = strcat(dataDir, '/Figures', dataName,'.Wfm.csv');
OSCdata.RecordL = RecordL;
OSCdata.Resol = Resol;
OSCdata.xRange = xRange;
% OSCdata.DateTime = DateD;
OSCdata.SampleRate = 1/Resol;

switch chnC
    case 1
        OSCdata.Chn01 = OSCdataChn.Chn01;
%         OSCdata.Chn02 = defaultData;
%         OSCdata.Chn03 = defaultData;
%         OSCdata.Chn04 = defaultData;
    case 2
        OSCdata.Chn01 = OSCdataChn.Chn01;
        OSCdata.Chn02 = OSCdataChn.Chn02;
%         OSCdata.Chn03 = defaultData;
%         OSCdata.Chn04 = defaultData;
    case 3
        OSCdata.Chn01 = OSCdataChn.Chn01;
        OSCdata.Chn02 = OSCdataChn.Chn02;
        OSCdata.Chn03 = OSCdataChn.Chn03;
%         OSCdata.Chn04 = defaultData;
    case 4
        OSCdata.Chn01 = OSCdataChn.Chn01;
        OSCdata.Chn02 = OSCdataChn.Chn02;
        OSCdata.Chn03 = OSCdataChn.Chn03;
        OSCdata.Chn04 = OSCdataChn.Chn04;
    otherwise
        OSCdata.Chn01 = NaN(RecordL,1);
      
end
[OSCdata.Len,~] = size(OSCdata.Chn01);
Stack = OSCdata.Len*Resol/(xRange(2)-xRange(1));
OSCdata.Stack = floor(Stack);
if OSCdata.Stack ~= Stack
    warning('data not right, not integer stack!');
end

end
% toc;
% table(end,:)=[];
% table