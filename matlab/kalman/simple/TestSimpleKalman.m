global z

% Housekeeping
clear all;
close all;
clc;

% time definition (dt will have to change here)
dt = 0.2;
t = 0:dt:50;
Nsamples = length(t);

% output arrays
Xsaved = zeros(Nsamples,1);
Zsaved = zeros(Nsamples, 1);

% kalman recursion
for k=1:Nsamples
    z = GetVolt();
    volt = SimpleKalman(z);
    Xsaved(k) = volt;
    Zsaved(k) = z;
end

figure();
plot(t, Xsaved, 'o-');
hold on;
plot(t, Zsaved, 'r:*');
legend('Kalman','True');

ylim([-10 10]);