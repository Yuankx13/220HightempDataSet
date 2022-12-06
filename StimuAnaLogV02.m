Ae = 0.088/100/100;
N1 = 54;
le = 3.85/100;
expoL = Ae*N1*N1/le;
mu0 = 4e-7*pi();


dirName='./20220920/LOG/';
dataCluster=string(ls(dirName));
if isunix()
    [dataCluster,~]=strsplit(dataCluster);
end
dataCluster=dataCluster(contains(dataCluster, '.CSV'));
fileCluster=strcat(dirName, dataCluster);
dataCount = size(dataCluster,1);
tempC = zeros(1,dataCount);
colorPool = ["black" "blue" "magenta" "cyan" "red"];

for i=1:dataCount
    ImpeData(i).data=read_KeysightE4990A(fileCluster(i)); %#ok<SAGROW>    
    tempCBuff = erase(strsplit(dataCluster(i),'-'),'.CSV');
    tempC(i) = str2double(tempCBuff(2)); 
end

% name = 'Trace01.csv';
figure(1);
% p(1)=semilogx(ImpeData(1).data.Freq, ImpeData(1).data.Ls_H__data*1000,...
%     'LineWidth',1.2, 'Color', 'k','DisplayName', [num2str(tempC(1)) '^{\circ}C']);
for i=1:dataCount    
    p(i)=semilogx(ImpeData(i).data.Freq, ImpeData(i).data.Ls_H__data*1000,...
        'LineWidth',1.2,'DisplayName', [num2str(tempC(i)) '^{\circ}C'],...
        'Color',colorPool(i));
    hold on
end
hold off;
legend(p,'Location','northeast','FontSize',18);
% ylim([0.02 400]);
% xlim([0 4000]);
set(gca,'fontsize',18);
ylabel('Ls (mH)','FontSize',24);
xlabel('Frequency (Hz)','FontSize',24);
set(gcf,'Position',[1,41,1536,755.6]);
set(gcf,'Color','none');
saveas(gcf,strcat(dirName, 'LsFigure.fig'));
% saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.pdf'));
saveas(gcf,strcat(dirName, 'LsFigure.svg'));
saveas(gcf,strcat(dirName, 'LsFigure.png'));
close(1);


figure(2);
sub1=subplot(211);
% p(1)=loglog(ImpeData(1).data.Freq, ImpeData(1).data.x_Z__Ohm__data,...
%     'LineWidth',1.2, 'Color', 'k','DisplayName', [num2str(tempC(1)) '^{\circ}C']);
for i=1:dataCount    
    p(i)=loglog(ImpeData(i).data.Freq, ImpeData(i).data.x_Z__Ohm__data,...
        'LineWidth',1.2,'DisplayName', [num2str(tempC(i)) '^{\circ}C'],...
        'Color',colorPool(i));
    hold on
end
[~,savP(1)]=min(abs(ImpeData(1).data.Freq-1000));
[~,savP(2)]=min(abs(ImpeData(4).data.Freq-1000));
[~,savP(3)]=min(abs(ImpeData(5).data.Freq-1000));
% plot(ImpeData(1).data.Freq(savP(1)),ImpeData(1).data.x_Z__Ohm__data(savP(1)),...
%     'x','MarkerSize',18, 'Color',colorPool(1));
% text(ImpeData(1).data.Freq(savP(1)),ImpeData(1).data.x_Z__Ohm__data(savP(1)),...
%     strcat('|Z| = ', num2str(ImpeData(1).data.x_Z__Ohm__data(savP(1)),'%.1f'),'\Omega'),...
%     'FontSize',20, 'Color',colorPool(1));
% plot(ImpeData(2).data.Freq(savP(2)),ImpeData(2).data.x_Z__Ohm__data(savP(2)),...
%     'x','MarkerSize',18, 'Color',colorPool(2));
% text(ImpeData(2).data.Freq(savP(2)),ImpeData(2).data.x_Z__Ohm__data(savP(2)),...
%     strcat('|Z| = ', num2str(ImpeData(2).data.x_Z__Ohm__data(savP(2)),'%.1f'),'\Omega'),...
%     'FontSize',20, 'Color',colorPool(2));
% plot(ImpeData(5).data.Freq(savP(3)),ImpeData(5).data.x_Z__Ohm__data(savP(3)),...
%     'x','MarkerSize',18, 'Color',colorPool(5));
% text(ImpeData(5).data.Freq(savP(3)),ImpeData(5).data.x_Z__Ohm__data(savP(3)),...
%     strcat('|Z| = ', num2str(ImpeData(5).data.x_Z__Ohm__data(savP(3)),'%.1f'),'\Omega'),...
%     'FontSize',20, 'Color',colorPool(5));
hold off;
% legend(p,'Location','best');
% ylim([0.02 400]);
% xlim([0 4000]);
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('|Z| (\Omega)','FontSize',24);
a = get(sub1,'YLabel');
a.Position(1) = a.Position(1)-1;
set(sub1, 'YLabel', a);
legend(p,'Location','northwest','Fontsize',18);
xticklabels({});
sub2=subplot(212);
% p(1)=semilogx(ImpeData(1).data.Freq, ImpeData(1).data.theta_z_deg__data,...
%     'LineWidth',1.2, 'Color', 'k','DisplayName', [num2str(tempC(1)) '^{\circ}C']);
for i=1:dataCount    
    p(i)=semilogx(ImpeData(i).data.Freq, ImpeData(i).data.theta_z_deg__data,...
        'LineWidth',1.2,'DisplayName', [num2str(tempC(i)) '^{\circ}C'],...
        'Color',colorPool(i));
    hold on
end
hold off;
% legend(p,'Location','southeast','Fontsize',16);
ylim(ylim()*1.1);
% xlim([0 4000]);
set(gca,'FontSize',20);
set(gca,'LineWidth',1);
ylabel('Phase Angle','FontSize',24);
a = get(sub2,'YLabel');
a.Position(1) = a.Position(1)-1;
set(sub2, 'YLabel', a);
ytickformat('degrees');
xlabel('Frequency (Hz)','FontSize',24);

Bar1=get(sub1,'Position');
Bar2=get(sub2,'Position');
BarM = (Bar1(2)-(Bar2(2)+Bar2(4)))/2;
Bar1(2) = Bar1(2) - BarM;
Bar1(4) = Bar1(4) + BarM;
Bar2(4) = Bar2(4) + BarM;
set(sub1,'Position',Bar1);
set(sub2,'Position',Bar2);
set(gcf,'Position',[1,41,1536,755.6]);
set(gcf,'Color','none');
a = get(sub1,'YLabel');
a.Position(1) = a.Position(1)-0.5;
% set(sub1, 'YLabel', a);
a = get(sub2,'YLabel');
a.Position(1) = a.Position(1)-0.5;
% set(sub2, 'YLabel', a);
saveas(gcf,strcat(dirName, 'ZthetaFigure.fig'));
% saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.pdf'));
saveas(gcf,strcat(dirName, 'ZthetaFigure.svg'));
saveas(gcf,strcat(dirName, 'ZthetaFigure.png'));
% close(2);

% legend({'Unsaturated, 25^\circ C','Saturated, 25^\circ C','Unsaturated, 135^\circ C'...
%     ,'Saturated, 135^\circ C','Unsaturated, 175^\circ C','Saturated, 175^\circ C'...
%     ,'Unsaturated, 220^\circ C','Saturated, 220^\circ C'},'Location','east','FontSize',16);


figure(4);
% p(1)=semilogx(ImpeData(1).data.Freq, ImpeData(1).data.Ls_H__data/expoL/mu0,...
%     'LineWidth',1.2, 'Color', 'k','DisplayName', [num2str(tempC(1)) '^{\circ}C']);
for i=1:dataCount    
    p(i)=semilogx(ImpeData(i).data.Freq, ImpeData(i).data.Ls_H__data/expoL/mu0,...
        'LineWidth',1.2,'DisplayName', [num2str(tempC(i)) '^{\circ}C'],...
        'Color',colorPool(i));
    hold on
end

legend(p,'Location','northeast','FontSize',18);
% ylim([0.02 400]);
% xlim([0 4000]);
set(gca,'fontsize',18);
[~,savP(1)]=min(abs(ImpeData(1).data.Freq-1000));
[~,savP(2)]=min(abs(ImpeData(4).data.Freq-1000));
[~,savP(3)]=min(abs(ImpeData(5).data.Freq-1000));
plot(ImpeData(1).data.Freq(savP(1)),ImpeData(1).data.Ls_H__data(savP(1))/expoL/mu0,...
    'x','MarkerSize',18, 'Color',colorPool(1));
text(ImpeData(1).data.Freq(savP(1))*1.05,ImpeData(1).data.Ls_H__data(savP(1))/expoL/mu0+500,...
    strcat('\mu_i = ', num2str(ImpeData(1).data.Ls_H__data(savP(1))/expoL/mu0,'%.3e')),...
    'FontSize',20, 'Color',colorPool(1));
plot(ImpeData(2).data.Freq(savP(2)),ImpeData(2).data.Ls_H__data(savP(2))/expoL/mu0,...
    'x','MarkerSize',18, 'Color',colorPool(2));
text(ImpeData(2).data.Freq(savP(2))*1.05,ImpeData(2).data.Ls_H__data(savP(2))/expoL/mu0+500,...
    strcat('\mu_i = ', num2str(ImpeData(2).data.Ls_H__data(savP(2))/expoL/mu0,'%.3e')),...
    'FontSize',20, 'Color',colorPool(2));
plot(ImpeData(5).data.Freq(savP(3)),ImpeData(5).data.Ls_H__data(savP(3))/expoL/mu0,...
    'x','MarkerSize',18, 'Color',colorPool(5));
text(ImpeData(5).data.Freq(savP(3))*1.05,ImpeData(5).data.Ls_H__data(savP(3))/expoL/mu0+500,...
    strcat('\mu_i = ', num2str(ImpeData(5).data.Ls_H__data(savP(3))/expoL/mu0,'%.3e')),...
    'FontSize',20, 'Color',colorPool(5));
hold off;
legend(p,'Location','northeast','FontSize',18);
ylabel('\mu_i','FontSize',32);
xlabel('Frequency (Hz)','FontSize',24);
set(gcf,'Position',[1,41,1536,755.6]);
set(gcf,'Color','none');
saveas(gcf,strcat(dirName, 'muFigure.fig'));
% saveas(gcf,strcat(dirName, 'IntensityFigures/ThermalValue.pdf'));
saveas(gcf,strcat(dirName, 'muFigure.svg'));
saveas(gcf,strcat(dirName, 'muFigure.png'));
close(4);



