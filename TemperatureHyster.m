figHandle = 1;
chosenTemp = [1 7 12 17 22 23];
colorPool = ["black" "blue" "magenta" "green" "cyan" "red"];
figure(figHandle);
hold on;
for i=1:6
    choseP = chosenTemp(i);
    plot(HysterAv(choseP).Hexec,2.4*HysterAv(choseP).Bsens,...
        'Color',colorPool(i),'LineWidth',1.2);
end

set(gca,'FontSize',16);
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
xlabel('H (A{\cdot}m)','FontSize',20);
ylabel('B (T)','FontSize',20);
xlim(HysterXR);
ylim(2.4*HysterYR*1.15);
legend({'25^{\circ}C','70^{\circ}C','120^{\circ}C','170^{\circ}C',...
    '220^{\circ}C','230^{\circ}C'},'FontSize',20,'Location','southeast');
hold off;
box on;
% title([Name ' Hysterisis'],'Interpreter','none','FontSize',28);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,'Temperature_StackHyster.fig');
saveas(gcf,'Temperature_StackHyster.png');
% saveas(gcf,strcat(FullName, '_StackHysterisis.svg'));
% saveas(gcf,strcat(FullName, '_StackHysterisis.png'));
% close(figHandle);