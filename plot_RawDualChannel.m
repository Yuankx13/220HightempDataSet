function exeHandle=plot_RawDualChannel(figHandle, xRange, SampRate,...
    Name, FullName, Chn01, Chn02)

t=xRange(1)+1/SampRate:1/SampRate:xRange(2);
figure(figHandle);
hold on;
plot(t,Chn01,'r','LineWidth',1.2);
plot(t,Chn02,'b','LineWidth',1.2);
hold off;

set(gca,'FontSize',20);
set(gca,'LineWidth',1);
xlim(xRange);
xlabel('Time (s)','FontSize',24);
ylabel('Voltage (V)','FontSize',24);
legend({'Channel 01','Channel 02'},'FontSize',20,'Location','southeast');
title([Name ' Raw data vision '],'Interpreter','none','FontSize',28);
set(gca,'XAxisLocation','origin');
% set(gca,'YAxisLocation','origin');

set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(FullName, '_Raw.svg'));
% saveas(gcf,strcat(FullName, '_Raw.fig'));
saveas(gcf,strcat(FullName, '_Raw.png'));
close(figHandle);
exeHandle=1;
end