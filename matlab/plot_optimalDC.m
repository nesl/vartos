%%
clc; clear all; close all;

%%
dc_array = 0:0.005:0.3;

dc1_array = [];
dc2_array = [];
u1_array = [];
u2_array = [];
tu_array = [];
mu_array = [];

for dc_total = dc_array
    
    [dc1, u1, dc2, u2, tu, mu] = getOptimalDC(dc_total);
    dc1_array = [dc1_array dc1];
    dc2_array = [dc2_array dc2];
    u1_array = [u1_array u1];
    u2_array = [u2_array u2];
    tu_array = [tu_array tu];
    mu_array = [mu_array mu];
    
    %pause();
    
    
end

%%
cfigure(14,8);

plot(dc_array, mu_array, '-k','LineWidth',1);
hold on;
plot(dc_array, tu_array,'--k','LineWidth',2);
plot(dc_array, u1_array,'ob','LineWidth',2);
plot(dc_array, u2_array,'sr','LineWidth',2);

legend('Maximum Utility','Total Utility','Task(1) Utility','Task(2) Utility',...
    'Location','NorthWest');

text(0.01,0.2,'(a)','FontSize',12);
text(0.06,1,'(b)','FontSize',12);
text(0.06,0.3,'(c)','FontSize',12);
text(0.085,0.8,'(d)','FontSize',12);

ylim([0 2.5]);
xlim([0 0.3]);
grid on;

xlabel('Available System DC (d^*)','FontSize',12);
ylabel('Utility','FontSize',12);

saveplot('../tecs/figures/optimalDCexample');





