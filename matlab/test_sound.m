%% Housekeeping
clc; close all; clear all;
% generate time vector
SR = 44.1e3;
t = 0:(1/SR):1;
freq = 440;
output = sin(2*pi*freq*t);

output = output + sin(2*pi*600*t);

sound(output,SR);