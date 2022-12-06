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
headerT = 't4_';

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

%% Draw Compare
mkdir(strcat(dirName, 'P0N_DataCompare/'));
parfor i=1:dataCount/3
    plot_RawP0N(2*dataCount+i, thermalData0(i).xRange/500,...
        thermalData0(i).SampleRate, thermalPoint(i), ...
        strcat(dirName, 'P0N_DataCompare/', thermalPoint(i)),...
        thermalDataP(i), thermalData0(i), thermalDataN(i));
end
toc;
stepP = thermalData0(1).SampleRate/FreqExec;
% 
% %% Calculate Maximum sequence phase0
% maxP0 = zeros(1,dataCount/3);
% maxPP = zeros(1,dataCount/3);
% maxPN = zeros(1,dataCount/3);

% parfor i = 1:dataCount/3
%     [~,maxP0(i)] = max(thermalData0(i).Chn02);
%     [~,maxPP(i)] = max(thermalDataP(i).Chn02);
%     [~,maxPN(i)] = max(thermalDataN(i).Chn02);
% end
% maxP0 = mod(maxP0, stepP);
% maxPP = mod(maxPP, stepP);
% maxPN = mod(maxPN, stepP);
% toc;
% 
% %% Calculate Minimum sequence phase0
% minP0 = zeros(1,dataCount/3);
% minPP = zeros(1,dataCount/3);
% minPN = zeros(1,dataCount/3);
% % stepP = thermalData0(1).SampleRate/FreqExec;
% parfor i = 1:dataCount/3
%     [~,minP0(i)] = min(thermalData0(i).Chn02);
%     [~,minPP(i)] = min(thermalDataP(i).Chn02);
%     [~,minPN(i)] = min(thermalDataN(i).Chn02);
% end
% minP0 = mod(minP0, stepP);
% minPP = mod(minPP, stepP);
% minPN = mod(minPN, stepP);
% toc;

%% Set Sample Point Count, and shift those data to avoid error
sampCount = 5;
sampShift = ceil(sampCount/2);

parfor i = 1:dataCount/3
    thermalData0(i).Chn01 = circshift(thermalData0(i).Chn01,sampShift);
    thermalData0(i).Chn02 = circshift(thermalData0(i).Chn02,sampShift);
    thermalDataN(i).Chn01 = circshift(thermalDataN(i).Chn01,sampShift);
    thermalDataN(i).Chn02 = circshift(thermalDataN(i).Chn02,sampShift);
    thermalDataP(i).Chn01 = circshift(thermalDataP(i).Chn01,sampShift);
    thermalDataP(i).Chn02 = circshift(thermalDataP(i).Chn02,sampShift);
end
toc;

%% Check Peak Set
%  [veP0,peP0] = findpeaks(thermalData0(1).Chn02,'MinPeakHeight',1);
toler = 3; %set Phase tolerance
parfor i = 1:dataCount/3
      [veP0,peP0] = findpeaks(thermalData0(i).Chn02,'MinPeakHeight',1);
      if max(abs(diff(peP0)-stepP))>toler
          error('Phase not Correct, at %d zeroField', i);
      end
      [vePP,pePP] = findpeaks(thermalDataP(i).Chn02,'MinPeakHeight',1);
      if max(abs(diff(pePP)-stepP))>toler
          error('Phase not Correct, at %d PosiField', i);
      end
      [vePN,pePN] = findpeaks(thermalDataN(i).Chn02,'MinPeakHeight',1);
      if max(abs(diff(pePN)-stepP))>toler
          error('Phase not Correct, at %d zeroField', i);
      end
      maxP0(i) = mod(peP0(1),stepP);
      maxPP(i) = mod(pePP(1),stepP);
      maxPN(i) = mod(pePN(1),stepP);
      [veN0,peP0] = findpeaks(-thermalData0(i).Chn02,'MinPeakHeight',1);
      if max(abs(diff(peP0)-stepP))>toler
          error('Phase not Correct, at %d zeroField', i);
      end
      [veNP,pePP] = findpeaks(-thermalDataP(i).Chn02,'MinPeakHeight',1);
      if max(abs(diff(pePP)-stepP))>toler
          error('Phase not Correct, at %d PosiField', i);
      end
      [veNN,pePN] = findpeaks(-thermalDataN(i).Chn02,'MinPeakHeight',1);
      if max(abs(diff(pePN)-stepP))>toler
          error('Phase not Correct, at %d zeroField', i);
      end
      std0(i) = sqrt(power(std(veP0),2)+power(std(veN0),2));
      stdP(i) = sqrt(power(std(vePP),2)+power(std(veNP),2));
      stdN(i) = sqrt(power(std(vePN),2)+power(std(veNN),2));
      minP0(i) = mod(peP0(1),stepP);
      minPP(i) = mod(pePP(1),stepP);
      minPN(i) = mod(pePN(1),stepP);
end
toc;

%% Generate Sampling Sequence
sampS0 = NaN(dataCount/3, thermalData0(1).Len);
sampSP = NaN(dataCount/3, thermalDataP(1).Len);
sampSN = NaN(dataCount/3, thermalDataN(1).Len);

for i = 1:dataCount/3
    for j = -floor(sampCount/2):1:floor(sampCount/2)
        sampS0(i, maxP0(i)+j:stepP:end) = 1;
        sampS0(i, minP0(i)+j:stepP:end) = 1;
        sampSP(i, maxPP(i)+j:stepP:end) = 1;
        sampSP(i, minPP(i)+j:stepP:end) = 1;
        sampSN(i, maxPN(i)+j:stepP:end) = 1;
        sampSN(i, minPN(i)+j:stepP:end) = 1;
    end
end
toc;

%% Do Sampling
% PeakN = (thermalDataN(1).Chn02(:)).*sampSN(1,:)';
parfor i = 1:dataCount/3
    Peak0Buff = thermalData0(i).Chn02.*sampS0(i,:)';
    PeakPBuff = thermalDataP(i).Chn02.*sampSP(i,:)';
    PeakNBuff = thermalDataN(i).Chn02.*sampSN(i,:)';
    Peak0Buff(isnan(Peak0Buff)) = [];
    PeakPBuff(isnan(PeakPBuff)) = [];
    PeakNBuff(isnan(PeakNBuff)) = [];
    Peak0(i,:) = Peak0Buff;
    PeakP(i,:) = PeakPBuff;
    PeakN(i,:) = PeakNBuff;
    Value0(i) = mean(Peak0Buff)*sqrt(sampCount);
    ValueP(i) = mean(PeakPBuff)*sqrt(sampCount);
    ValueN(i) = mean(PeakNBuff)*sqrt(sampCount);
end
toc;

%% standard error
for i=1:dataCount/3
    std0(i) = std(Peak0(i,sampShift:2*sampCount:end)+Peak0(i,sampShift+sampCount:2*sampCount:end));
    stdP(i) = std(PeakP(i,sampShift:2*sampCount:end)+PeakP(i,sampShift+sampCount:2*sampCount:end));
    stdN(i) = std(PeakN(i,sampShift:2*sampCount:end)+PeakN(i,sampShift+sampCount:2*sampCount:end));
end
thermalTick = str2double(erase(thermalPoint,headerT));

%% Draw thermal-field curve
mkdir(strcat(dirName, 'IntensityFigures/'));
figure(dataCount*3+1);
errorbar(thermalTick, Value0, std0, 'Color','black','LineWidth',1.5);
hold on;
errorbar(thermalTick, ValueP, stdP, 'Color','red','LineWidth',1.5);
errorbar(thermalTick, ValueN, stdN, 'Color','blue','LineWidth',1.5);
hold off;
xticks(0:30:270);
% xticklabels(strsplit(num2str(30:40:230),' '));
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('Sense Signal Peak Voltage (V)','FontSize',24);
xlabel('Sensor Temperature (^{\circ}C)','FontSize',24);
legend({'Zero Field','Positive Field','Negative Field'},'FontSize',20,'Location','best');
title('Thermal - Reversed Field Test Signal Intensity Curve','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.fig'));
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.svg'));
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.png'));
close(dataCount*3+1);

figure(dataCount*3+2);
errorbar(thermalTick, -ValueP+Value0, sqrt(stdP.^2+std0.^2), 'Color','red','LineWidth',1.5);
hold on;
errorbar(thermalTick, ValueN-Value0, sqrt(stdN.^2+std0.^2), 'Color','blue','LineWidth',1.5);
hold off;
xticks(0:30:270);
% xticks(0:4:errorRange(end)+1);
% xticklabels(strsplit(num2str(30:40:230),' '));
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('Sense Signal Peak Voltage (V)','FontSize',24);
xlabel('Sensor Temperature (^{\circ}C)','FontSize',24);
legend({'Positive Field (Flipped)','Negative Field'},'FontSize',20,'Location','best');
title('Thermal - Reversed Field Test Signal Detrended Intensity Curve','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValueDetrended.fig'));
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValueDetrended.svg'));
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValueDetrended.png'));
close(dataCount*3+2);
