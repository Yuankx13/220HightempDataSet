function exeHandle=plot_RawHysterTimeSeri(figHandle, xRange, SampRate, Name,...
    FullName, Chn01, Chn02, Math01)
t=xRange(1)+1/SampRate:1/SampRate:xRange(2);
figure(figHandle);
hold on;
plot(t,Chn01,'r','LineWidth',1);
plot(t,Chn02,'k','LineWidth',0.6);
plot(t,Math01,'blue','LineWidth',1.2);
set(gca,'FontSize',16);
xlim(xRange);
xlabel('Time (s)','FontSize',20);
ylabel('Voltage (V)','FontSize',20);
legend({'Channel 01','Channel 02','Math01\cdot 10000'},'FontSize',18,'Location','southeast');
title([Name ' Raw data vision '],'Interpreter','none','FontSize',28);
hold off;
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(FullName, '_01Raw.png'));
close(figHandle);
exeHandle=1;
end