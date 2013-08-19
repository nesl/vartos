%% Housekeeping
clc; clear all; close all;

%% Load VarEMU data

sleep_variance = 1e3*20; %uW -> nW
active_variance = 1e3*20; %uW -> nW

data = csvread('vemu_power_45nm.csv');
N = length(data(:,1));
T_array = data(:,1);
Ps_array = data(:,2)*1e9+randn(N,1)*sleep_variance; % to nW
Pa_array = data(:,3)*1e9+randn(N,1)*active_variance; % to nW

T_array_nonoise = data(:,1);
Ps_array_nonoise = data(:,2)*1e9;
Pa_array_nonoise = data(:,3)*1e9;

%% Plot sleep and active data
cfigure(40,10);
subplot(141);
scatter(T_array, Ps_array/1e3);
hold on;
grid on;


%% Model sleep power: approximate linearization and least squares
p = polyfit(T_array, log(Ps_array), 1);
Ps_linear = exp(polyval(p,T_array));
plot(T_array, Ps_array_nonoise/1e3, 'k','LineWidth',2);
plot(T_array, Ps_linear/1e3,'--r','LineWidth',2);
xlim([-20 100]);

%% Legend
legend('Data','Noise Removed','Linearized Fit','Location','NorthWest');
xlabel('Temperature (C)','FontSize',12);
ylabel('Power (uW)','FontSize',12);


%% Calculate error
subplot(142);
error = 100*(Ps_array_nonoise-Ps_linear)./Ps_array_nonoise;
plot(T_array,error,'.-k','LineWidth',2);
hold on;
plot([min(T_array) max(T_array)], [0 0], '-k');
ylim([-15 15]);
xlim([-20 100]);

xlabel('Temperature (C)','FontSize',12);
ylabel('Error (%)','FontSize',12);
grid on;

%saveplot('../rtss/figures/powerlearning');





