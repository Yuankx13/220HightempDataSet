

name = 'Trace01.csv';
plot(Trace01.Freq, Trace01.Ls*1000,'r','LineWidth',1.2);
hold on
plot(Trace02.Freq, Trace02.Ls*1000,'b','LineWidth',1.2);
plot(Trace03.Freq, Trace03.Ls*1000,'m','LineWidth',1.2);
plot(Trace04.Freq, Trace04.Ls*1000,'g','LineWidth',1.2);
set(gca,'fontsize',18);
ylabel('������Ч���Ls (mH)','FontSize',20);
xlabel('Ƶ�ʣ�Hz)','FontSize',20);
legend({'��о����ǰ��25^\circ C','��о���ͺ�25^\circ C','��о����ǰ��135^\circ C','��о���ͺ�135^\circ C'},'Location','northeast','FontSize',18);
