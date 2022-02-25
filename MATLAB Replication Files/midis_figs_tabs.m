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
%%%%%%%%%%                     July 20, 2021                     %%%%%%%%%%
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

%% Load the MIDIS data for 120 countries:

load('midis.mat')

D = double(exportmidis(:,3:end));
D = D';
D = 100*D;

N = size(D,2);

%% Tables

Initial  = D(1,:)';
Average  = (mean(D))';
Minimum  = (min(D))';
AutoCorr = NaN(N,1);
for i=1:N
 [acf,lags,bounds] = autocorr(D(:,i));
 AutoCorr(i,1) = acf(2);
 clear acf lags bounds
end

Country = char(exportmidis(:,1));
Date500 = char(exportmidis(:,2));

T = table(Country,Date500,Initial,Average,Minimum,AutoCorr);

top10 = [43;76;62;100;3;87;49;117;89;69];
bot10 = [40;78;64;105;57;19;108;96;52;120];

Tab1a = [T(43,:);T(76,:);T(62,:);T(100,:);T(3,:);T(87,:);T(49,:);T(117,:);T(89,:);T(69,:)];
Tab1b = [T(40,:);T(78,:);T(64,:);T(105,:);T(57,:);T(19,:);T(108,:);T(96,:);T(52,:);T(120,:)];

%% Figure

figure(2)
plot(D,'Color',[0.7 0.7 0.7])
hold on
plot(D(:,118),'m^-','LineWidth',1)     % Yemen
plot(D(:,29),'mo-','LineWidth',1)      % Cote d'Ivoire 
text(31.5,D(30,118),'YEM','Color','m','FontSize',8,'FontWeight','bold')
text(31.5,D(30,29)-1,'CIV','Color','m','FontSize',8,'FontWeight','bold')
plot(D(:,52),'bv-','LineWidth',1)      % Japan
plot(D(:,103),'bs-','LineWidth',1)     % Sweden 
text(31.5,D(30,52),'JPN','Color','b','FontSize',8,'FontWeight','bold')
text(31.5,D(30,103)+1,'SWE','Color','b','FontSize',8,'FontWeight','bold')
plot(D(:,100),'r>-','LineWidth',1)     % South Korea
plot(D(:,76),'rd-','LineWidth',1)      % New Zealand 
text(31.5,D(30,100),'KOR','Color','r','FontSize',8,'FontWeight','bold')
text(31.5,D(30,76),'NZL','Color','r','FontSize',8,'FontWeight','bold')
plot(D(:,50),'kx-','LineWidth',1)      % Italy
plot(D(:,114),'k*-','LineWidth',1)     % United States 
text(31.5,D(30,50),'ITA','Color','k','FontSize',8,'FontWeight','bold')
text(31.5,D(30,114),'USA','Color','k','FontSize',8,'FontWeight','bold')
hold off
xlim([0 31])
ylabel('percent')
grid on
saveas(gcf,'fig2','epsc')

%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
