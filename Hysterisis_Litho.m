load('./220914ykx/HysterisisAxis.mat');
dirName = './220914ykx/';
figure(1)
mu0 = 4*pi*power(10,-7);
volumeSamp = 0.01*0.005*20*power(10,-6);

figure(1);
plot(axisShort.Field_Adj, axisShort.Moment_Adj,'b','LineWidth', 1.2);
hold on;
plot(axisLong.Field_Adj, axisLong.Moment_Adj, 'r', 'LineWidth', 1);
hold off;
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('Moment (Am^2)','FontSize',24);
xlabel('Field (T)','FontSize',24);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'Hysterisis.fig'));
saveas(gcf,strcat(dirName, 'Hysterisis.png'));
saveas(gcf,strcat(dirName, 'Hysterisis.svg'));
close(1);

Field_AdjH = axisLong.Field_Adj/mu0;
FluxDens_AdjH = axisLong.Moment_Adj/volumeSamp*mu0;

figure(2);
plot(Field_AdjH, FluxDens_AdjH,'r','LineWidth', 1.2);
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
set(gca,'FontSize',24);
set(gca,'LineWidth',1);
ylabel('B (T)','FontSize',26);
xlabel('H (A/m)','FontSize',26);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'HysterisisR.fig'));
saveas(gcf,strcat(dirName, 'HysterisisR.png'));
saveas(gcf,strcat(dirName, 'HysterisisR.svg'));
close(2);


figure(3)
plot(axisShort.Field_Adj, axisShort.Moment_Adj/0.005,'b','LineWidth', 1.2);
hold on;
plot(axisLong.Field_Adj, axisLong.Moment_Adj/0.01, 'r', 'LineWidth', 1);
hold off;
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('Induced Field (A{\cdot}m)','FontSize',24);
xlabel('Ambient Field (T)','FontSize',24);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'HysterisisF.fig'));
saveas(gcf,strcat(dirName, 'HysterisisF.png'));
saveas(gcf,strcat(dirName, 'HysterisisF.svg'));
close(3);

Field_AdjHS = axisShort.Field_Adj/mu0;
FluxDens_AdjHS = axisShort.Moment_Adj/volumeSamp*mu0;

figure(2);
plot(Field_AdjHS, FluxDens_AdjHS,'b','LineWidth', 1.2);
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
set(gca,'FontSize',24);
set(gca,'LineWidth',1);
ylabel('B (T)','FontSize',26);
xlabel('H (A/m)','FontSize',26);
set(gcf,'Position',[1,41,1536,755.6]);
saveas(gcf,strcat(dirName, 'HysterisisR.fig'));
saveas(gcf,strcat(dirName, 'HysterisisR.png'));
saveas(gcf,strcat(dirName, 'HysterisisR.svg'));
close(2);
