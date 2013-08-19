%% Housekeeping
clc; close all;

%% Define Applications
global Apps;

App1.priority = 1;
App1.utilOffset = 0;
App1.utilC = 10000;
App1.dmin = 0;
App1.dc = 0;

App2.priority = 1.5;
App2.utilOffset = 0;
App2.utilC = 500;
App2.dmin = 0.2;
App2.dc = 0;

App3.priority = 2;
App3.utilOffset = 0;
App3.utilC = 20;
App3.dmin = 0.3;
App3.dc = 0;

Apps = [App1 App2 App3];

%% Plot Utilities
t = 0:0.01:1;
util1 = App1.priority*log(App1.utilC*t+1)/(log(App1.utilC+1));
util2 = App2.priority*log(App2.utilC*t+1)/(log(App2.utilC+1));
util3 = App3.priority*log(App3.utilC*t+1)/(log(App3.utilC+1));

cfigure(18,12);
plot(t,util1,'m','LineWidth',3);
hold on;
plot(t,util2,'c','LineWidth',3);
plot(t,util3,'g','LineWidth',3);
xlabel('Duty Cycle','FontSize',13);
ylabel('Utility','FontSize',13);
grid off;

%% Optimize duty cycles
%x = maxAlloc_cvx(1,3,@utilFcn,...
%    [App1.dmin; App2.dmin; App3.dmin]);
%uVal1 = App1.priority*log(App1.utilC*x(1)+1)/(log(App1.utilC+1));
%uVal2 = App2.priority*log(App2.utilC*x(2)+1)/(log(App2.utilC+1));
%uVal3 = App3.priority*log(App3.utilC*x(3)+1)/(log(App3.utilC+1));

%h_lp = plot(x(1),uVal1,'or','MarkerSize',20);
%plot(x(2),uVal2,'ob','MarkerSize',20);
%plot(x(3),uVal3,'om','MarkerSize',20);

%saveplot('../figs/optimizeCAndP');

%% Optimization from algorithm
delta = 0.0001;
dc_total = 1;
dc_remaining = dc_total;
dcs = [0 0 0];

while(dc_remaining > 0)
    App1 = Apps(1);
    App2 = Apps(2);
    App3 = Apps(3);
    
    % try to assign minimum d.c.
    
    % find max m.u.
    util1_s = App1.priority*log(App1.utilC*App1.dc+1)/(log(App1.utilC+1));
    util2_s = App2.priority*log(App2.utilC*App2.dc+1)/(log(App2.utilC+1));
    util3_s = App3.priority*log(App3.utilC*App3.dc+1)/(log(App3.utilC+1));
    
    util1_f = App1.priority*log(App1.utilC*(App1.dc+delta)+1)/(log(App1.utilC+1));
    util2_f = App2.priority*log(App2.utilC*(App2.dc+delta)+1)/(log(App2.utilC+1));
    util3_f = App3.priority*log(App3.utilC*(App3.dc+delta)+1)/(log(App3.utilC+1));
    
    mus = [(util1_f-util1_s)/delta (util2_f-util2_s)/delta (util3_f-util3_s)/delta];
    
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

% overlay the plots
App1 = Apps(1);
App2 = Apps(2);
App3 = Apps(3);
uVal1 = App1.priority*log(App1.utilC*Apps(1).dc+1)/(log(App1.utilC+1));
uVal2 = App2.priority*log(App2.utilC*Apps(2).dc+1)/(log(App2.utilC+1));
uVal3 = App3.priority*log(App3.utilC*Apps(3).dc+1)/(log(App3.utilC+1));

h_greedy = plot(App1.dc,uVal1,'^r','MarkerSize',12, 'MarkerFaceColor','r');
plot(App2.dc,uVal2,'^b','MarkerSize',12, 'MarkerFaceColor','b');
plot(App3.dc,uVal3,'^m','MarkerSize',12, 'MarkerFaceColor','m');

%legend([h_lp h_greedy],'CVX Solution', 'Greedy Solution', 'Location', 'NorthWest');

%saveplot('../figs/greedyTest');