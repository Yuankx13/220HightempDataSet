

name = 'Trace01.csv';
plot(Trace01.Freq, Trace01.Ls*1000,'r','LineWidth',1.2);
hold on
plot(Trace02.Freq, Trace02.Ls*1000,'b','LineWidth',1.2);
plot(Trace03.Freq, Trace03.Ls*1000,'m','LineWidth',1.2);
plot(Trace04.Freq, Trace04.Ls*1000,'g','LineWidth',1.2);
set(gca,'fontsize',18);
ylabel('串联等效电感Ls (mH)','FontSize',20);
xlabel('频率（Hz)','FontSize',20);
legend({'磁芯饱和前，25^\circ C','磁芯饱和后，25^\circ C','磁芯饱和前，135^\circ C','磁芯饱和后，135^\circ C'},'Location','northeast','FontSize',18);
