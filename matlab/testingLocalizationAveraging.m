%% Housekeeping
clc; close all; clear all;

%% 
num2avg = 6;
val = 50;
variance = 50;
data = val*ones(1,1000) + (randn(1,1000)-0.5)*50;

newvals = [];
for i=1:num2avg:(length(data)-num2avg)
    newvals = [newvals mean(data(i:(i+num2avg-1)))];
end

hist(newvals,10);

ylim([0 10]);

disp('true')
disp(val)
disp('30 avg')
disp(mean(val + (randn(1,30))*20));
disp('6 avg')
disp(mean(val + (randn(1,6))*20));

%% test uniform -> normal dist.
urand = rand(1,10000);
vrand = rand(1,10000);
nrand = sqrt(-2*log(urand)).*cos(2*pi*vrand);

hist(nrand,50);
