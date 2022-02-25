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

%% Introduce the multiplication factors:

for i=1:N
    Cd500(:,i) = Id500(:,i)+Rd500(:,i)+Dd500(:,i);
end

% mfc = 1; mfr = 1; mfd = 1;         % benchmark
% mfc = 3; mfr = 3; mfd = 3;         % mf1
% mfc = 7; mfr = 7; mfd = 7;         % mf2
% mfc = 7; mfr = 3; mfd = 3;         % mf3
% mfc = 2.9; mfr = 2.2; mfd = 2.2;   % mf4
mfc = 2.9; mfr = 1.6; mfd = 2.2;   % mf5

for i=1:N
    Cd500(:,i) = mfc*Cd500(:,i);
    Dd500(:,i) = mfd*Dd500(:,i);
    Rd500(:,i) = mfr*Rd500(:,i);
end

for i=1:N
    Id500(:,i) = Cd500(:,i) - Rd500(:,i) - Dd500(:,i);
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
        Sb(t,i) = 1-Xd500s1(t,i)-Id500s1(t,i)*(1+eb(t,i));
    end
end

%% Identify the exposure variable: zeta*(1-d_t)^2

epsib = NaN(T,N);
 
for i=1:N
    for t=1:T-2
        epsib(t,i) = (eb(t+1,i)*(1-gama(t,i)+alfab*eb(t,i))-(1-alfab)*eb(t,i))/(betab*Sb(t,i));
        if epsib(t,i) < 0
            epsib(t,i) = 0;
        end
    end
end

epstb = epsib(1:30,:);

%% Identify latent social distancing: d_t

distb = NaN(30,N);
zeta  = NaN(N,1);

tau = 1;
% Calibrate \zeta^i using Google distancing at t=tau
for i=1:N
    zeta(i,1) = epstb(tau,i)/((1-Gd500s1(tau,i))^2);
end

for i=1:N
    for t=1:30
        distb(t,i) = 1 - ((1/zeta(i,1))*epstb(t,i))^(1/2);
    end
end

%% Indexing:

dmax = max(max(distb));
dmin = min(min(distb));

auxx = distb-dmin;
auxm = max(max(auxx));

Index = auxx/auxm;

%% Organize and save the data:

% Index_bm = Index;
% Index_mf1 = Index;
% Index_mf2 = Index;
% Index_mf3 = Index;
% Index_mf4 = Index;
Index_mf5 = Index;

% save('midis_bm.mat','Index_bm')
% save('midis_mf1.mat','Index_mf1')
% save('midis_mf2.mat','Index_mf2')
% save('midis_mf3.mat','Index_mf3')
% save('midis_mf4.mat','Index_mf4')
save('midis_mf5.mat','Index_mf5')

%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%