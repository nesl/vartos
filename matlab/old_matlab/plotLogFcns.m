%% Housekeeping
clc; close all;

%% Plot sigmoids
t = 0:0.001:100;
cvals = [10 50 500 100000];
colors = hsv(length(cvals));

cfigure(18,12);
hold on;

% gompertz y(t) = ae^(be^(ct))

for c = 1:length(cvals)
    thisC = cvals(c);
    y = log(thisC*t+1)./log(thisC+1);
    
    plot(t,y,'Color',colors(c,:),'LineWidth',2);

end
xlabel('d_a','FontSize',12);
ylabel('u_a(d_a)','FontSize',12);
xlim([0 1]);
ylim([0 1.1]);
grid on;
h_leg = legend('c = 10','c = 50', 'c = 500','c = 100000',...
    'Location','SouthEast');
title('Convex Log Utility','FontSize',12);
saveplot('../figs/logFcns');