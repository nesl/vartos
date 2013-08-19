%% Housekeeping
clc; close all; clear all;


%% Track construction
track_circumference = 300; % meters
track_radius = track_circumference/(2*pi); % meters

%% Car construction
car_length = 1; % meters

%% Sensor construction
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

%% Plot nodes & node observation radii
cfigure(16,16);
scatter(node_coords(:,1), node_coords(:,2), 200*ones(1,N),'sr',...
    'MarkerFace','r');
xlim([-100 100]);
ylim([-100 100]);
hold on;

% node visibility radius
observation_radius = 80;
for n=1:N
    circle2(node_coords(n,1),node_coords(n,2),observation_radius);
end

%% Get Results
SECONDS_IN_YEAR = 365*24*3600;
times = 1:(1/1000):10;
speed = 0.4; % km/h

[d,x,y] = getCarSensorValue(1,speed,0,0);
h_unk = plot(x,y,'ob','MarkerSize',20,'MarkerFaceColor','blue');

sensor_distances = zeros(1,N);
sensor_text_handles = zeros(1,N);
for s=1:N
    sensor_text_handles(s) = ...
        text(node_coords(s,1),...
        node_coords(s,2)+10,num2str(-1));
end
estimate_handle = plot(0,0,'^r','MarkerSize',10,...
    'MarkerFaceColor','cyan');
xhat = 0;
yhat = 0;

xlabel('X Coordinate','FontSize',12);
ylabel('Y Coordinate','FontSize',12);
legend('Fixed Nodes','Unknown Node','Estimate',...
    'Location','NorthEast');

for i=1:length(times);
    t_sec = times(i);
    pause(0.1);
    
    % get sensor distance values
    good_nodes = [];
    good_values = [];
    for s=1:N
        [d,x,y] = getCarSensorValue(s,speed,10,t_sec);
        set(sensor_text_handles(s),'String',num2str(d));
        sensor_distances(s) = d;
        
        if d ~= -1
            good_nodes = [good_nodes s];
            good_values = [good_values d];
        end
    end
    
    % update real unknown location
    set(h_unk,'XData',x);
    set(h_unk,'YData',y);
    pause(0.2);
    
    if length(good_nodes) >= 3
        % find intersection of distance circles
        intersections = [];
        for s1=1:(length(good_nodes)-1)
            s1_id = good_nodes(s1);
            s1_d = good_values(s1);
            s1_x = node_coords(s1_id,1);
            s1_y = node_coords(s1_id,2);
            
            for s2=1:(length(good_nodes)-1)
                if s1 == s2
                    continue
                end
                s2_id = good_nodes(s2);
                s2_d = good_values(s2);
                s2_x = node_coords(s2_id,1);
                s2_y = node_coords(s2_id,2);
                
                [xout,yout] = circcirc(...
                    s1_x,s1_y,s1_d,...
                    s2_x,s2_y,s2_d );
                
                if ~( isnan(xout) & isnan(yout) )
                    intersections = [intersections [xout;yout]];
                end
                
                
            end
            
            
        end
    end
        
    if ~isempty(intersections)
        xhat = median(intersections(1,:));
        yhat = median(intersections(2,:));
    end
    
    set(estimate_handle,'XData',xhat);
    set(estimate_handle,'YData',yhat);
    
    
    
end

