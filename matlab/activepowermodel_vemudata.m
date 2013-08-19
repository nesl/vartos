%% Housekeeping
clc; clear all; close all;

%% Load VarEMU data
sleep_variance = 1e3*10; %nW
active_variance = 1e3*10; %nW

data = csvread('vemu_power_45nm.csv');
N = length(data(:,1));
T_array = data(:,1);
Ps_array = data(:,2)*1e9+randn(N,1)*sleep_variance; % to nW
Pa_array = data(:,3)*1e9+randn(N,1)*active_variance; % to nW

T_array_nonoise = data(:,1);
Ps_array_nonoise = data(:,2)*1e9;
Pa_array_nonoise = data(:,3)*1e9;

%% Plot sleep and active data
cfigure(35,15);
subplot(1,2,1);
scatter(T_array, Ps_array/1e3);
hold on;
grid on;

subplot(1,2,2);
scatter(T_array, Pa_array/1e6);
hold on;
grid on;

%% Model sleep power: approximate linearization and least squares
p = polyfit(T_array, log(Ps_array), 1);
subplot(1,2,1);
Ps_linear = exp(polyval(p,T_array));
plot(T_array, Ps_array_nonoise/1e3, 'k','LineWidth',2);
plot(T_array, Ps_linear/1e3,'sr','LineWidth',1);




%% Overlay VaRTOS predictions
subplot(1,2,1);
p_s = [0.019 11.7];
plot(T_array, exp(polyval(p_s,T_array))/1e3,'.-m','LineWidth',2);

subplot(1,2,2);
p_a = [-0.112 751653];
pa_plus_ps = (polyval(p_a,T_array) + exp(polyval(p_s,T_array)))/1e6;
plot(T_array, pa_plus_ps,'.-m','LineWidth',2);


%% Legend
subplot(1,2,1);
legend('Data','Noise Removed','Linearized Fit','VaRTOS Model','Location','NorthWest');
xlabel('Temperature (C)','FontSize',12);
ylabel('Power (uW)','FontSize',12);
title('Sleep Power','FontSize',12);

subplot(1,2,2);
legend('Data','Noise Removed','Linear + Ps','VaRTOS Model','Location','NorthWest');
xlabel('Temperature (C)','FontSize',12);
ylabel('Power (mW)','FontSize',12);
title('Active Power','FontSize',12);
%saveplot('~/Desktop/powerlearning');


