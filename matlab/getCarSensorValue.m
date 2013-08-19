function [d,xreal,yreal] = getCarSensorValue(sensorID, velocity_kmph, noise_variance, time_sec)

%% Track Size
track_circumference = 300; % meters
track_radius = track_circumference/(2*pi); % meters

%% Car length
car_length = 1; % meters

%% Sensor node locations
N = 8;
r_x = track_radius*1.3;
a = r_x*sqrt(2)/2;

node_coords = [
    -a , a
    0  , r_x
    a  , a
    -r_x , 0
    r_x  , 0
    -a , -a
    0  , -r_x
    a  , -a
    ];

%% node visibility radius
observation_radius = 80;

%% Angular velocity conversion
inst_velocity_kmph = velocity_kmph; % km/h
inst_velocity_mps = inst_velocity_kmph*1000/60;
rad_per_sec = (2*pi/track_circumference)*inst_velocity_mps;
omega = rad_per_sec;

%% Calculate sensor value
node_x = node_coords(sensorID,1);
node_y = node_coords(sensorID,2);
car_x = track_radius*cos(omega*time_sec);
car_y = track_radius*sin(omega*time_sec);

d = sqrt( (node_x-car_x)^2 + (node_y-car_y)^2 );

% here we'd add noise
d = d + noise_variance*(rand-0.5);

% make sure it doesn't go nonpositive
if d < 0.05
    d = 0.05;
end

if d > observation_radius
    d = -1;
end

% assign true car locations
xreal = car_x;
yreal = car_y;



end
