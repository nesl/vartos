%% Housekeeping
clc; close all;

%% Plot sigmoids
t = 0:0.05:100;
cvals = [1 2 3 4];
colors = hsv(length(cvals));
epsilon = 0.99;

cfigure(14,8);
hold on;

%
p = 1;
dc_min = 0.2;
dc_max = 0.7;
c = -log( (2/(epsilon+1)) - 1)/(dc_max-dc_min);

y = p*(2./(1 + exp(-c*(t-dc_min))) - 1);
plot(t,y,'s-r','LineWidth',2);

%
p = 2;
dc_min = 0.1;
dc_max = 0.3;
c = -log( (2/(epsilon+1)) - 1)/(dc_max-dc_min);

y = p*(2./(1 + exp(-c*(t-dc_min))) - 1);
plot(t,y,'^-b','LineWidth',2);

%
p = 1.5;
dc_min = 0;
dc_max = 0.5;
c = -log( (2/(epsilon+1)) - 1)/(dc_max-dc_min);

y = p*(2./(1 + exp(-c*(t-dc_min))) - 1);
plot(t,y,'o-m','LineWidth',2);

xlabel('Duty Cycle','FontSize',12);
ylabel('Utility','FontSize',12);
xlim([0 1]);
ylim([0 2.5]);
grid on;
h_leg = legend('Task 1: 1[0.2, 0.7]','Task 2: 2[0.1,0.3]', 'Task 3: 1.5[0, 0.5]', ...
    'Location','NorthWest');
saveplot('../tecs/figures/utilityfunctions');












