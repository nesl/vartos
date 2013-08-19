%% Housekeeping
clc; clear all; close all;

%% Node locations
car_circumference = 500; % meters
car_radius = car_circumference/(2*pi); % meters
car_length = 1; % meters

N = 9;
r_x2 = car_radius*2;
a = r_x2*sqrt(2)/2;

node_coords = [
    -a , a
    0  , r_x2
    a  , a
    -r_x2 , 0
    0  , 0
    r_x2  , 0
    -a , -a
    0  , -r_x2
    a  , -a
    ];

cfigure(20,20);
scatter(node_coords(:,1), node_coords(:,2), 200*ones(1,N),'sr',...
    'MarkerFace','r');
xlim([-180 180]);
ylim([-180 180]);
hold on;

% node visibility radius
observation_radius = 100;
for n=1:N
    circle2(node_coords(n,1),node_coords(n,2),observation_radius);
end

%% Unknown node parameters
unknown_coord = car_radius*[1,0]; %x,y
start_angle = 0;

%% Angular velocity
inst_velocity_kmph = 0.1; % km/h
inst_velocity_mps = inst_velocity_kmph*1000/60;
rad_per_sec = (2*pi/car_circumference)*inst_velocity_mps;
omega = rad_per_sec;

%% Timescale
SECONDS_IN_YEAR = 365*24*3600;
HOURS_IN_YEAR = 365*24;

times = 0:SECONDS_IN_YEAR;

h_unk = plot(unknown_coord(1), unknown_coord(2),...
    'ob','MarkerFaceColor','b','MarkerSize',20);

for i=1:length(times);
    t_sec = times(i);
    unknown_coord = car_radius*[cos(omega*t_sec) sin(omega*t_sec)];
    set(h_unk,'XData',unknown_coord(1));
    set(h_unk,'YData',unknown_coord(2));
    pause(0.1);
    
end
