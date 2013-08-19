%% Housekeeping
clc; close all;

%% Define Applications
global Apps;

App1.priority = 3;
App1.utilOffset = 0;
App1.dmin = 0.35;
App1.dgood = 0.5;
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
App3.dmin = 0.2;
App3.dgood = 0.75;
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

disp('d_min satisfied to best of ability');
fprintf('d_min consumed: %d\n',dc_used);

% marginal utility queue
muQueue = [];
for i = 1:length(Apps)
    dmin = Apps(i).dmin;
    dgood = Apps(i).dgood;
    dbest = Apps(i).dbest;
    priority = Apps(i).priority;
    
    mu1 = priority*(0.9-0.0)/(dgood - dmin);
    mu2 = priority*(1.0-0.9)/(dbest - dgood);
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

disp('marginal utilities calculated');
% sort marginal utility queue (bubble sort)
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
disp('marginal utilities sorted');
for i = 1:length(muQueue)
    disp(muQueue(i).mu);
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
            dc_required = dc_required + (muQueue(i).df-muQueue(i).ds);
        end
    end
    
    
    
    % of those with maximum m.u., request enough duty cycle
    % to bring these to the next duty cycle, or as much as we can
    % first, how much dc can we get?
    dc_avail = min(dc_required,(dc_max-dc_used));
    % now how much can we assign to the tasks that need it?
    dc_per_task = dc_avail / num;
    % increment the duty cycles of each app
    for i = 1:num
        app_id = muQueue(i).idx;
        Apps(app_id).dc = Apps(app_id).dc + dc_per_task;
        dc_used = dc_used + dc_per_task;
        % remove app from queue
        muQueue = muQueue(2:end);
    end
    
    fprintf('    > incrementing %d apps...\n\r',num);
    disp([Apps(1).dc Apps(2).dc Apps(3).dc]);
end

disp('DONE!');
disp('dc vector:');
disp([Apps(1).dc Apps(2).dc Apps(3).dc]);

%% Plot optimized duty cycles
t = 0:0.01:1;
utils = zeros(length(Apps),length(t));

dc_optimal = [Apps(1).dc Apps(2).dc Apps(3).dc];

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

% overlay optimal points
optimal_points = zeros(1,length(Apps));

for a = 1:length(Apps)
    dmin = Apps(a).dmin;
    dgood = Apps(a).dgood;
    dbest = Apps(a).dbest;
    priority = Apps(a).priority;
    
    opt = dc_optimal(a);
    yval = 0;
    
    if opt <= dmin
        yval = 0;
    elseif opt <= dgood
        yval = 0 + (opt-dmin)*0.90*priority/(dgood-dmin);
    elseif opt <= dbest
        yval = 0.9*priority + (opt-dgood)*(1.0-0.90)*priority/(dbest-dgood);
    else
        yval = priority;
    end
    optimal_points(a) = yval;
end

cfigure(18,12);
plot(t,utils(1,:),'r');
hold on;
plot(t,utils(2,:),'b');
plot(t,utils(3,:),'m');
% optimal points
plot(dc_optimal(1),optimal_points(1),'or','MarkerSize',20);
plot(dc_optimal(2),optimal_points(2),'ob','MarkerSize',20);
plot(dc_optimal(3),optimal_points(3),'om','MarkerSize',20);

xlabel('Duty Cycle','FontSize',12);
ylabel('Utility','FontSize',12);
legend('App 1', 'App 2', 'App 3','Location','SouthEast');
xlim([0 1]);
ylim([0 3.5]);
grid on;
saveplot('../figs/utilityEquivOptimal2');