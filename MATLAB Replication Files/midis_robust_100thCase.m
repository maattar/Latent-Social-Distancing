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

%% Discard the days for which Cd < 100: 

Id100 = NaN(T,N);
Rd100 = NaN(T,N);
Dd100 = NaN(T,N);
Gd100 = NaN(T,N);

t100 = NaN(N,1);

for i=1:N
    for t=1:T
        if (Cd(t,i)<100) && (Cd(t+1,i)>=100)
            t100(i,1) = t+1;
        end
    end
end

for i=1:N
    date100(i,1) = date(t100(i,1));
end

t1 = NaN(N,1);

for i=1:N
    for t=1:T
        if (Cd(t,i)==0) && (Cd(t+1,i)>=1)
            t1(i,1) = t+1;
        end
    end
end

for i=1:N
    if (Cd(1,i)>=1)
        t1(i,1) = 1;
    end
end

for i=1:N
    date1(i,1) = date(t1(i,1));
end

date1panel = NaN(30*120,1);
for i=1:N
    date1panel(30*i-29:30*i,1) = t1(i,1)*ones(30,1);
end

% The following loop creates a rectangular array of data such that the 
% first observation for any country is the observation for the day on 
% which the number of confirmed cases (Cd) exceeds 100. 
for i=1:N 
    Id100(1:T-t100(i,1)+1,i) = Id(t100(i,1):T,i);
    Rd100(1:T-t100(i,1)+1,i) = Rd(t100(i,1):T,i);
    Dd100(1:T-t100(i,1)+1,i) = Dd(t100(i,1):T,i);
    Gd100(1:T-t100(i,1)+1,i) = Gd(t100(i,1):T,i);
end

outI = reshape(Id100(1:30,:),[],1);
outR = reshape(Rd100(1:30,:),[],1);
outD = reshape(Dd100(1:30,:),[],1);
outC = outI+outR+outD;

out  = [outC outR outD outI];

xlswrite('CRDI.xls',out);

%% Normalize the epidemiological data with population levels:

for i=1:N
    Id100(:,i) = Id100(:,i)/Pop(i);
    Rd100(:,i) = Rd100(:,i)/Pop(i);
    Dd100(:,i) = Dd100(:,i)/Pop(i);
end

%% Define the X = R + D compartment:

Xd100 = Rd100 + Dd100;

%% Smooth the data:

Id100s1 = smoothdata(Id100,'gaussian',25);
Xd100s1 = smoothdata(Xd100,'gaussian',25);
Dd100s1 = smoothdata(Dd100,'gaussian',25);
Gd100s1 = smoothdata(Gd100,'gaussian',25);

%% Set the negative Google distancing values to zero:

for i=1:N
    for t=1:T-2
        if Gd100s1(t,i) < 0
            Gd100s1(t,i) = 0;
        end
    end
end

%% Set the parameter value:

alfab = 1/7;   % Average incubation period = 7 days   (He et al., 2020)   

%% Identify \gamma_t via \gamma_t = (X_{t+1}-X_{t})/I_t:

gama = NaN(T,N);

for i=1:N
    for t=1:T-1
        gama(t,i) = (Xd100s1(t+1,i)-Xd100s1(t,i))/Id100s1(t,i);
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
        GrId(t,i) = Id100s1(t+1,i)/Id100s1(t,i);
        eb(t,i) = (GrId(t,i)-(1-gama(t,i)))/alfab;
        Sb(t,i) = 1-Xd100s1(t,i)-Id100s1(t,i)*(1+eb(t,i));
    end
end

%% Identify the exposure variable: zeta*(1-d_t)^2

epsib = NaN(T,N);
 
for i=1:N
    for t=1:T-2
        epsib(t,i) = (eb(t+1,i)*(1-gama(t,i)+alfab*eb(t,i))-(1-alfab)*eb(t,i))/(Sb(t,i));
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
    zeta(i,1) = epstb(tau,i)/((1-Gd100s1(tau,i))^2);
end

zeta(11,1) = epstb(14,11)/((1-Gd100s1(14,11))^2);

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

Index100 = auxx/auxm;

%% Organize and save the data:

exportmidis100 = [string(name) string(date100) Index100'];

save('midis_robust_100thCase.mat','exportmidis100')

%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%