%% Housekeeping
clc; close all; clear all;

%% File loading
vemu_log_file = '../results/vemulog/app1_kp_test_04_25_13.txt';
output_log_file = '../results/app1_kp_test_04_25_13.txt';

vemu_data = csvread(vemu_log_file);
output_data = csvread(output_log_file);

%% Plot convergence from output log
plot(output_data(:,1)./10,'r','LineWidth',2);
hold on;
plot(1:52, zeros(1,52), '.-k','LineWidth',2);
xlabel('Weeks','FontSize',12);
ylabel('% Error','FontSize',12);
ylim([-10 10]);
xlim([1 52]);
grid on;
saveplot('~/Desktop/powererror0');

%% Plot DC 
plot(output_data(:,2)./10000,'r','LineWidth',2);
hold on;
xlabel('Weeks','FontSize',12);
ylabel('DC','FontSize',12);
xlim([1 52]);
grid on;
saveplot('~/Desktop/dc');