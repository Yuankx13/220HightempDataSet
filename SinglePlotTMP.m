%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clustering Wave Form Data
clear all;

%% Calculate Coil Specs
CoilSpec.EXEC=54;
CoilSpec.SENS=10;
k=[1 1];
CoilExpo.Exec=k(1)*CoilSpec.EXEC;
CoilExpo.Sens=k(2)*1/((5)/1000*0.005*CoilSpec.SENS);
Res.Exec=0.5;
Res.Sens=1.0;

%% Import data
dirName='./Test2/Temp03/';
dataCluster=string(ls(dirName));
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
for i=1:dataCount
    OSCdata(i)=read_RohdeWavePair(fileCluster(i));
end
toc;
% for i=1:dataCount
%     Math01(i,:)=detrend(cumtrapz(1/OSCdata(i).SampleRate, OSCdata(i).Chn02),'linear');
% end
% toc;

t=OSCdata(1).xRange(1)+1/OSCdata(1).SampleRate:1/OSCdata(1).SampleRate:OSCdata(1).xRange(2);
figure(1);
hold on;
plot(t,OSCdata(1).Chn01,'r','LineWidth',1.5);
% plot(t,OSCdata(1).Chn02,'k','LineWidth',0.6);
xlim(OSCdata(1).xRange(:)/2);
set(gca,'FontSize',18);
set(gca,'Linewidth',1.2);
xlabel('Time (s)','FontSize',24);
ylabel('Current (A)','FontSize',24);
set(gcf,'Position',[1,41,1536,755.6]);
Ytk = yticks();
yticklabels(sprintfc('%2.1f', Ytk*2));