%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw Exec and Sens signal, then do some calculate
clear all;

%% Import data-
dirName='./Test2/calib1K/';
dataCluster=string(ls(dirName));
FreqExec = 1000;
if isunix()
    [dataCluster,~]=strsplit(dataCluster);
end
dataHandle=contains(dataCluster, '.Wfm.csv');
nameHeader = '1k_';

%% Pick up valid Files
dataCluster(dataHandle==0)=[];
fileCluster=strcat(dirName, dataCluster);
dataCount=length(dataCluster);
validArea = 1:dataCount;
dataCount = validArea(end);

%% Load Valid Data
tic;
% parpool;
parfor i=1:dataCount
    OSCdata(i) = read_RohdeWavePair(fileCluster(i));
    field(i) = str2double(erase(OSCdata(i).Name, nameHeader));
end
toc;

%% Draw Raw Data Series
mkdir(strcat(dirName, 'RawDataFigures/'));
parfor i=1:dataCount
    plot_RawDualChannel(i, OSCdata(i).xRange, OSCdata(i).SampleRate,...
    OSCdata(i).Name, strcat(dirName, 'RawDataFigures/', OSCdata(i).Name),...
    OSCdata(i).Chn01, OSCdata(i).Chn02);
end
toc;

%% Draw Raw data Frequency Spectrum
Intens1Fq = NaN(dataCount, 1);
Intens2Fq = NaN(dataCount, 1);
mkdir(strcat(dirName, 'FFTFigures/'));
parfor i=1:dataCount    
    [~, Intens1Fq(i), Intens2Fq(i)] = plot_RawHysterFourier(OSCdata(i).Chn02,...
        OSCdata(i).Len, OSCdata(i).SampleRate, OSCdata(i).Name, i+dataCount,...
        strcat(dirName, 'FFTFigures/', OSCdata(i).Name), FreqExec);
end
toc;

%% Calculate Maximum sequence phase0
maxP = zeros(1,dataCount);
minP = zeros(1,dataCount);
stepP = OSCdata(1).SampleRate/FreqExec;
parfor i = 1:dataCount
    [~,maxP(i)] = max(OSCdata(i).Chn02);
    [~,minP(i)] = min(OSCdata(i).Chn02);
end
maxP = mod(maxP, stepP);
minP = mod(minP, stepP);
toc;

%% Calculate Secondary Signal
waveN = (OSCdata(1).xRange(2)-OSCdata(1).xRange(1))*FreqExec;
valueS = NaN(dataCount, waveN);
parfor i=1:dataCount
    valueS(i,:) = OSCdata(i).Chn02(maxP:stepP:end)+OSCdata(i).Chn02(minP:stepP:end);
end
fieldWide = field;
for i = 1 : waveN-1
    fieldWide = [fieldWide field];
end
valueWide = reshape(valueS, 1, []);
[caliP,caliS]=polyfit(fieldWide, valueWide, 1);
field_fit = sort(field,'ascend');
[value_fit,delta] = polyval(caliP, field_fit, caliS);

mkdir(strcat(dirName, 'CalibCurve/'));
figure(2*dataCount+1);
scatter(fieldWide, valueWide,'MarkerEdgeColor', 'blue', 'LineWidth', 1.2);
hold on;
plot(field_fit, value_fit, 'Color', 'red', 'LineWidth', 1.2);
plot(field_fit, value_fit+2*delta, 'm-.', field_fit, value_fit-2*delta, 'm-.', 'LineWidth', 1.2);
hold off;

xticks(field_fit(1):(field_fit(end)-field_fit(1))/10:field_fit(end));
xlim([field_fit(1)-5000 field_fit(end)+5000]);
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('U_{S} (V)','FontSize',24);
xlabel('B_{A} (nT)','FontSize',24);
legend({'Measured Data','Linear Fit','95% Prediction Interval'},'FontSize',20,'Location','southeast');
% title('Ambient Magnetic Field Calibration Fitting Curve','FontSize',28);
% text(field_fit(3), value_fit(end-3), ['$\hat{U}_{S} = ' num2str(caliP(1),'%g') '{\cdot}B_{A}' num2str(caliP(2),'%+g') '$'],...
%     'Interpreter', 'latex', 'FontSize',24);
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'CalibCurve/Fitting01.svg'));
saveas(gcf,strcat(dirName, 'CalibCurve/Fitting01.png'));
% close(2*dataCount+1);
toc;


