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

% marginal utility queue
muQueue = [];  %%%%%%%% i stopped here--find the 2 m.u. for each task,
% put them in a queue, and execute each one in the queue until dc is done


while(dc_used < dc_max)
    % set up anchor
    dc_anchor = dc_events(dc_idx);
    
    
    % find the marginal utility
    for i = 1:length(sorted_apps)
        dmin = sorted_apps(i).dmin;
        dgood = sorted_apps(i).dgood;
        dbest = sorted_apps(i).dbest;
        
        % find the slope
        slope = 0;
        if dc_anchor < dmin
            slope = 0;
        elseif dc_anchor < dgood
            slope = 0.9/(dgood-dmin);
        elseif dc_anchor < dbest
            slope = 0.1/(dbest-dgood);
        end
        
        % marginal utility = slope, increase in order of priority < d_max
        d
        
    end
end



