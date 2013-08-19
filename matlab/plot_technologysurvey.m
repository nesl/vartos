%% Housekeeping
clc; clear all; close all;

%% Data from ITRS Predictions
cfigure(18,8);
years = 2009:2022;
itrs_sleep_var = [
    190
    230 % 2010
    255
    290 % 2012
    290
    300 % 2014
    325
    380 % 2016
    390
    400 % 2018
    398
    397 % 2020
    430
    605 % 2022
    ];
itrs_total_var = [
    70
    73 % 2010
    76
    79 % 2012
    82
    85 % 2014
    88
    91 % 2016
    94
    97 % 2018
    103
    109 % 2020
    115
    121 % 2022
    ];

plot(years,itrs_sleep_var,'--k','LineWidth',2);
hold on
plot(years, itrs_total_var,'k','LineWidth',2);
xlim([2009 2022]);
ylim([0 600]);
grid on;
xlabel('Year','FontSize',12);
ylabel('% Variability','FontSize',12);


%% Data from literature surveys with notes
% lucas (45nm) 500 is from balaji et al below
wanner2010_sleep_var = 500;
wanner2010_active_var = 10; 
plot(2010,10,'^r','MarkerSize',15, 'LineWidth',2);
plot(2010,500,'^r','MarkerSize',15, 'LineWidth',2, 'MarkerFaceColor','r');


% from UCSD accurate characterization of the variability in power
% consumption in modern mobile processors
% ( 32 nm) 17% worst case
balaji_2012_active_var = 17;
plot(2012,17,'sb','MarkerSize',15, 'LineWidth',2);

text(2010,300,'STILL WORKING ON THIS PLOT','FontSize',24);
saveplot('../rtss/figures/projected_variations');




