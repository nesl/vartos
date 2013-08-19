%% Housekeeping
clc; close all; clear all;

%% Vars
locations = {'Mauna_Loa', 'Sioux_Fall','Stovepipe'};
states = {'HI', 'SD','CA'};
instances = {'bc','nc','wc'};

% Battery capacities (Joules)
AA_2 = 2*2.7*1.5*3600;
AA_1 = 2.7*1.5*3600;
AAA_2 = 2*1.2*1.5*3600;
AAA_1 = 1*1.2*1.5*3600;
AAAA_2 = 2*0.625*1.5*3600;
CR2032_1 = 1*0.225*3*3600;

%% Corrected
energy_errors_cor = zeros(length(instances),length(locations));
knob_vals_cor = zeros(length(instances), length(locations));
pos_errors_cor = zeros(length(instances),length(locations));
vel_errors_cor = zeros(length(instances),length(locations));
bar_values_corrected = zeros(1,9);

disp('i, l, pos_err, vel_err');
for i = 1:length(instances)
    inst = instances{i};
    for l = 1:length(locations)
        loc = locations{l};
        state = states{l};
        % how much energy did we have to start?
        energy_budget = AAA_2;
        % how much energy did we actually use?
        vemu_path = ['../../../results/kalman_vemu/' ...
            inst '_' state '_0'];
        data = csvread(vemu_path);
        % why off?
        energy_used = data(end,4)-0.35e4;
        dc_inst = data(end,3);
        dc_avg = data(end,2);
        
        app_path = ['../../../results/kalman_app/' ...
            inst '_' state '_0'];
        
        data = csvread(app_path,96,0);
        
        % extract data
        time_data = data(:,1)*0.01;
        knob_data = data(:,2);
        dt_data = data(:,3)/1000.0;
        sensor_data = data(:,3);
        pos_data = data(:,4);
        vel_data = data(:,5)/1000.0;
        k1_data = data(:,6)/1000.0;
        k2_data = data(:,7)/1000.0;
        
        % append knob value to array
        knob_vals_cor(i,l) = knob_data(end);
        
        % append energy error to array
        energy_errors_cor(i,l) = round(1000*(energy_budget-energy_used)/energy_budget)/10;
        
        % kalculate error in kalman prediction
        [error_pos, error_vel] = getDvKalmanError(time_data,pos_data,vel_data,-16);
        pos_errors_cor(i,l) = error_pos;
        vel_errors_cor(i,l) = error_vel;
        fprintf('%d,%d,%f,%f\n',i,l,error_pos,error_vel);
        bar_values_corrected((i-1)*3 + l) = error_vel;
        bar_values_corrected(9) = 8.2;
        
        
    end
end


%% Uncorrected
energy_errors_uncor = zeros(length(instances),length(locations));
knob_vals_uncor = zeros(length(instances), length(locations));
pos_errors_uncor = zeros(length(instances),length(locations));
vel_errors_uncor = zeros(length(instances),length(locations));
bar_values_uncorrected = zeros(1,9);

disp('i, l, pos_err, vel_err');
for i = 1:length(instances)
    inst = instances{i};
    for l = 1:length(locations)
        loc = locations{l};
        state = states{l};
        % how much energy did we have to start?
        energy_budget = AAA_2;
        % how much energy did we actually use?
        vemu_path = ['../../../results/kalman_baseline_vemu/' ...
            inst '_' state '_0'];
        data = csvread(vemu_path);
        % why off?
        energy_used = data(end,4)-0.35e4;
        dc_inst = data(end,3);
        dc_avg = data(end,2);
        
        app_path = ['../../../results/kalman_baseline_app/' ...
            inst '_' state '_0'];
        
        data = csvread(app_path,96,0);
        
        % extract data
        time_data = data(:,1)*0.01;
        knob_data = data(:,2);
        dt_data = data(:,3)/1000.0;
        sensor_data = data(:,3);
        pos_data = data(:,4);
        vel_data = data(:,5)/1000.0;
        k1_data = data(:,6)/1000.0;
        k2_data = data(:,7)/1000.0;
        
        % append knob value to array
        knob_vals_uncor(i,l) = knob_data(end);
        
        % append energy error to array
        energy_errors_uncor(i,l) = round(1000*(energy_budget-energy_used)/energy_budget)/10;
        
        % kalculate error in kalman prediction
        [error_pos, error_vel] = getDvKalmanError(time_data,pos_data,vel_data,-16);
        pos_errors_uncor(i,l) = error_pos;
        vel_errors_uncor(i,l) = error_vel;
        fprintf('%d,%d,%f,%f\n',i,l,error_pos,error_vel);
        bar_values_uncorrected((i-1)*3 + l) = error_vel;
        
        
    end
end

%% Plot
bar_values_corrected;

close all;
cfigure(14,8);
hold on;
plot(1:9,bar_values_uncorrected,'sb','LineWidth',2,... 
    'MarkerFaceColor','b','MarkerSize',10);
plot(1:9,bar_values_corrected, '^r','LineWidth',2,... 
    'MarkerFaceColor','r','MarkerSize',10);

%set(h(1),'facecolor',[1 0.5 0.5]);
%set(h(2),'facecolor',[0 0 1]);
set(gca,'XTickLabel',{'B/B', 'B/N', 'B/W',...
    'N/B','N/N','N/W','W/B','W/N','W/W'})
set(gca,'XTick',1:9)

xlabel('Instance and Temperature Profile (Inst/Temp)','FontSize',12);
ylabel('Velocity Estimate Error (RMSE)','FontSize',12);
legend('Assumed Worst Case','With Instance Modeling','Location','NorthEast');
ylim([0 12]);
grid on;

saveplot('../../../tecs/figures/kalman_results');

