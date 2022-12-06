function [exeHandle, Intens0, IntensP, IntensN]=plot_RawCalibFourier(Data0,...
    DataP, DataN, Len,SampRate, FigName, FigHandle, FullName, FreqPoint)
Data0Ft = abs(fft(Data0)/Len);
DataPFt = abs(fft(DataP)/Len);
DataNFt = abs(fft(DataN)/Len);
F=(0:Len/2)*SampRate/Len;
Data0Ft = Data0Ft(1:max(size(F)));
DataPFt = DataPFt(1:max(size(F)));
DataNFt = DataNFt(1:max(size(F)));
[~, FreqT1]=min(abs(F-FreqPoint));
[~, FreqT2]=min(abs(F-2*FreqPoint));

figure(FigHandle);
hold on;
semilogy(F, Data0Ft,'black','LineWidth',1.2);
semilogy(F, DataPFt,'red','LineWidth',1.2);
semilogy(F, DataNFt,'blue','LineWidth',1.2);
set(gca,'FontSize',16);
set(gca,'LineWidth',1);
ylim([1e-5 0.05]);
xlim([0 8e3]);
xlabel('Frequency (s)','FontSize',20);
ylabel('Intensity (dB)','FontSize',20);
title([FigName ' Raw data Fourier Spectrum'],'Interpreter','none','FontSize',28);
yax = ylim;
plot([FreqPoint FreqPoint], yax, 'k-.', 'LineWidth', 1.8);
plot([FreqPoint*2 FreqPoint*2], yax, 'k-.', 'LineWidth', 1.8);
% txt1=[num2str(F(FreqT1)), 'Hz',...
%     char(13,10)', 'ZeroField:', num2str(Intens1Fq,'%e'), 'dB'...
%     char(13,10)', 'PositiveField:', num2str(Intens1Fq,'%e'), 'dB'...
%     char(13,10)', 'NegativeField:', num2str(Intens1Fq,'%e'), 'dB'];
% txt2=[num2str(F(FreqT2)), 'Hz', char(13,10)', 'Y:', num2str(Intens2Fq,'%e'), 'dB'];
text(FreqPoint*1.05, Data0Ft(FreqT1)*1.05, strcat('ZeroField:',num2str(Data0Ft(FreqT1))), 'Color','black', 'FontSize',24);
text(FreqPoint*2*1.05, Data0Ft(FreqT1)*0.75, strcat('ZeroField:',num2str(Data0Ft(FreqT2))), 'Color','black', 'FontSize',24);
text(FreqPoint*1.05, Data0Ft(FreqT1)*0.95, strcat('PositiveField:',num2str(DataPFt(FreqT1))),'Color','red', 'FontSize',24);
text(FreqPoint*2*1.05, Data0Ft(FreqT1)*0.65, strcat('PositiveField:',num2str(DataPFt(FreqT2))), 'Color','red', 'FontSize',24);
text(FreqPoint*1.05, Data0Ft(FreqT1)*0.85, strcat('NegativeField:',num2str(DataNFt(FreqT1))), 'Color','blue', 'FontSize',24);
text(FreqPoint*2*1.05, Data0Ft(FreqT1)*0.55, strcat('NegativeField:',num2str(DataNFt(FreqT2))), 'Color','blue', 'FontSize',24);
% text(F(FreqT2)*1.05, HysterFt(FreqT2)*1.05, txt2, 'FontSize',24,'Color', 'r');
hold off;
Intens0 = Data0Ft(FreqT2);
IntensP = DataPFt(FreqT2);
IntensN = DataNFt(FreqT2);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(FullName, '_FFT.svg'));
saveas(gcf,strcat(FullName, '_FFT.png'));
close(FigHandle);
exeHandle=1;
