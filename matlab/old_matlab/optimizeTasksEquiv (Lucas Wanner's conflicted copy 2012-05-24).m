%% Housekeeping
clc; close all;

%% Define Applications
global Apps;

App1.priority = 3;
App1.utilOffset = 0;
App1.dmin = 0;
App1.dgood = 0.1;
App1.dbest = 1;
App1.dc = 0;

App2.priority = 2;
App2.utilOffset = 0.1;
App2.dmin = 0;
App2.dgood = 0.2;
App2.dbest = 1;
App2.dc = 0;

App3.priority = 1;
App3.utilOffset = 0;
App3.dmin = 0;
App3.dgood = 0.7;
App3.dbest = 1;
App3.dc = 0;

Apps = [App1 App2 App3];

%% Plot Utilities
t = 0:0.01:1;
utils = zeros(length(Apps),length(t));

for a = 1:length(Apps)
    dmin = Apps(a).dmin;
    dgood = Apps(a).dgood;
    dbest = Apps(a).dbest;
    priority = Apps(a).priority;
    
    % initial condition--last value must be 1
    utils(:,end) = [App1.priority;App2.priority;App3.priority];
    
    for i = (length(t)-1):-1:1
        if t(i) < dgood
            slope = 0.90*priority/(dgood-dmin);
        elseif t(i) < dbest
            slope = (1.0-0.90)*priority/(dbest-dgood);
        else
            slope = 0;
        end
        utils(a,i) = utils(a,i+1)-slope*(t(i+1)-t(i));
    end
end

cfigure(18,12);
plot(t,utils(1,:),'r');
hold on;
plot(t,utils(2,:),'b');
plot(t,utils(3,:),'m');
xlabel('Duty Cycle','FontSize',12);
ylabel('Utility','FontSize',12);
legend('App 1', 'App 2', 'App 3','Location','SouthEast');
xlim([0 1]);
ylim([0 3.5]);
grid on;
%saveplot('../figs/utilityEquiv');

%% Optimize duty cycles
%x = maxAlloc_cvx(1,3,@utilFcnEquiv,...
%    [App1.dmin; App2.dmin; App3.dmin]);

% simple algorithm for determining optimal duty cycles:

% determine maximum system-wide duty cycle
dc_max = 1.0;
dc_used = 0.0;

% in order of priority, try to accomodate dmin
dc_idx = 1;
sorted_apps = [App1 App2 App3]; % by priority
for i = 1:length(sorted_apps)
    if(dc_used + Apps(i).dmin > dc_max)
        continue;
    end
    dc_used = dc_used + Apps(i).dmin;
    Apps(i).dc = Apps(i).dmin;
end

%% marginal utility queue
muQueue = [];
for i = 1:length(Apps)
    mu1 = (0.9-0.0)/(Apps(i).dgood - Apps(i).dmin);
    mu2 = (1.0-0.9)/(Apps(i).dbest - Apps(i).dgood);
    % first m.u. struct
    mu_t_1.mu = mu1;
    mu_t_1.idx = i;
    mu_t_1.ds = dmin;
    mu_t_1.df = dgood;
    % second m.u. struct
    mu_t_2.mu = mu2;
    mu_t_2.idx = i;
    mu_t_2.ds = dgood;
    mu_t_2.df = dbest;
    muQueue = [muQueue mu_t_1 mu_t_2];
end

%% sort marginal utility queue (bubble sort)
swapOccured = 1;
while(swapOccured == 1)
    swapOccured = 0;
    for i = 1:length(muQueue)-1
        if muQueue(i).mu < muQueue(i+1).mu
            muTemp = muQueue(i+1);
            muQueue(i+1) = muQueue(i);
            muQueue(i) = muTemp;
            swapOccured = 1;
        end
    end
end

%% get optimal DCs
mu_idx = 1;
while(dc_used < dc_max)
    % how many in the queue have maximum m.u. ?
    num = 0;
    muMax = muQueue(1).mu;
    dc_required = 0;
    for i = 1:length(muQueue)
        if muQueue(i).mu == muMax
            num = num + 1;
            dc_required = dc_required + muQueue(i).df;
        else
            break;
        end
    end
    
    % of those with maximum m.u., request enough duty cycle
    % to bring these to the next duty cycle, or as much as we can
    
    
end



