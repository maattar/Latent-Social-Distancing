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
% which the number of confirmed cases (Cd) exceeds 500. 
for i=1:N 
    Id500(1:T-t500(i,1)+1,i) = Id(t500(i,1):T,i);
    Rd500(1:T-t500(i,1)+1,i) = Rd(t500(i,1):T,i);
    Dd500(1:T-t500(i,1)+1,i) = Dd(t500(i,1):T,i);
    Gd500(1:T-t500(i,1)+1,i) = Gd(t500(i,1):T,i);
end

outI = reshape(Id500(1:30,:),[],1);
outR = reshape(Rd500(1:30,:),[],1);
outD = reshape(Dd500(1:30,:),[],1);
outC = outI+outR+outD;

out  = [outC outR outD outI];

xlswrite('CRDI.xls',out);

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

exportmidis = [string(name) string(date500) Index'];

save('midis.mat','exportmidis')

midispanel = NaN(30*120,1);
for i=1:N
    midispanel(30*i-29:30*i,1) = Index(:,i);
end

dAUS = Index([1	2 3	6	7	8	9	10	13	14	15	16	17	20	21	22	23	24	27	28	29	30],3);
dAUT = Index([3	4	5	6	7	10	11	12	13	14	17	18	19	20	21	24	25	26	27	28],4);
dBEL = Index([1	4	5	6	7	8	11	12	13	14	15	18	19	20	21	22	25	26	27	28	29],10);
dBGR = Index([2	3	4	5	6	9	10	11	12	13	16	17	18	19	20	23	24	25	26	27	30],16);
dHRV = Index([1	4	5	6	7	8	11	12	13	14	15	18	19	20	21	22	25	26	27	28	29],25);
dCZE = Index([1	2	5	6	7	8	9	12	13	14	15	16	19	20	21	22	23	26	27	28	29	30],26);
dDNK = Index([1	2	5	6	7	8	9	12	13	14	15	16	19	20	21	22	23	26	27	28	29	30],27);
dEST = Index([1	2	5	6	7	8	9	12	13	14	15	16	19	20	21	22	23	26	27	28	29	30],32);
dFIN = Index([3	4	5	6	7	10	11	12	13	14	17	18	19	20	21	24	25	26	27	28],34);
dFRA = Index([1	4	5	6	7	8	11	12	13	14	15	18	19	20	21	22	25	26	27	28	29],35);
dDEU = Index([1	4	5	6	7	8	11	12	13	14	15	18	19	20	21	22	25	26	27	28	29],37);
dGRC = Index([3	4	5	6	7	10	11	12	13	14	17	18	19	20	21	24	25	26	27	28],39);
dHUN = Index([1	2	3	6	7	8	9	10	13	14	15	16	17	20	21	22	23	24	27	28	29	30],44);
dIND = Index([1	2	3	4	7	8	9	10	11	14	15	16	17	18	21	22	23	24	25	28	29	30],45);
dIRL = Index([1	2	5	6	7	8	9	12	13	14	15	16	19	20	21	22	23	26	27	28	29	30],48);
dITA = Index([5	6	7	8	9	12	13	14	15	16	19	20	21	22	23	26	27	28	29	30],50);
dJPN = Index([1	2	3	4	5	8	9	10	11	12	15	16	17	18	19	22	23	24	25	26	29	30],52);
dLTU = Index([1	2	3	6	7	8	9	10	13	14	15	16	17	20	21	22	23	24	27	28	29	30],61);
dNLD = Index([1	4	5	6	7	8	11	12	13	14	15	18	19	20	21	22	25	26	27	28	29],75);
dNOR = Index([1	2	3	6	7	8	9	10	13	14	15	16	17	20	21	22	23	24	27	28	29	30],81);
dPOL = Index([3	4	5	6	7	10	11	12	13	14	17	18	19	20	21	24	25	26	27	28],88);
dPRT = Index([1	2	5	6	7	8	9	12	13	14	15	16	19	20	21	22	23	26	27	28	29	30],89);
dROU = Index([1	2	3	4	5	8	9	10	11	12	15	16	17	18	19	22	23	24	25	26	29	30],91);
dSVK = Index([1	2	3	4	5	8	9	10	11	12	15	16	17	18	19	22	23	24	25	26	29	30],97);
dSVN = Index([1	2	3	6	7	8	9	10	13	14	15	16	17	20	21	22	23	24	27	28	29	30],98);
dESP = Index([2	3	4	5	6	9	10	11	12	13	16	17	18	19	20	23	24	25	26	27	30],101);
dSWE = Index([1	2	3	6	7	8	9	10	13	14	15	16	17	20	21	22	23	24	27	28	29	30],103);
dCHE = Index([1	2	3	6	7	8	9	10	13	14	15	16	17	20	21	22	23	24	27	28	29	30],104);
dUKR = Index([1	2	3	4	5	8	9	10	11	12	15	16	17	18	19	22	23	24	25	26	29	30],111);
dUSA = Index([2	3	4	5	6	9	10	11	12	13	16	17	18	19	20	23	24	25	26	27	30],114);

sample30  = [dAUS;dAUT;dBEL;dBGR;dHRV;dCZE;dDNK;dEST;dFIN;dFRA;dDEU;dGRC;dHUN;dIND;dIRL;dITA;dJPN;dLTU;dNLD;dNOR;dPOL;dPRT;dROU;dSVK;dSVN;dESP;dSWE;dCHE;dUKR;dUSA];
sample120 = midispanel;

clear dAUS dAUT dBEL dBGR dHRV dCZE dDNK dEST dFIN dFRA dDEU dGRC dHUN dIND dIRL dITA dJPN dLTU dNLD dNOR dPOL dPRT dROU dSVK dSVN dESP dSWE dCHE dUKR dUSA

%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%