% Draw Exec and Sens signal, then do some calculate
clear all;

%% Import data-
dirName='./thermalField13/';
dataCluster=string(ls(dirName));
FreqExec = 1000;
% fieldCount = 7;
fieldSeq = -60000:20000:60000;
fieldCount = length(fieldSeq);
chosenTemp = [28 70:50:220];
if length(chosenTemp)>5
    error('Scatter Map Could Draw Up to 5 temperatures!');
end

if isunix()
    [dataCluster,~]=strsplit(dataCluster);
end
dataHandle=contains(dataCluster, '.Wfm.csv');
headerT = 't13_';

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

%% Analyze dataName
for i = 1:dataCount
    nameBuff = strsplit(OSCdata(i).Name,'_');
    OSCdata(i).Temp = str2double(nameBuff(2));
    OSCdata(i).Field = str2double(nameBuff(3));
end
toc;

%% Make Temperature Sequence
tempBuff = 0;
tempSeq = [];
for i = 1:dataCount
    if tempBuff == OSCdata(i).Temp
        continue;
    else
        tempBuff = OSCdata(i).Temp;
        tempSeq = [tempSeq tempBuff];
    end
end
toc;
tempCount = length(tempSeq);

%% Sort Temperature - Field Sequence by Pointer
dataPointer = zeros(tempCount, fieldCount);
for i=1:dataCount
    a = find(tempSeq==OSCdata(i).Temp);
    b = find(fieldSeq==OSCdata(i).Field);
    dataPointer(a,b)=i;
end

%% Draw Raw data Frequency Spectrum
Intens1Fq = NaN(dataCount, 1);
Intens2Fq = NaN(dataCount, 1);
mkdir(strcat(dirName, 'FFTFigures/'));
parfor i=1:dataCount    
    [~, Intens1Fq(i), Intens2Fq(i)] = plot_RawHysterFourierNT(OSCdata(i).Chn02,...
        OSCdata(i).Len, OSCdata(i).SampleRate, OSCdata(i).Name, i+dataCount,...
        strcat(dirName, 'FFTFigures/', OSCdata(i).Name), FreqExec);
end
toc;

% %% Draw Raw Data Series
% %% Draw Spectrum
% %% Draw Compare
% %% Calculate Maximum sequence phase0
% %% Calculate Minimum sequence phase0
%% Set Sample Point Count, and shift those data to avoid error
sampCount = 3;
sampShift = ceil(sampCount/2);
peakCount = OSCdata(1).Len*OSCdata(1).Resol*FreqExec;

parfor i = 1:dataCount
    OSCdata(i).Chn01 = circshift(OSCdata(i).Chn01, sampShift);
    OSCdata(i).Chn02 = circshift(OSCdata(i).Chn02, sampShift);
end
toc;

%% Check Peak Set
%  [veP0,peP0] = findpeaks(thermalData0(1).Chn02,'MinPeakHeight',1);
toler = 3; %set Phase tolerance
stepP = OSCdata(1).SampleRate/FreqExec;
parfor i = 1:dataCount
      [veP,peP] = findpeaks(OSCdata(i).Chn02,'MinPeakHeight',1);
      if max(abs(diff(peP)-stepP))>toler
          error('Phase not Correct, at %d zeroField', i);
      end
      maxP(i) = mod(peP(1),stepP);
      [veN,peN] = findpeaks(-OSCdata(i).Chn02,'MinPeakHeight',1);
      if max(abs(diff(peN)-stepP))>toler
          error('Phase not Correct, at %d zeroField', i);
      end
      minP(i) = mod(peN(1),stepP);
end
toc;

%% Generate Sampling Sequence
sampS = NaN(dataCount, OSCdata(1).Len);

for i = 1:dataCount
    for j = -floor(sampCount/2):1:floor(sampCount/2)
        sampS(i, maxP(i)+j:stepP:end) = 1;
        sampS(i, minP(i)+j:stepP:end) = 1;
    end
end
toc;

%% Do Sampling
% PeakN = (thermalDataN(1).Chn02(:)).*sampSN(1,:)';
parfor i = 1:dataCount
    PeakBuff = OSCdata(i).Chn02.*sampS(i,:)';
    PeakBuff(isnan(PeakBuff)) = [];
    PeakPN(i,:) = PeakBuff;
    ValuePN(i) = mean(PeakBuff)*sqrt(sampCount);
    ResultBuff = mean(reshape(PeakBuff,[sampCount*2,FreqExec*2]),1)'*sqrt(sampCount);
    ResultPN(i,:) = ResultBuff;
    stdPN0(i) = std(PeakBuff(sampShift:2*sampCount:end)...
        +PeakBuff(sampShift+sampCount:2*sampCount:end));
    stdPN1(i) = std(ResultBuff);
 end
toc;

%% Link Sequence by temperature
scaCalib = NaN(tempCount, fieldCount*peakCount);
fieldStack = NaN(1,fieldCount*peakCount);
for i = 1:tempCount
    for j = 1:fieldCount
        scaCalib(i,(j-1)*peakCount+1:j*peakCount) = ResultPN(dataPointer(i,j),:);
    end
end
for i = 1:fieldCount
    fieldStack((i-1)*peakCount+1:i*peakCount) = fieldSeq(i);
end
parfor i = 1:tempCount
    [caliP(i,:), caliS(i,:)] = polyfit(fieldStack, scaCalib(i,:),1);
    [scaFit(i,:), delta(i,:)] = polyval(caliP(i,:),fieldSeq, caliS(i,:));
end
delta = delta(:,1);
toc;

% %% standard error
% parfor i = 1:dataCount
%     stdPN0(i) = std(PeakPN(i,sampShift:2*sampCount:end)+PeakPN(i,sampShift+sampCount:2*sampCount:end));
% end
% 
% for i=1:dataCount/3
%     std0(i) = std(Peak0(i,sampShift:2*sampCount:end)+Peak0(i,sampShift+sampCount:2*sampCount:end));
%     stdP(i) = std(PeakP(i,sampShift:2*sampCount:end)+PeakP(i,sampShift+sampCount:2*sampCount:end));
%     stdN(i) = std(PeakN(i,sampShift:2*sampCount:end)+PeakN(i,sampShift+sampCount:2*sampCount:end));
% end
% thermalTick = str2double(erase(thermalPoint,headerT));

%% Draw thermal-field curve
mkdir(strcat(dirName, 'IntensityFigures/'));
figure(1);
errorbar(tempSeq, ValuePN(dataPointer(:,ceil(fieldCount/2))),...
    stdPN1(dataPointer(:,ceil(fieldCount/2))), 'Color','black','LineWidth',1.5);
hold on;
for i = 1:floor(fieldCount/2)    
    errorbar(tempSeq, ValuePN(dataPointer(:,ceil(fieldCount/2)-i)),...
        stdPN1(dataPointer(:,ceil(fieldCount/2)-i)), 'LineWidth',1.5);   
    errorbar(tempSeq, ValuePN(dataPointer(:,ceil(fieldCount/2)+i)),...
        stdPN1(dataPointer(:,ceil(fieldCount/2)+i)), 'LineWidth',1.5);
end
hold off;
xlim([20 230]);
xticks(20:20:220);
% xticklabels(strsplit(num2str(30:40:230),' '));
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('Sensor Measured Voltage (V)','FontSize',24);
xlabel('Sensor Temperature (^{\circ}C)','FontSize',24);
% legend({'Zero Field','Positive Field','Negative Field'},'FontSize',20,'Location','best');
title('Thermal - Varias Field Test Signal Intensity Curve','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
set(gcf,'Color','none');
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.fig'));
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.pdf'));
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.svg'));
saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.png'));
close(1);

%% Thermal Calibration
drawTemp = NaN(1,length(chosenTemp));
for i = 1:length(chosenTemp)
    drawTemp(i) = find(tempSeq == chosenTemp(i));
end
colorPool = ["black" "green" "blue" "magenta" "red"];
markerPool = ["o" "+" "s" "v" "x"];
figure(2)
% scatter(fieldStack, scaCalib(1,:),'MarkerEdgeColor', 'black', 'LineWidth', 0.8);
hold on;
% plot(fieldSeq, scaFit(1,:), 'Color', 'black', 'LineWidth', 1.2);
% plot(fieldSeq, scaFit(1,:)+2*delta(i), '-.', fieldSeq, scaFit(1,:)-2*delta(i), '-.', 'LineWidth', 0.8, 'Color', 'black');

for i = 1:length(chosenTemp)    
    p(i) = scatter(-fieldStack, scaCalib(i,:), 16 ,markerPool(i), 'MarkerEdgeColor',...
        colorPool(i), 'LineWidth', 0.8, 'DisplayName', [num2str(chosenTemp(i)) '^{\circ}C']);
    plot(-fieldSeq, scaFit(i,:), '--', 'Color', colorPool(i), 'LineWidth', 1.2);
%     plot(fieldSeq, scaFit(i,:)+2*delta(i), '-.', fieldSeq, scaFit(i,:)-2*delta(i), '-.', 'LineWidth', 0.8, 'Color', colorPool(i));
%     text(fieldSeq(3), scaFit(i,end-3), ['$\hat{U}_{S} = ' num2str(caliP(i,1),'%g') '{\cdot}B_{A}' num2str(caliP(i,2),'%+g') '$'],...
%         'Interpreter', 'latex', 'FontSize',24);
end
legend(p, 'fontsize', 24, 'location', 'southeast');
hold off;
xlim([fieldSeq(1) fieldSeq(end)]*1.25);
ylim([-max(abs(ylim())) max(abs(ylim()))]);
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('U_{S} (V)','FontSize',24);
xlabel('B_{A} (nT)','FontSize',24);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'IntensityFigures/Fitting01.fig'));
saveas(gcf,strcat(dirName, 'IntensityFigures/Fitting01.png'));
saveas(gcf,strcat(dirName, 'IntensityFigures/Fitting01.svg'));
% set(gcf,'Position',[1,41,800,600]);
% saveas(gcf,strcat(dirName, 'IntensityFigures/Fitting01.pdf'));
close(2);
toc;

%% error bar version
figure(3)
% scatter(fieldStack, scaCalib(1,:),'MarkerEdgeColor', 'black', 'LineWidth', 0.8);
hold on;
% plot(fieldSeq, scaFit(1,:), 'Color', 'black', 'LineWidth', 1.2);
% plot(fieldSeq, scaFit(1,:)+2*delta(i), '-.', fieldSeq, scaFit(1,:)-2*delta(i), '-.', 'LineWidth', 0.8, 'Color', 'black');

for i = 1:length(chosenTemp)  
%     p(i) = errorbar(-fieldStack, scaCalib(i,:), stdPN1(dataPointer(drawTemp(i),:)))
    p(i) = errorbar(-fieldSeq, ResultPN(dataPointer(drawTemp(i),:)),...
        stdPN0(dataPointer(drawTemp(i),:)), markerPool(i), 'Color',...
        colorPool(i), 'LineWidth', 0.8, 'DisplayName', [num2str(chosenTemp(i)) '^{\circ}C']);
    plot(-fieldSeq, scaFit(i,:), '--', 'Color', colorPool(i), 'LineWidth', 1.2);
%     plot(fieldSeq, scaFit(i,:)+2*delta(i), '-.', fieldSeq, scaFit(i,:)-2*delta(i), '-.', 'LineWidth', 0.8, 'Color', colorPool(i));
%     text(fieldSeq(3), scaFit(i,end-3), ['$\hat{U}_{S} = ' num2str(caliP(i,1),'%g') '{\cdot}B_{A}' num2str(caliP(i,2),'%+g') '$'],...
%         'Interpreter', 'latex', 'FontSize',24);
end
legend(p, 'fontsize', 24, 'location', 'southeast');
hold off;
xlim([fieldSeq(1) fieldSeq(end)]*1.25);
ylim([-max(abs(ylim())) max(abs(ylim()))]);
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('U_{S} (V)','FontSize',24);
xlabel('B_{A} (nT)','FontSize',24);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'IntensityFigures/Fitting02.fig'));
saveas(gcf,strcat(dirName, 'IntensityFigures/Fitting02.png'));
saveas(gcf,strcat(dirName, 'IntensityFigures/Fitting02.svg'));
% set(gcf,'Position',[1,41,800,600]);
% saveas(gcf,strcat(dirName, 'IntensityFigures/Fitting02.pdf'));
% close(2);
toc;

%% adjust
% %% LineFit Coefficient
% figure(3);
load('./Test2/calib1K/CalibCoef.mat','caliPRE');
caliPAdj = [caliP(:,1)/caliP(1,1)*caliPRE(1),caliP(:,2)-caliP(1,2)+caliPRE(2),...
    (caliP(:,2)-caliP(1,2)+caliPRE(2))*1000];
% [Pfit, Ps] = polyfit(tempSeq', caliPRE(:)/caliPRE(1),1);
% [PVal, deltaP] = polyval(Pfit,tempSeq, Ps);
% 
% scatter(tempSeq, caliPRE1(:), 'LineWidth', 1.5);
% hold on;
% plot(tempSeq, PVal*caliPRE1(1), '-.', 'LineWidth',1.2);
