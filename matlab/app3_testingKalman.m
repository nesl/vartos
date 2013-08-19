%% Housekeeping
clc; close all; clear all;

%% Gradient descent to solve matrix inversion
theta = 1; % degrees
omega = 3;
H = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];

x = [1;0]; % x,y = (1,0)
times = 1:0.5:3000;

states = zeros(2,length(times));

for i = 1:length(times);
    % grab new time
    t = times(i);
    
    % kalman update
    
    
    % state update
    x = H*x + sind(omega*t);
    states(:,i) = x;
end


scatter(states(1,:), states(2,:));