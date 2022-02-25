%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%                          MIDIS                        %%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%          By M. Aykut Attar & Ay�a Tekin-Koru          %%%%%%%%%%
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

%% Load the source data:

[Cd, text, alldata] = xlsread('Cd.xlsx'); %#ok<*ASGLU>
[Rd, text, alldata] = xlsread('Rd.xlsx');
[Dd, text, alldata] = xlsread('Dd.xlsx');
[Gd, text, alldata] = xlsread('Google.xlsx');
Pop = xlsread('Pop.xlsx');

clear alldata

%% Organize the source data:

name = text(2:end,1);
date = text(1,2:end);

clear text

Cd = Cd';
Rd = Rd';
Dd = Dd';
Id = Cd - Rd - Dd;
date = date';
Gd = Gd/100;
Gd = Gd';

T = size(Cd,1); % The Number of Days in the Full Sample 
N = size(Cd,2); % The Number of Countries in the Full Sample 

%% Discard the days for which Cd < 500: 

Id500 = NaN(T,N);
Rd500 = NaN(T,N);
Dd500 = NaN(T,N);
Gd500 = NaN(T,N);

t500 = NaN(N,1);

for i=1:N
    for t=1:T
        if (Cd(t,i)<500) && (Cd(t+1,i)>=500)
            t500(i,1) = t+1;
        end
    end
end

for i=1:N
    date500(i,1) = date(t500(i,1));
end

% The following loop creates a rectangular array of data such that the 
% first observation for any country is the observation for the day on 
% which the number of confirmed cases (Cd) exceeds 500. 
for i=1:N 
    Id500(1:T-t500(i,1)+1,i) = Id(t500(i,1):T,i);
    Rd500(1:T-t500(i,1)+1,i) = Rd(t500(i,1):T,i);
    Dd500(1:T-t500(i,1)+1,i) = Dd(t500(i,1):T,i);
    Gd500(1:T-t500(i,1)+1,i) = Gd(t500(i,1):T,i);
end

%% Normalize the epidemiological data with population levels:

for i=1:N
    Id500(:,i) = Id500(:,i)/Pop(i);
    Rd500(:,i) = Rd500(:,i)/Pop(i);
    Dd500(:,i) = Dd500(:,i)/Pop(i);
end

%% Define the X = R + D compartment:

Xd500 = Rd500 + Dd500;

%% Smooth the data:

Id500s1 = smoothdata(Id500,'gaussian',25);
Xd500s1 = smoothdata(Xd500,'gaussian',25);
Dd500s1 = smoothdata(Dd500,'gaussian',25);
Gd500s1 = smoothdata(Gd500,'gaussian',25);

%% Set the negative Google distancing values to zero:

for i=1:N
    for t=1:T-2
        if Gd500s1(t,i) < 0
            Gd500s1(t,i) = 0;
        end
    end
end

%% Set the parameter values:

alfab = 1/7;   % Average incubation period = 7 days   (He et al., 2020)   
betab = 0.111; % Estimated pure prob. of transmission (He et al., 2020)

alfal = 1/9;     
betal = 0.111-0.0015*2;   

alfah = 1/5;     
betah = 0.111+0.0015*2;

%% Identify \gamma_t via \gamma_t = (X_{t+1}-X_{t})/I_t:

gama = NaN(T,N);

for i=1:N
    for t=1:T-1
        gama(t,i) = (Xd500s1(t+1,i)-Xd500s1(t,i))/Id500s1(t,i);
        if gama(t,i) < 0
            gama(t,i) = 0;
        end
    end
end

%% Identify G_{I,t}, e_{t} and S_{t}:

GrId = NaN(T,N); % Gross growth rate of the share of infected population
eb   = NaN(T,N); % Exposed-to-Infected ratio
Sb   = NaN(T,N); % The share of susceptible population

for i=1:N
    for t=1:T-1
        GrId(t,i) = Id500s1(t+1,i)/Id500s1(t,i);
        eb(t,i) = (GrId(t,i)-(1-gama(t,i)))/alfab;
        e1(t,i) = (GrId(t,i)-(1-gama(t,i)))/alfal;
        e2(t,i) = (GrId(t,i)-(1-gama(t,i)))/alfah;
        Sb(t,i) = 1-Xd500s1(t,i)-Id500s1(t,i)*(1+eb(t,i));
        S1(t,i) = 1-Xd500s1(t,i)-Id500s1(t,i)*(1+e1(t,i));
        S2(t,i) = 1-Xd500s1(t,i)-Id500s1(t,i)*(1+e2(t,i));
    end
end

%% Identify the exposure variable: zeta*(1-d_t)^2

epsib = NaN(T,N);
epsi1 = NaN(T,N);
epsi2 = NaN(T,N);
epsi3 = NaN(T,N);
epsi4 = NaN(T,N);

for i=1:N
    for t=1:T-2
        epsib(t,i) = (eb(t+1,i)*(1-gama(t,i)+alfab*eb(t,i))-(1-alfab)*eb(t,i))/(betab*Sb(t,i));
        epsi1(t,i) = (e1(t+1,i)*(1-gama(t,i)+alfal*eb(t,i))-(1-alfal)*e1(t,i))/(betal*S1(t,i));
        epsi2(t,i) = (e2(t+1,i)*(1-gama(t,i)+alfah*eb(t,i))-(1-alfah)*e2(t,i))/(betal*S2(t,i));
        epsi3(t,i) = (e1(t+1,i)*(1-gama(t,i)+alfal*eb(t,i))-(1-alfal)*e1(t,i))/(betah*S1(t,i));
        epsi4(t,i) = (e2(t+1,i)*(1-gama(t,i)+alfah*eb(t,i))-(1-alfah)*e2(t,i))/(betah*S2(t,i));
        if epsib(t,i) < 0
            epsib(t,i) = 0;
        end
        if epsi1(t,i) < 0
            epsi1(t,i) = 0;
        end
        if epsi2(t,i) < 0
            epsi2(t,i) = 0;
        end
        if epsi3(t,i) < 0
            epsi3(t,i) = 0;
        end
        if epsi4(t,i) < 0
            epsi4(t,i) = 0;
        end
    end
end

epstb = epsib(1:30,:);
epst1 = epsi1(1:30,:);
epst2 = epsi2(1:30,:);
epst3 = epsi3(1:30,:);
epst4 = epsi4(1:30,:);

%% Identify latent social distancing: d_t

distb = NaN(30,N);
dist1 = NaN(30,N);
dist2 = NaN(30,N);
dist3 = NaN(30,N);
dist4 = NaN(30,N);
zetab = NaN(N,1);
zeta1 = NaN(N,1);
zeta2 = NaN(N,1);
zeta3 = NaN(N,1);
zeta4 = NaN(N,1);

tau = 1;
% Calibrate \zeta^i using Google distancing at t=tau
for i=1:N
    zetab(i,1) = epstb(tau,i)/((1-Gd500s1(tau,i))^2);
    zeta1(i,1) = epst1(tau,i)/((1-Gd500s1(tau,i))^2);
    zeta2(i,1) = epst2(tau,i)/((1-Gd500s1(tau,i))^2);
    zeta3(i,1) = epst3(tau,i)/((1-Gd500s1(tau,i))^2);
    zeta4(i,1) = epst4(tau,i)/((1-Gd500s1(tau,i))^2);
end

for i=1:N
    for t=1:30
        distb(t,i) = 1 - ((1/zetab(i,1))*epstb(t,i))^(1/2);
        dist1(t,i) = 1 - ((1/zeta1(i,1))*epst1(t,i))^(1/2);
        dist2(t,i) = 1 - ((1/zeta2(i,1))*epst2(t,i))^(1/2);
        dist3(t,i) = 1 - ((1/zeta3(i,1))*epst3(t,i))^(1/2);
        dist4(t,i) = 1 - ((1/zeta4(i,1))*epst4(t,i))^(1/2);
    end
end

%% Indexing:

dmaxb  = max(max(distb));
dminb  = min(min(distb));
auxxb  = distb-dminb;
auxmb  = max(max(auxxb));
Indexb = auxxb/auxmb;
Indexb = 100*Indexb;

dmax1  = max(max(dist1));
dmin1  = min(min(dist1));
auxx1  = dist1-dmin1;
auxm1  = max(max(auxx1));
Index1 = auxx1/auxm1;
Index1 = 100*Index1;

dmax2  = max(max(dist2));
dmin2  = min(min(dist2));
auxx2  = dist2-dmin2;
auxm2  = max(max(auxx2));
Index2 = auxx2/auxm2;
Index2 = 100*Index2;

dmax3  = max(max(dist3));
dmin3  = min(min(dist3));
auxx3  = dist3-dmin3;
auxm3  = max(max(auxx3));
Index3 = auxx3/auxm3;
Index3 = 100*Index3;

dmax4  = max(max(dist4));
dmin4  = min(min(dist4));
auxx4  = dist4-dmin4;
auxm4  = max(max(auxx4));
Index4 = auxx4/auxm4;
Index4 = 100*Index4;

%% Figure A.1

subplot(2,1,1)
plot(Indexb(:,100))
hold on
plot(Index1(:,100),'o')
plot(Index2(:,100),'s')
plot(Index3(:,100),'d')
plot(Index4(:,100),'x')
hold off
xlim([0 31])
ylim([40 100])
grid on
title('South Korea')
ylabel('percent')
legend('benchmark','low \alpha, low \beta','high \alpha, low \beta','low \alpha, high \beta','high \alpha, high \beta','FontSize',8,'Location','SouthEast')
subplot(2,1,2)
plot(Indexb(:,114))
hold on
plot(Index1(:,114),'o')
plot(Index2(:,114),'s')
plot(Index3(:,114),'d')
plot(Index4(:,114),'x')
hold off
xlim([0 31])
ylim([40 100])
grid on
title('USA')
ylabel('percent')
saveas(gcf,'figa1','epsc')

%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%