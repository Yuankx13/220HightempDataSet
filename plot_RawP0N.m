function exeHandle=plot_RawP0N(figHandle, xRange, SampRate,...
    Name, FullName, SeriP, Seri0, SeriN)

t = -SeriP.Len*SeriP.Resol/2+SeriP.Resol:SeriP.Resol:SeriP.Len*SeriP.Resol/2;
% t = xRange(1)+1/SampRate:1/SampRate:xRange(2);
peridX = [t(1) t(end)]/500;
xtk = peridX(1):(peridX(2)-peridX(1))/10:peridX(2);
% maxP = max([max(abs(SeriP.Chn01)) max(abs(SeriP.Chn02))]);
% max0 = max([max(abs(Seri0.Chn01)) max(abs(Seri0.Chn02))]);
% maxN = max([max(abs(SeriN.Chn01)) max(abs(SeriN.Chn02))]);
maxX = max([max(abs(SeriP.Chn02)) max(abs(Seri0.Chn02))...
    max(abs(SeriN.Chn02))])*1.1;
maxY = max([max(abs(SeriP.Chn01)) max(abs(Seri0.Chn01))...
    max(abs(SeriN.Chn01))])*2.5;
Y1tk = [-3 0 3];

figure(figHandle);
set(gcf,'outerposition',get(0,'screensize'));

sub1=subplot(3,1,1);
hold on;
box on; 
yyaxis right;
plot(t,SeriP.Chn01/0.5,'r','LineWidth',1.2);
ylim([-maxY maxY]);
yticks(Y1tk);
yyaxis left;
plot(t,SeriP.Chn02,'b','LineWidth',1.2);
ylabel(['Positive' char(13,10)' ' '],'FontSize',24, 'Color','black');
hold off;
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
xlim(peridX);
ylim([-maxX maxX]);
xticks(xtk);
xticklabels({' ',' ',' ',' ',' ',' ',' ',' ',' ',' '});
% ylabel('Positive','FontSize',24);
% legend({'Positive Field EXC','Positive Field SEN'},'FontSize',16,'Location','southeast');
% title([Name ' Bi-Direction Field Co-Responding Signal'],'Interpreter','none','FontSize',28);
% set(gca,'XAxisLocation','origin');

sub2=subplot(3,1,2);
hold on;
box on;
yyaxis right;
plot(t,Seri0.Chn01/0.5,'r','LineWidth',1.2);
ylabel('Current (A)','FontSize',24, 'Color','black');
ylim([-maxY maxY]);
yticks(Y1tk);
yyaxis left;
plot(t,Seri0.Chn02,'b','LineWidth',1.2);
ylabel(['Zero Field' char(13,10)' 'Voltage (V)'],'FontSize',24, 'Color','black');
hold off;
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
xlim(peridX);
ylim([-maxX maxX]);
xticks(xtk);
xticklabels({' ',' ',' ',' ',' ',' ',' ',' ',' ',' '});
% ylabel({'$\rm{Annual}\;\Delta{\it{S}}$';'$\rm{(mm\,year^{-1})}$'},'interpreter','latex');
% ylabel(['Voltage (V)' char(13,10)' 'Zero Field'],'FontSize',24);
legend({'IND','EXC'},'FontSize',16,'Location','southeast');
% title([Name ' Raw data vision '],'Interpreter','none','FontSize',28);
% set(gca,'XAxisLocation','origin');


sub3=subplot(3,1,3);
hold on;
box on;
yyaxis right;
plot(t,SeriN.Chn01/0.5,'r','LineWidth',1.2);
ylim([-maxY maxY]);
yticks(Y1tk);
yyaxis left;
plot(t,SeriN.Chn02,'b','LineWidth',1.2);
ylabel(['Negative' char(13,10)' ' '],'FontSize',24, 'Color','black');
hold off;
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
xlim(peridX);
ylim([-maxX maxX]);
xticks(xtk);
% xticklabels({' ',' ',' ',' ',' ',' ',' ',' ',' ',' '});
% ylabel('Negative','FontSize',24);
xlabel('Time (S)','FontSize',24);
% legend({'Negative Field EXC', 'Negative Field SEN'},'FontSize',16,'Location','southeast');
% title([Name ' Raw data vision '],'Interpreter','none','FontSize',28);
% set(gca,'XAxisLocation','origin');

Bar1=get(sub1,'Position');
Bar2=get(sub2,'Position');
Bar1(2)=Bar2(2)+Bar2(4);
set(sub1,'Position',Bar1);
Bar3=get(sub3,'Position');
Bar3(2)=Bar2(2)-Bar3(4);
set(sub3,'Position',Bar3);
% Bar3=get(sub3,'Position');
set(sub2,'Position',Bar2);

set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(FullName, '_Raw.svg'));
saveas(gcf,strcat(FullName, '_Raw.png'));
close(figHandle);


exeHandle = 1;


