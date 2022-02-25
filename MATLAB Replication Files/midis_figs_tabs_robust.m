%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%                          MIDIS                        %%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%          By M. Aykut Attar & Ayça Tekin-Koru          %%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%                       Nov 7, 2021                     %%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clean the workspace & close the figures:

clc
clear
close all

%% Load the data for alternative runs:

load('midis_robust_alfab.mat')
Db = double(exportmidisb(:,3:end)); Db = Db'; 

load('midis_robust_alfa1.mat')
D1 = double(exportmidis1(:,3:end)); D1 = D1';

load('midis_robust_alfa2.mat')
D2 = double(exportmidis2(:,3:end)); D2 = D2';

load('midis_robust_100thCase.mat')
D3 = double(exportmidis100(:,3:end)); D3 = 100*D3; D3 = D3';

load('midis_robust_60days.mat')
D4 = double(exportmidis60(:,3:end)); D4 = 100*D4; D4 = D4';

%% Figure A.1

figure(1)
subplot(2,1,1)
plot(Db(:,100),'Color','black','LineWidth',1.5)
hold on
plot(D1(:,100),'or','LineWidth',1.5)
plot(D2(:,100),'sb','LineWidth',1.5)
hold off
xlim([0 31])
ylim([40 100])
grid on
title('South Korea')
ylabel('percent','FontSize',10)
legend('benchmark','low \alpha','high \alpha','FontSize',10,'Location','SouthEast')
subplot(2,1,2)
plot(Db(:,114),'Color','black','LineWidth',1.5)
hold on
plot(D1(:,114),'or','LineWidth',1.5)
plot(D2(:,114),'sb','LineWidth',1.5)
hold off
xlim([0 31])
ylim([40 100])
grid on
title('USA')
ylabel('percent','FontSize',10)
xlabel('30 days after the 500th COVID-19 case','FontSize',10)
saveas(gcf,'figa1','epsc')

%% Figure A.2

figure(2)
plot(Db(:,100),'Color','red','LineWidth',1.5)
hold on
plot(D3(:,100),'--','Color','red','LineWidth',1.5)
plot(Db(:,114),'Color','blue','LineWidth',1.5)
plot(D3(:,114),'--','Color','blue','LineWidth',1.5)
hold off
xlim([0 31])
ylim([25 100])
grid on
ylabel('percent')
xlabel('30 days after the 500th (or 100th) COVID-19 case')
legend('benchmark (30 days after the 500th case) - South Korea','30 days after the 100th case - South Korea','benchmark (30 days after the 500th case) - USA','30 days after the 100th case - USA','FontSize',10,'Location','SouthEast')
saveas(gcf,'figa2','epsc')

%% Figure A.3

figure(3)
plot(Db(:,100),'Color','red','LineWidth',1.5)
hold on
plot(D4(:,100),'--','Color','red','LineWidth',1.5)
plot(Db(:,114),'Color','blue','LineWidth',1.5)
plot(D4(:,114),'--','Color','blue','LineWidth',1.5)
hold off
xlim([0 61])
ylim([45 100])
grid on
ylabel('percent')
xlabel('30 days (or 60 days) after the 500th COVID-19 case')
legend('benchmark (30 days) - South Korea','60 days - South Korea','benchmark (30 days) - USA','60 days - USA','FontSize',10,'Location','SouthEast')
saveas(gcf,'figa3','epsc')

%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%