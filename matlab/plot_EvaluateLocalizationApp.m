%% Housekeeping
clc; close all;

%% Obtain the output data for processing
locations = {'Mauna_Loa', 'Sioux_Fall','Stovepipe'};
states = {'HI', 'SD','CA'};
instances = {'i01','i02','i03','i04','i05','i06','i07','i08'};
% Battery capacities (Joules)
AA_2 = 2*2.7*1.5*3600;
AA_1 = 2.7*1.5*3600;
AAA_2 = 2*1.2*1.5*3600;
AAA_1 = 1*1.2*1.5*3600;
AAAA_2 = 2*0.625*1.5*3600;
CR2032_1 = 1*0.225*3*3600;
% knob mins and maxes
knob_min_sensor = 1; % num_averages
knob_max_sensor = 100;
knob_min_radio = 100; % mHz TX
knob_max_radio = 5000;
% choose a certain location (it'd be too cluttered to loop them all)
IDX = 3;
loc = locations{IDX};
state = states{IDX};
% how much will we be reading per app file?
num_sensor_vals = 4200; % they're cut short, not sure why...
% data output arrays
sensor_outputs = zeros( length(instances), num_sensor_vals );
energy_outputs = zeros(1, length(instances) );
energy_errors = zeros(1, length(instances) );
dutycycle_outputs = zeros(1, length(instances) );
radio_knobs = zeros(1, length(instances));
sensor_knobs = zeros(1,length(instances));

% fudge factors for alignment
offsets = [38 38 38];
speedups = [1.035 1.035 1.035];

for i = 1:length(instances)
    inst = instances{i};
    
    % how much energy did we have to start?
    energy_budget = AAA_2;
    
    % =================== parse the vemu file ===================
    vemu_path = ['../results/localization_vemu/' inst '_' state];
    data = csvread(vemu_path);
    % how much energy did we actually use?
    energy_used = data(end,4);
    energy_outputs(i) = energy_used;
    energy_errors(i) = 100*(energy_budget-energy_used)/energy_budget;
    % what was our ending duty cycle?
    dc_inst = data(end,3);
    dc_avg = data(end,2);
    dutycycle_outputs(i) = dc_avg;
    
    % ==================== parse the app file ===================
    app_path = ['../results/localization_app/' inst '_' state];
    % the useful data starts at 313 and lasts for num_sensor_vals long
    startrow=312;
    data = csvread(app_path,startrow,0);
    data = data(:,1:4);
    % parse the radio and sensor outputs [taskID,knob_val,output_val]
    radio_data = data(find(data(:,1) == 1),:);
    sensor_data = data(find(data(:,1) == 0),:);
    % what are the final knob values?
    radio_knobs(i) = radio_data(end,2);
    sensor_knobs(i) = sensor_data(end,2);
    % grab the timestamps from the sensor output
    sensor_times = sensor_data(1:num_sensor_vals,4);
    % now toss all but the actual data
    sensor_data = sensor_data(1:num_sensor_vals,3);
    % some of the sensor data is corrupted, so we need to prune it, might
    % as well divide to get proper units here too
    threshold_high = 10000;
    threshold_low = 5;
    for j=1:length(sensor_data)
        
        if sensor_data(j) > threshold_high
            if j > 1
                sensor_data(j) = sensor_data(j-1);
            else
                sensor_data(j) = sensor_data(j+1);
            end
        end
        
        % protect against negative / too small
        if sensor_data(j) < threshold_low
            sensor_data(j) = threshold_low;
        end
        
        % divide by 100 to get into meters
        sensor_data(j) = sensor_data(j)/100;
        
    end
    % construct the sensor stream output array
    sensor_outputs(i,:) = sensor_data;
    
end

%% Calculate Initial Results
clc;
disp('Radio Knob Values')
disp(radio_knobs');
disp('Sensor Knob Values');
disp(sensor_knobs');
disp('Average Radio Latency (sec)');
disp(mean(radio_knobs)/1000);
disp('Worst Case Radio Latency (sec)');
disp(max(radio_knobs)/1000);
disp('Errors in Energy Consumption (%)');
disp(energy_errors);

%% Calculate localization error results
velocity_kmph = 0.2; % km/h

% sensor measurement error
sensor_errors = zeros(8,num_sensor_vals);
localization_errors = zeros(1,num_sensor_vals);
ideal_distances = zeros(8,num_sensor_vals);


% guesses and actual values
estimates_x = zeros(1,num_sensor_vals);
estimates_y = zeros(1,num_sensor_vals);
real_x = zeros(1,num_sensor_vals);
real_y = zeros(1,num_sensor_vals);

% Track Size
track_circumference = 300; % meters
track_radius = track_circumference/(2*pi); % meters

% Sensor node locations
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

xhat = 0;
yhat = 0;

for i = 1:num_sensor_vals
    
    time_sec = i*0.2;
    
    % get sensor distance values
    good_nodes = [];
    good_values = [];
    
    for s = 1:length(instances)
        
        % calculate ideal sensor measurement
        % note we have a 3% speedup and 2.4 s offset for some reason, so
        % i'm fudging it here
        speedup = speedups(IDX);
        offset = offsets(IDX);
        [d_ideal,car_x,car_y] = getCarSensorValue(s,velocity_kmph*speedup,0,time_sec-offset);
        
        ideal_distances(s,i) = d_ideal;
        
        % get the actual sensor measurement
        d_sensor = sensor_outputs(s,i);
        if d_sensor ~= -1 && d_ideal ~= -1
            sensor_errors(s,i) = 100*(d_ideal-d_sensor)/d_ideal;
        else
            sensor_errors(s,i) = NaN;
        end
        
        
        % keep track of nodes that sensed the unknown object
        if d_sensor ~= -1
            good_nodes = [good_nodes s];
            good_values = [good_values d_sensor];
        end
    end
    
    real_x(i) = car_x;
    real_y(i) = car_y;
    
    % calculate intersections of distance circles
    if length(good_nodes) >= 3
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
    
    
    % calculate the estimated (x,y) coords. of the car
    if ~isempty(intersections)
        xhat = mean(intersections(1,:));
        yhat = mean(intersections(2,:));
    end
    
    estimates_x(i) = xhat;
    estimates_y(i) = yhat;
    
    % what is our localization error?
    dist_error = sqrt( (xhat-car_x)^2 + (yhat-car_y)^2 );
    localization_errors(i) = dist_error;
    
    
    %fprintf('error: %f\n',dist_error);
    
    
end

%% Save the results
fstring = sprintf('loc_errors_var_%d',IDX);
%save(fstring,'localization_errors');

%% Plot the results
endtime = 2000;
windowsize = 1;

plot(filter(ones(1,windowsize)/windowsize,1,so1),'b','LineWidth',1);
ylim([0 50]);

%% Plot All results
endtime = 2000;
windowsize = 50;

load('loc_errors_var_1.mat');
so1 = localization_errors;
so1 = filter(ones(1,windowsize)/windowsize,1,so1);
load('loc_errors_var_2.mat');
so2 = localization_errors;
so2 = filter(ones(1,windowsize)/windowsize,1,so2);
load('loc_errors_var_3.mat');
so3 = localization_errors;
so3 = filter(ones(1,windowsize)/windowsize,1,so3);

cfigure(30,10);
plot((1:endtime)*0.2, so1(1:endtime),'-k', 'LineWidth',2);
hold on;
plot((1:endtime)*0.2, so2(1:endtime),'--r', 'LineWidth',2);
plot((1:endtime)*0.2, so3(1:endtime),'-.b', 'LineWidth',2);

grid on;
ylim([0 50]);
xlabel('Time (minutes)','FontSize',12);
ylabel('Estimation Error (%)','FontSize',12);
legend('Location','NorthEast','T: Mild','T: Medium','T: Harsh');

%saveplot('../tecs/figures/localization_var');


%% Plot variance of ALL
endtime = 2000;
windowsize = 20;

load('loc_errors_var_1.mat');
so1 = localization_errors(1:endtime);
so1 = windowedVar(so1, windowsize);
load('loc_errors_var_2.mat');
so2 = localization_errors(1:endtime);
so2 = windowedVar(so2, windowsize);
load('loc_errors_var_3.mat');
so3 = localization_errors(1:endtime);
so3 = windowedVar(so3, windowsize);

cfigure(14,8);
plot(20*0.5*(1:length(so1)), so1,'-k', 'LineWidth',2);
hold on;
plot(20*0.5*(1:length(so2)), so2,'--r', 'LineWidth',2);
plot(20*0.5*(1:length(so3)), so3,'-.b', 'LineWidth',2);

grid on;
ylim([0 200]);
xlabel('Time (minutes)','FontSize',12);
ylabel('Error Variance (m^2)','FontSize',12);
legend('Location','NorthEast','T: Mild','T: Medium','T: Harsh');

saveplot('../tecs/figures/localization_variance_var');



%% Check alignment
idx = 8;

cfigure(40,10);
so = sensor_outputs;
plot(so(idx,:));
hold on;
plot(ideal_distances(idx,:),'r');

%% Plot sample sensor streams
idx = 8;

cfigure(20,10);
so = sensor_outputs;
plot(so(idx,:),'b','LineWidth',2);
hold on;
% 448
plot(ideal_distances(idx,1:end),'--r','LineWidth',2);
xlabel('Time (minutes)','FontSize',12);
ylabel('Measurement (m)','FontSize',12);
ylim([0 100]);
xlim([400 750]);
legend('Ideal Measurement','Simulated Measurement','Location','NorthEast');
%saveplot('../tecs/figures/localization_stream_wc');









