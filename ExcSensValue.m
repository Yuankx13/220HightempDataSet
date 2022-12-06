%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw Exec and Sens signal, then do some calculate
clear all;

%% Import data-
dirName='./Test2/thermalField03/';
dataCluster=string(ls(dirName));
FreqExec = 1000;
if isunix()
    [dataCluster,~]=strsplit(dataCluster);
end
dataHandle=contains(dataCluster, '.Wfm.csv');

%% Pick up valid Files
dataCluster(dataHandle==0)=[];
fileCluster=strcat(dirName, dataCluster);
dataCount=length(dataCluster);

%% Load Valid Data
tic;
% parpool;
parfor i=1:dataCount
    OSCdata(i)=read_RohdeWavePair(fileCluster(i));
end
toc;
%% Check if the order is right
if mod(dataCount, 3)
    error('Data count not right, Check again.');
end
for i=1:dataCount/3
    if contains(OSCdata((i-1)*3+1).Name, '_+')
        if contains(OSCdata((i-1)*3+2).Name, '_-')
            if contains(OSCdata(i*3).Name, '_0')
                continue
            end
        end
    end
    error(strcat(OSCdata(i*3).Name, 'Data Order not right, Check again.'));
end
toc;
for i = 1:dataCount/3
    if OSCdata((i-1)*3+1).Len == OSCdata((i-1)*3+2).Len
        if OSCdata((i-1)*3+1).Len == OSCdata(i*3).Len
            continue
        end
    end
    error(strcat(OSCdata(i*3).Name, 'Data Length mismatch, Check again!'));
end

%% Get Those Data into Order
thermalDataP = OSCdata(1:3:end);
thermalDataN = OSCdata(2:3:end);
thermalData0 = OSCdata(3:3:end);
parfor i=1:dataCount/3
    thermalBuff = char(thermalDataP(i).Name);
    thermalPoint(i) = string(thermalBuff(1:end-2));
end
toc;

%% Draw Raw Data Series
mkdir(strcat(dirName, 'RawDataFigures/'));
parfor i=1:dataCount
    plot_RawDualChannel(i, OSCdata(i).xRange*OSCdata(i).Stack, OSCdata(i).SampleRate,...
    OSCdata(i).Name, strcat(dirName, 'RawDataFigures/', OSCdata(i).Name),...
    OSCdata(i).Chn01, OSCdata(i).Chn02);
end
toc;
%% Draw Spectrum
Intens0 = NaN(dataCount, 1);
IntensP = NaN(dataCount, 1);
IntensN = NaN(dataCount, 1);
mkdir(strcat(dirName, 'FFTFigures/'));
parfor i=1:dataCount/3    
    [~, Intens0(i), IntensP(i), IntensN(i)] = plot_RawCalibFourier(thermalData0(i).Chn02,...
        thermalDataP(i).Chn02, thermalDataN(i).Chn02, thermalDataN(i).Len,...
        thermalData0(i).SampleRate, thermalPoint(i), i+dataCount,...
        strcat(dirName, 'FFTFigures/', thermalPoint(i)), FreqExec);
%     Data0,...
%     DataP, DataN, Len,SampRate, FigName, FigHandle, FullName, FreqPoint
end
toc;
%% Draw compare
mkdir(strcat(dirName, 'P0N_DataCompare/'));
parfor i=1:dataCount/3
    plot_RawP0N(2*dataCount+i, thermalData0(i).xRange*thermalData0(i).Stack,...
        thermalData0(i).SampleRate, thermalPoint(i), ...
        strcat(dirName, 'P0N_DataCompare/', thermalPoint(i)),...
        thermalDataP(i), thermalData0(i), thermalDataN(i));
end
toc;

%% Calculate Maximum sequence phase0
maxP0 = zeros(1,dataCount/3);
maxPP = zeros(1,dataCount/3);
maxPN = zeros(1,dataCount/3);
stepP = thermalData0(1).SampleRate/FreqExec;
parfor i = 1:dataCount/3
    [~,maxP0(i)] = max(thermalData0(i).Chn02);
    [~,maxPP(i)] = max(thermalDataP(i).Chn02);
    [~,maxPN(i)] = max(thermalDataN(i).Chn02);
end
toc;
maxP0 = mod(maxP0, stepP);
maxPP = mod(maxPP, stepP);
maxPN = mod(maxPN, stepP);

%% Calculate Minimum sequence phase0
minP0 = zeros(1,dataCount/3);
minPP = zeros(1,dataCount/3);
minPN = zeros(1,dataCount/3);
% stepP = thermalData0(1).SampleRate/FreqExec;
parfor i = 1:dataCount/3
    [~,minP0(i)] = min(thermalData0(i).Chn02);
    [~,minPP(i)] = min(thermalDataP(i).Chn02);
    [~,minPN(i)] = min(thermalDataN(i).Chn02);
end
toc;
minP0 = mod(minP0, stepP);
minPP = mod(minPP, stepP);
minPN = mod(minPN, stepP);

% %% Calculate start Phase
% pha0 = min([maxP0 minP0]);
% phaP = min([maxPP minPP]);
% phaN = min([maxPN minPN]);

%% Calculate harmmean maximum, minimum and error bar value.
Peak0 = NaN(dataCount/3, 2);
PeakP = NaN(dataCount/3, 2);
PeakN = NaN(dataCount/3, 2);
Err0 = NaN(dataCount/3, 2, 2);
ErrP = NaN(dataCount/3, 2, 2);
ErrN = NaN(dataCount/3, 2, 2);
parfor i = 1:dataCount/3
    Peak0(i,:) = [harmmean(thermalData0(i).Chn02(maxP0:stepP:end))...
        harmmean(thermalData0(i).Chn02(minP0:stepP:end))];
    PeakP(i,:) = [harmmean(thermalDataP(i).Chn02(maxPP:stepP:end))...
        harmmean(thermalDataP(i).Chn02(minPP:stepP:end))];
    PeakN(i,:) = [harmmean(thermalDataN(i).Chn02(maxPN:stepP:end))...
        harmmean(thermalDataN(i).Chn02(minPN:stepP:end))];
    Err0(i,:,:) = [min(thermalData0(i).Chn02(maxP0:stepP:end))...
        max(thermalData0(i).Chn02(maxP0:stepP:end));...
        min(thermalData0(i).Chn02(minP0:stepP:end))...
        max(thermalData0(i).Chn02(minP0:stepP:end))];        
    ErrP(i,:,:) = [min(thermalDataP(i).Chn02(maxPP:stepP:end))...
        max(thermalDataP(i).Chn02(maxPP:stepP:end));...
        min(thermalDataP(i).Chn02(minPP:stepP:end))...
        max(thermalDataP(i).Chn02(minPP:stepP:end))];
    ErrN(i,:,:) = [min(thermalDataN(i).Chn02(maxPN:stepP:end))...
        max(thermalDataN(i).Chn02(maxPN:stepP:end));...
        min(thermalDataN(i).Chn02(minPN:stepP:end))...
        max(thermalDataN(i).Chn02(minPN:stepP:end))];
%     Peak0(i,2) = harmmean(thermalData0(i).Chn02(minP0:stepP:end));
end
toc;

%% Draw Peak and Valley Value Versus ZeroField
TPoint = erase(thermalPoint,"t4_");
errorRange = 1:dataCount/3-1;

mkdir(strcat(dirName, 'IntensityFigures/'));
figure(dataCount*3+1);
errorbar(errorRange, Peak0(errorRange,1),Err0(errorRange,1,1)-Peak0(errorRange,1),...
    Err0(errorRange,1,2)-Peak0(errorRange,1),'Color','black','LineWidth',1.5);
hold on;
errorbar(errorRange, PeakP(errorRange,1),ErrP(errorRange,1,1)-PeakP(errorRange,1),...
    ErrP(errorRange,1,2)-PeakP(errorRange,1),'Color','red','LineWidth',1.5);
errorbar(errorRange, PeakN(errorRange,1),ErrN(errorRange,1,1)-PeakN(errorRange,1),...
    ErrN(errorRange,1,2)-PeakN(errorRange,1),'Color','blue','LineWidth',1.5);
hold off;
xticks(0:4:errorRange(end)+1);
xticklabels(strsplit(num2str(30:40:230),' '));
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('Sense Signal Peak Voltage (V)','FontSize',24);
xlabel('Sensor Temperature (^{\circ}C)','FontSize',24);
legend({'Zero Field','Positive Field','Negative Field'},'FontSize',20,'Location','northeast');
title('Thermal Field Test Signal Peak Value Curve','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalPeakValue.svg'));
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalPeakValue.png'));
close(dataCount*3+1);

figure(dataCount*3+2);
errorbar(errorRange, Peak0(errorRange,2),Err0(errorRange,2,1)-Peak0(errorRange,2),...
    Err0(errorRange,2,2)-Peak0(errorRange,2),'Color','black','LineWidth',1.5);
hold on;
errorbar(errorRange, PeakP(errorRange,2),ErrP(errorRange,2,1)-PeakP(errorRange,2),...
    ErrP(errorRange,2,2)-PeakP(errorRange,2),'Color','red','LineWidth',1.5);
errorbar(errorRange, PeakN(errorRange,2),ErrN(errorRange,2,1)-PeakN(errorRange,2),...
    ErrN(errorRange,2,2)-PeakN(errorRange,2),'Color','blue','LineWidth',1.5);
hold off;
xticks(0:4:errorRange(end)+1);
xticklabels(strsplit(num2str(30:40:230),' '));
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('Sense Signal Valley Voltage (V)','FontSize',24);
xlabel('Sensor Temperature (^{\circ}C)','FontSize',24);
legend({'Zero Field','Positive Field','Negative Field'},'FontSize',20,'Location','southeast');
title('Thermal Field Test Signal Valley Value Curve','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValleyValue.svg'));
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValleyValue.png'));
close(dataCount*3+2);
toc;
%% Calculate Secondary Signal
Value0 = NaN(dataCount/3, 1);
ValueP = NaN(dataCount/3, 1);
ValueN = NaN(dataCount/3, 1);
ErrV0 = NaN(dataCount/3, 2);
ErrVP = NaN(dataCount/3, 2);
ErrVN = NaN(dataCount/3, 2);

parfor i = 1:dataCount/3
    Value0(i) = harmmean(thermalData0(i).Chn02(maxP0:stepP:end)...
        +thermalData0(i).Chn02(minP0:stepP:end), 'omitnan');
    ValueP(i) = harmmean(thermalDataP(i).Chn02(maxPP:stepP:end)...
        +thermalDataP(i).Chn02(minPP:stepP:end), 'omitnan');
    ValueN(i) = harmmean(thermalDataN(i).Chn02(maxPN:stepP:end)...
        +thermalDataN(i).Chn02(minPN:stepP:end), 'omitnan');
    ErrV0(i,:) = [min(thermalData0(i).Chn02(maxP0:stepP:end)...
        +thermalData0(i).Chn02(minP0:stepP:end))-Value0(i)...
        max(thermalData0(i).Chn02(maxP0:stepP:end)...
        +thermalData0(i).Chn02(minP0:stepP:end))-Value0(i)];
    ErrVP(i,:) = [min(thermalDataP(i).Chn02(maxPP:stepP:end)...
        +thermalDataP(i).Chn02(minPP:stepP:end))-ValueP(i)...
        max(thermalDataP(i).Chn02(maxPP:stepP:end)...
        +thermalDataP(i).Chn02(minPP:stepP:end))-ValueP(i)];
    ErrVN(i,:) = [min(thermalDataN(i).Chn02(maxPN:stepP:end)...
        +thermalDataN(i).Chn02(minPN:stepP:end))-ValueN(i)...
        max(thermalDataN(i).Chn02(maxPN:stepP:end)...
        +thermalDataN(i).Chn02(minPN:stepP:end))-ValueN(i)];
%     Peak0(i,2) = harmmean(thermalData0(i).Chn02(minP0:stepP:end));
end
toc;

figure(dataCount*3+3);
errorbar(errorRange, Value0(errorRange),ErrV0(errorRange,1),...
    ErrV0(errorRange,2),'Color','black','LineWidth',1.5);
hold on;
errorbar(errorRange, ValueP(errorRange),ErrVP(errorRange,1),...
    ErrVP(errorRange,2),'Color','red','LineWidth',1.5);
errorbar(errorRange, ValueN(errorRange),ErrVN(errorRange,1),...
    ErrVN(errorRange,2),'Color','blue','LineWidth',1.5);
hold off;
xticks(0:4:errorRange(end)+1);
xticklabels(strsplit(num2str(30:40:230),' '));
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('Sense Secondary Signal Voltage (V)','FontSize',24);
xlabel('Sensor Temperature (^{\circ}C)','FontSize',24);
legend({'Zero Field','Positive Field','Negative Field'},'FontSize',20,'Location','northeast');
title('Thermal Field Test Secondary Signal Intensity Curve','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'IntensityFigures/Thermal2ndValue.svg'));
saveas(gcf,strcat(dirName, 'IntensityFigures/Thermal2ndValue.png'));
close(dataCount*3+3);
toc;

figure(dataCount+4);
% errorbar(errorRange, Value0(errorRange),ErrV0(errorRange,1),...
%     ErrV0(errorRange,2),'Color','black','LineWidth',1.5);
hold on;
errorbar(errorRange, -(ValueP(errorRange)-Value0(errorRange)),...
    ErrVP(errorRange,1)+ErrV0(errorRange,1),...
    ErrVP(errorRange,2)+ErrV0(errorRange,2),'Color','red','LineWidth',1.5);
errorbar(errorRange, ValueN(errorRange)-Value0(errorRange),...
    ErrVN(errorRange,1)+ErrV0(errorRange,1),...
    ErrVN(errorRange,2)+ErrV0(errorRange,2),'Color','blue','LineWidth',1.5);
hold off;
xticks(0:4:errorRange(end)+1);
xticklabels(strsplit(num2str(30:40:230),' '));
set(gca,'FontSize',20);
ylabel('Sense Secondary Signal Voltage (V)','FontSize',24);
xlabel('Sensor Temperature (^{\circ}C)','FontSize',24);
legend({'Positive Field (Reversed)','Negative Field'},'FontSize',20,'Location','northeast');
title('Thermal Field Test Detrended Secondary Signal Intensity Curve','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'IntensityFigures/Thermal2ndDetrended.svg'));
saveas(gcf,strcat(dirName, 'IntensityFigures/Thermal2ndDetrended.png'));
close(dataCount+4);
toc;

figure(dataCount+5);
% errorbar(errorRange, Value0(errorRange),ErrV0(errorRange,1),...
%     ErrV0(errorRange,2),'Color','black','LineWidth',1.5);
hold on;
errorbar(errorRange, -ValueP(errorRange), ErrVP(errorRange,1),...
    ErrVP(errorRange,2),'Color','red','LineWidth',1.5);
errorbar(errorRange, ValueN(errorRange), ErrVN(errorRange,1),...
    ErrVN(errorRange,2),'Color','blue','LineWidth',1.5);
hold off;
xticks(0:4:errorRange(end)+1);
xticklabels(strsplit(num2str(30:40:230),' '));
set(gca,'FontSize',20);
ylabel('Sense Secondary Signal Voltage (V)','FontSize',24);
xlabel('Sensor Temperature (^{\circ}C)','FontSize',24);
legend({'Positive Field (Reversed)','Negative Field'},'FontSize',20,'Location','northeast');
title('Thermal Field Test Secondary Signal Intensity Curve','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'IntensityFigures/Thermal2nd.svg'));
saveas(gcf,strcat(dirName, 'IntensityFigures/Thermal2nd.png'));
close(dataCount+5);
toc;