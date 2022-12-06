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
dirName='./Test2/muTest/';
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
parfor i=1:dataCount
    OSCdata(i)=read_RohdeWavePair(fileCluster(i));
end
toc;
parfor i=1:dataCount
    Math01(i,:)=detrend(cumtrapz(1/OSCdata(i).SampleRate, OSCdata(i).Chn02),'linear');
end
toc;

%% Draw Those Raw Data
mkdir(strcat(dirName, 'RawDataFigures/'));
parfor i=1:dataCount
    plot_RawHysterTimeSeri(i, OSCdata(i).xRange,OSCdata(i).SampleRate,...
        OSCdata(i).Name, strcat(dirName, 'RawDataFigures/', OSCdata(i).Name)...
        , OSCdata(i).Chn01, OSCdata(i).Chn02, Math01(i,:).*10000);
    HysterC(i).Hexec = OSCdata(i).Chn01/Res.Exec*CoilExpo.Exec/0.5;
    HysterC(i).Bsens = -detrend(Math01(i,:)'*CoilExpo.Sens,'linear');
%     HysterFt(i) = abs(fft(HysterC(i).Hexec)/OSCdata(i).Len);
%     F(i)=(0:OSCdata(i).Len/2)*OSCdata(i).SampleRate/OSCdata(i).Len;
end
toc;

%% Draw Raw data Frequency Spectrum
Intens1Fq = NaN(dataCount, 1);
Intens2Fq = NaN(dataCount, 1);
mkdir(strcat(dirName, 'FFTFigures/'));
parfor i=1:dataCount    
    [~, Intens1Fq(i), Intens2Fq(i)] = plot_RawHysterFourier(HysterC(i).Hexec,...
        OSCdata(i).Len, OSCdata(i).SampleRate, OSCdata(i).Name, i+dataCount,...
        strcat(dirName, 'FFTFigures/', OSCdata(i).Name), 1000);
end
toc;

%% Draw Spectrum Key Frequency Trend
figure(dataCount*2+1);
plot(Intens1Fq,'r','LineWidth',1.2);
set(gca,'FontSize',16);
ylabel('Intensity (dB)','FontSize',20);
legend({'Foundamental Frequency'},'FontSize',18,'Location','northeast');
xticks(1:dataCount);
for i=1:dataCount
    TrendTicks(i) = OSCdata(i).Name;
end
xticklabels(TrendTicks(:));
xtickangle(45);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'FFTFigures/FoundamentalIntense_01Raw.png'));
close(dataCount*2+1);
toc;

figure(dataCount*2+2);
plot(Intens2Fq,'b','LineWidth',1.4);
set(gca,'FontSize',16);
ylabel('Intensity (dB)','FontSize',20);
legend({'Secondary Frequency'},'FontSize',18,'Location','northeast');
xticks(1:dataCount);
xticklabels(TrendTicks(:));
xtickangle(45);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'FFTFigures/SecondaryIntense_01Raw.png'));
close(dataCount*2+2);
toc;

%% CoPhase Stacking
parfor i=1:dataCount
    HysterAv(i).Hexec = SamePhaseStack_KX(1000, 200000, HysterC(i).Hexec);
    HysterAv(i).Bsens = SamePhaseStack_KX(1000, 200000, HysterC(i).Bsens);
end
toc;
xRBuff = NaN(dataCount, 1);
yRBuff = NaN(dataCount, 1);
parfor i=1:dataCount
    xRBuff(i) = max(abs(HysterC(i).Hexec));
    yRBuff(i) = max(abs(HysterC(i).Bsens));
end
HysterXR = [-max(xRBuff) max(xRBuff)];
HysterYR = [-max(yRBuff) max(yRBuff)];
%% Draw Stack
mkdir(strcat(dirName, 'RawHysterisis/'));
parfor i=1:dataCount
    plot_Hysterisis(i, OSCdata(i).Name, strcat(dirName, 'RawHysterisis/',...
        OSCdata(i).Name), HysterC(i).Hexec, HysterC(i).Bsens, HysterXR, HysterYR);
end
toc;

mkdir(strcat(dirName, 'StackHysterisis/'));
parfor i=1:dataCount
    plot_Hysterisis(i, OSCdata(i).Name, strcat(dirName, 'StackHysterisis/',...
        OSCdata(i).Name), HysterAv(i).Hexec, HysterAv(i).Bsens, HysterXR, HysterYR);
end
toc;

%% Permeability
Mu=zeros(dataCount,1999);
parfor i=1:dataCount
    Mu(i,:) = abs(diff(HysterC(i).Bsens)./diff(HysterC(i).Hexec));
end
toc;
muRBuff = NaN(dataCount, 1);
parfor i=1:dataCount
    muRBuff(i) = max(abs(Mu(i)));
end
MuYR = [0 max(muRBuff)];
mkdir(strcat(dirName, 'RawMu/'));
parfor i=1:dataCount
    plot_HysterMu(i, OSCdata(i).Name, strcat(dirName, 'RawMu/',...
        OSCdata(i).Name), HysterC(i).Hexec(1:end-1), Mu(i,:), HysterXR, MuYR);
end
toc;
% Hexec=OSCdata.Chn01./Res.Exec*CoilExpo.Exec;
% Bsens=Math01.*CoilExpo.Sens;
% Math01LP=lowpass(Math01(1,:),3000,OSCdata(1).SampleRate);