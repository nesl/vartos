%% Housekeeping
clc; close all;

%% Plot sigmoids
t = 0:0.01:100;
cvals = [1 2 3 4];
colors = hsv(length(cvals));

cfigure(18,12);
hold on;

% gompertz y(t) = ae^(be^(ct))

for c = 1:length(cvals)
    thisC = cvals(c);
    y = c*(2./(1 + exp(-10*t)) - 1);
    %y = 1*exp(-4*exp(-thisC.*t));
    
    
    plot(t,y,'Color',colors(c,:),'LineWidth',2);

end
xlabel('d_a','FontSize',12);
ylabel('p_a\cdot u_a(d_a)','FontSize',12);
xlim([0 1]);
ylim([0 5]);
grid on;
h_leg = legend('p = 1','p = 2', 'p = 3','p = 4',...
    'Location','NorthWest');
title('Utility with Priority','FontSize',12);
saveplot('../figs/sigmoidFcns3');