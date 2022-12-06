
load('Traces.mat');
T1=Trace01.Ls ./ Trace02.Ls;
T3=Trace03.Ls ./ Trace04.Ls/2;
T5=Trace05.Ls ./ Trace06.Ls*3;
T7=Trace07.Ls ./ Trace08.Ls*10;

figure(1);
semilogy(Trace01.Freq, T1,'LineWidth',1.6);
hold on
% semilogy(Trace02.Freq, Trace02.Ls*1000,'LineWidth',1.2);
semilogy(Trace03.Freq, T3,'LineWidth',1.6);
% semilogy(Trace04.Freq, Trace04.Ls*1000,'LineWidth',1.2);
semilogy(Trace05.Freq, T5,'LineWidth',1.6);
% semilogy(Trace06.Freq, Trace06.Ls*1000,'LineWidth',1.2);
semilogy(Trace07.Freq, T7,'LineWidth',1.6);
% semilogy(Trace08.Freq, Trace08.Ls*1000,'LineWidth',1.2);
ylim([0 1000]);
xlim([0 10000]);
set(gca,'fontsize',20);
ylabel('串联等效电感突变比例Ls_0/Ls_{Sat}','FontSize',24);
xlabel('频率（Hz）','FontSize',24);
legend({'25^\circ C','135^\circ C','175^\circ C','220^\circ C'},'Location','northeast','FontSize',20);
% legend({'磁芯饱和前，25^\circ C','磁芯饱和后，25^\circ C','磁芯饱和前，135^\circ C'...
%     ,'磁芯饱和后，135^\circ C','磁芯饱和前，175^\circ C','磁芯饱和后，175^\circ C'...
%     ,'磁芯饱和前，220^\circ C','磁芯饱和后，220^\circ C'},'Location','east','FontSize',16);
hold off;

figure(2);
plot(Trace01.Freq, Trace01.Ls*1000,'LineWidth',1.2);
hold on
% semilogy(Trace02.Freq, Trace02.Ls*1000,'LineWidth',1.2);
plot(Trace03.Freq, Trace03.Ls*1000,'LineWidth',1.2);
% semilogy(Trace04.Freq, Trace04.Ls*1000,'LineWidth',1.2);
plot(Trace05.Freq, Trace05.Ls*1000,'LineWidth',1.2);
% semilogy(Trace06.Freq, Trace06.Ls*1000,'LineWidth',1.2);
plot(Trace07.Freq, Trace07.Ls*1000,'LineWidth',1.2);
% semilogy(Trace08.Freq, Trace08.Ls*1000,'LineWidth',1.2);
% ylim([0.02 400]);
set(gca,'fontsize',18);
ylabel('串联等效电感Ls (mH)','FontSize',20);
xlabel('频率（Hz）','FontSize',20);
legend({'磁芯饱和前，25^\circ C','磁芯饱和前，135^\circ C','磁芯饱和前，175^\circ C'...
    ,'磁芯饱和前，220^\circ C'},'Location','northeast','FontSize',16);
hold off;
