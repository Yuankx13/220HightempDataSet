function exeHandle=plot_Hysterisis(figHandle, Name, FullName, Hexec,...
    Bsens, xRange, yRange)
figure(figHandle);
hold on;
scatter(Hexec,Bsens,'r+');
set(gca,'FontSize',16);
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
xlabel('H (A\cdot m)','FontSize',20);
ylabel('\mu','FontSize',20);
xlim(xRange);
ylim(yRange);
hold off;
title([Name ' Mu'],'Interpreter','none','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(FullName, '_Mu.fig'));
saveas(gcf,strcat(FullName, '_Mu.svg'));
saveas(gcf,strcat(FullName, '_Mu.png'));
close(figHandle);
exeHandle=1;
end

