
clear all;

capPoint = [1 3];
freqPoint = [5 8];
showCase = 40;

dirName='./Test2/FreqSensTest/';
dataCluster=string(ls(dirName));
if isunix()
    [dataCluster,~]=strsplit(dataCluster);
end
dataHandle=contains(dataCluster, '.csv');
dataCluster(dataHandle==0)=[];
fileCluster=strcat(dirName, dataCluster);
dataCount=length(dataCluster);
tic;
capT = zeros(1,dataCount);
frqT = zeros(1,dataCount);
parfor i=1:dataCount
    Trace(i) = read_Keysight9020(fileCluster(i));
    [capT(i), frqT(i)] = nameSolveCapFreq(dataCluster(i), capPoint, freqPoint);
end
toc;
ampP = zeros(2,dataCount);
posP1 = zeros(1,dataCount);
posP2 = zeros(1,dataCount);
parfor i=1:dataCount
    posP1(i) = find(abs(Trace(i).Freq-frqT(i))==min(abs(Trace(i).Freq-frqT(i))),1);
    posP2(i) = find(abs(Trace(i).Freq-2*frqT(i))==min(abs(Trace(i).Freq-2*frqT(i))),1);
    ampP(:,i) = [Trace(i).Amp(posP1(i)) Trace(i).Amp(posP2(i))];
end
toc;
capP = [1 find(diff(capT)~=0)+1];
capD = capT(capP);
capC = max(size(capP));
rampAmpS = NaN(capC,showCase);
rampAmpF = NaN(capC,showCase);
rampFrq = NaN(capC,showCase);
buffAmp = zeros(capC,1);

parfor i=1:capC-1
    if capP(i)+showCase>capP(i+1)
        buffAmp(i) = capP(i+1)-capP(i);
    else
        buffAmp(i) = showCase;
    end
end
if capP(end)+showCase>dataCount
    buffAmp(end) = dataCount-capP(end);
else
    buffAmp(end) = showCase;
end
toc;
for i=1:capC
    rampFrq(i,1:buffAmp(i)) = frqT(capP(i):capP(i)+buffAmp(i)-1);
    rampAmpF(i,1:buffAmp(i)) = ampP(1,capP(i):capP(i)+buffAmp(i)-1);
    rampAmpS(i,1:buffAmp(i)) = ampP(2,capP(i):capP(i)+buffAmp(i)-1);
end
toc;

figure(1);
hold on;
for i=1:capC
%     capCH = char(capD(i));
%     capT = str2double(capCH(1:2))*power(10,str2double(capCH(3)));
    capT = floor(capD(i)/10)*power(10,mod(capD(i),10))/power(10,6);
    p(i)=semilogy(rampFrq(i,:),rampAmpF(i,:),'LineWidth', 1.5,'DisplayName',...
        [num2str(capT, '%.1f') '{\mu}F']);
end  
hold off;
legend(p,'Location','southeast','Fontsize',24);
set(gca,'FontSize',16);
set(gca,'LineWidth',1.5);
ylim([-45 -10]);
xlim([0 4000]);
xlabel('Frequency (Hz)','FontSize',20);
ylabel('Intensity (dBm)','FontSize',20);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'ExecFreqCap.fig'));
saveas(gcf,strcat(dirName, 'ExecFreqCap.svg'));
saveas(gcf,strcat(dirName, 'ExecFreqCap.png'));
close(1);
toc;