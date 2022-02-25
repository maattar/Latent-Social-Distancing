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

%% Clean the workspace & close the figures

clc
clear
close all

%% Load the MIDIS data (alternative runs with measurement errors)

load('midis_bm.mat')  % Benchmark
load('midis_mf1.mat') % Fixed Multiplication Factors
load('midis_mf2.mat')
load('midis_mf3.mat')
load('midis_mf4.mat')
load('midis_mf5.mat')
load('midis_tv1.mat') % Time-Varying Multiplication Factors
load('midis_tv2.mat')
load('midis_tv3.mat')
load('midis_tv4.mat')

%% Figures 3 and 4
dbm  = 100*Index_bm;
dmf1 = 100*Index_mf1;
dmf2 = 100*Index_mf2;
dmf3 = 100*Index_mf3;
dmf4 = 100*Index_mf4;
dmf5 = 100*Index_mf5;
dtv1 = 100*Index_tv1;
dtv2 = 100*Index_tv2;
dtv3 = 100*Index_tv3;
dtv4 = 100*Index_tv4;

clear Index_bm Index_mf1 Index_mf2 Index_mf3 Index_mf4 Index_mf5 Index_tv1 Index_tv2 Index_tv3 Index_tv4

figure(3)
subplot(2,1,1)
plot(dbm(:,100))
hold on
plot(dmf1(:,100),'o')
plot(dmf2(:,100),'s')
plot(dmf3(:,100),'d')
plot(dmf4(:,100),'x')
plot(dmf5(:,100),'+')
hold off
xlim([0 31])
ylim([30 100])
grid on
ylabel('percent')
xlabel('30 days after the 500th COVID-19 case')
title('South Korea')
legend('\phi^C=\phi^R=\phi^D=1 (benchmark)','\phi^C=\phi^R=\phi^D=3','\phi^C=\phi^R=\phi^D=7','\phi^C=7, \phi^R=\phi^D=3','\phi^C=2.9, \phi^R=\phi^D=2.2','\phi^C=2.9, \phi^R=1.6, \phi^D=2.2','Location','SouthEast','FontSize',8)
subplot(2,1,2)
plot(dbm(:,114))
hold on
plot(dmf1(:,114),'o')
plot(dmf2(:,114),'s')
plot(dmf3(:,114),'d')
plot(dmf4(:,114),'x')
plot(dmf5(:,114),'+')
hold off
xlim([0 31])
ylim([30 100])
grid on
ylabel('percent')
xlabel('30 days after the 500th COVID-19 case')
title('USA')
saveas(gcf,'fig3','epsc')

figure(4)
subplot(2,1,1)
plot(dbm(:,100))
hold on
plot(dtv1(:,100),'o')
plot(dtv2(:,100),'s')
plot(dtv3(:,100),'d')
plot(dtv4(:,100),'x')
hold off
xlim([0 31])
ylim([30 100])
grid on
ylabel('percent')
xlabel('30 days after the 500th COVID-19 case')
title('South Korea')
legend('\phi^C=\phi^R=\phi^D=1 (benchmark)','different initial values, equal rate of decrease','equal initial value, different rates of decrease','different initial values, different rates of decrease','different initial values, faster decrease','FontSize',8,'Location','SouthEast')
subplot(2,1,2)
plot(dbm(:,114))
hold on
plot(dtv1(:,114),'o')
plot(dtv2(:,114),'s')
plot(dtv3(:,114),'d')
plot(dtv4(:,114),'x')
hold off
xlim([0 31])
ylim([30 100])
grid on
ylabel('percent')
xlabel('30 days after the 500th COVID-19 case')
title('USA')
saveas(gcf,'fig4','epsc')

%% Mean Squared Deviation (MSD) from the benchmark

N = size(dbm,2);
MSD = NaN(N,9);

for i=1:N
    MSD(i,1) = (1/120)*sum((dbm(:,i)-dmf1(:,i)).*(dbm(:,i)-dmf1(:,i)));
    MSD(i,2) = (1/120)*sum((dbm(:,i)-dmf2(:,i)).*(dbm(:,i)-dmf2(:,i)));
    MSD(i,3) = (1/120)*sum((dbm(:,i)-dmf3(:,i)).*(dbm(:,i)-dmf3(:,i)));
    MSD(i,4) = (1/120)*sum((dbm(:,i)-dmf4(:,i)).*(dbm(:,i)-dmf4(:,i)));
    MSD(i,5) = (1/120)*sum((dbm(:,i)-dmf5(:,i)).*(dbm(:,i)-dmf5(:,i)));
    MSD(i,6) = (1/120)*sum((dbm(:,i)-dtv1(:,i)).*(dbm(:,i)-dtv1(:,i)));
    MSD(i,7) = (1/120)*sum((dbm(:,i)-dtv2(:,i)).*(dbm(:,i)-dtv2(:,i)));
    MSD(i,8) = (1/120)*sum((dbm(:,i)-dtv3(:,i)).*(dbm(:,i)-dtv3(:,i)));
    MSD(i,9) = (1/120)*sum((dbm(:,i)-dtv4(:,i)).*(dbm(:,i)-dtv4(:,i)));
end

% Cleaning
% clc
% clear
% close all

%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%