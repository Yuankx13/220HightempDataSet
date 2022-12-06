%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clustering Wave Form Data
clear all;

%% Import data
dirName='./Test2/hysterTest/';
dataName = '025Test01.csv';
fileName=[dirName dataName];
OSCdata = read_RohdeWavePair(fileName);
% Tag = '0HzRefCurve';
tic;
sigFrq = 1000;

%%　To Prevent over drawing.
for i=1:5
    if ishandle(i)
        close(i);
    end
end
% close([1 2 3]);
Math01p=cumtrapz(1/OSCdata.SampleRate, OSCdata.Chn02)*1000;
Math01=detrend(Math01p,'linear');
%% Plot Raw Data
figure(1)
t=OSCdata.xRange(1)+1/OSCdata.SampleRate:1/OSCdata.SampleRate:OSCdata.xRange(2);
% plot(t,OSCdata.Chn01,'b');
hold on;
plot(t,OSCdata.Chn01,'r','LineWidth',1);
plot(t,OSCdata.Chn02,'g','LineWidth',0.6);
plot(t,Math01,'blue','LineWidth',1.2);
set(gca,'FontSize',16);
xlim(OSCdata.xRange);
xlabel('Time (s)','FontSize',20);
ylabel('Voltage (V)','FontSize',20);
legend({'Channel 01','Channel 02'},'FontSize',18,'Location','southeast');
title([OSCdata.Name ' Raw data vision '],'Interpreter','none','FontSize',28);
hold off;
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,[OSCdata.FullName '_01Raw.png']);
% saveFigMultiAxes(1,axesHandles,figSize,axesSizeRatio,fontName,fontSize,figName,figType,figResolution)

figure(2)
hold on;
plot(OSCdata.Chn01, Math01/0.5*50/0.08*1000);
xlabel('激励电流(A)','FontSize',20);
ylabel('感应磁场强度(A/m)','FontSize',20);

% plot(OSCdata.Chn01, Math01p);
