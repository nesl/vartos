
clear all; close all;

global dt
dt = 0.1;

end_time = 240;
times = 0:dt:end_time;

Xsaved = zeros(length(times), 2);
Zsaved = zeros(length(times), 1);
Vsaved = zeros(length(times), 1);

for k=1:length(times);

    [z_noise, z_real, v_real] = GetPos(k);
    [pos vel] = DvKalman(z_noise);
    
    Xsaved(k,:) = [pos vel];
    Zsaved(k) = z_noise;
    Zpsaved(k) = z_real;
    Vsaved(k) = v_real;
end

cfigure(18,10);
hold on;
plot(times, Zsaved(:), 'r.','LineWidth',2)
plot(times, Xsaved(:,1), 'b','LineWidth',2)
plot(times, Zpsaved(:), '--k','LineWidth',2);
xlabel('Time (sec) ','FontSize',12);
ylabel('Position (m)','FontSize',12);
legend('Location','NorthEast','Position sensor','Kalman estimate','True Position'); 
%saveplot('../../../tecs/figures/kalman_example_pos');

cfigure(14,8);
hold on;
plot(times(1:(end-2)), Xsaved(3:end,2), 'b','LineWidth',2)
plot(times, Vsaved(:), '--k','LineWidth',2);
xlabel('Time (sec) ','FontSize',12);
ylabel('Velocity (m/s)','FontSize',12);
legend('Location','NorthEast','Kalman estimate','True Velocity'); 
saveplot('../../../tecs/figures/kalman_example_vel');

%error = Xsaved(5:end,2) - Vsaved(1:(end-4));
%plot(medfilt1(error, 10/dt));
%plot(times,Xsaved(:,2));