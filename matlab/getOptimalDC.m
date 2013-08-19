function [app1dc, app1util, app2dc, app2util, totalutil, maxutil] = getOptimalDC(dc_total)

%% Define Applications
global Apps;
epsilon = 0.99;

App1.priority = 1;
App1.dmin = 0.02;
App1.dmax = 0.1;
App1.c = -log( (2/(epsilon+1)) - 1)/(App1.dmax-App1.dmin);
App1.dc = 0;

App2.priority = 1;
App2.dmin = 0.05;
App2.dmax = 0.2;
App2.c = -log( (2/(epsilon+1)) - 1)/(App2.dmax-App2.dmin);
App2.dc = 0;


Apps = [App1 App2];

%% Plot Utilities
t = 0:0.01:1;
util1 = App1.priority*(2./(1 + exp(-App1.c*(t-App1.dmin))) - 1);
util2 = App2.priority*(2./(1 + exp(-App2.c*(t-App2.dmin))) - 1);

%{
cfigure(18,12);
plot(t,util1,'b','LineWidth',3);
hold on;
plot(t,util2,'r','LineWidth',3);
xlabel('Duty Cycle','FontSize',13);
ylabel('Utility','FontSize',13);
ylim([0 3]);
grid on;
%}

%% Optimization from algorithm
delta = 0.0001;
dc_remaining = dc_total;

% try to assign minimum d.c.
if dc_remaining > App1.dmin
    dc_remaining = dc_remaining - App1.dmin;
    Apps(1).dc = App1.dmin;
end

if dc_remaining > App2.dmin
    dc_remaining = dc_remaining - App2.dmin;
    Apps(2).dc = App2.dmin;
end


while(dc_remaining > 0)
    App1 = Apps(1);
    App2 = Apps(2);
    
    % find max m.u.
    util1_s = App1.priority*(2/(1 + exp(-App1.c*(App1.dc-App1.dmin))) - 1);
    util2_s = App2.priority*(2/(1 + exp(-App2.c*(App2.dc-App2.dmin))) - 1);
    
    util1_f = App1.priority*(2/(1 + exp(-App1.c*(App1.dc+delta-App1.dmin))) - 1);
    util2_f = App2.priority*(2/(1 + exp(-App2.c*(App2.dc+delta-App2.dmin))) - 1);
    
    mus = [(util1_f-util1_s)/delta (util2_f-util2_s)/delta];
    
    maxMU = find(mus == max(mus));
    dc_requested = length(maxMU)*delta;
    if dc_requested > dc_remaining
        dc_requested = dc_remaining;
    end
    
    for i=1:length(maxMU)
        thisApp = maxMU(i);
        Apps(thisApp).dc = Apps(thisApp).dc + dc_requested/length(maxMU);
        dc_remaining = dc_remaining - dc_requested/length(maxMU);
    end
    
    
end

% update total_util


% overlay the plots
App1 = Apps(1);
App2 = Apps(2);
app1util = max(App1.priority*(2/(1 + exp(-App1.c*(App1.dc-App1.dmin))) - 1), 0);
app2util = max(App2.priority*(2/(1 + exp(-App2.c*(App2.dc-App2.dmin))) - 1), 0);
totalutil = app1util + app2util;
app1dc = App1.dc;
app2dc = App2.dc;
maxutil = App1.priority + App2.priority;







