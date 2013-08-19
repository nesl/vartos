%% Housekeeping
clc; clear all; close all;


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
energy_errors = zeros(length(instances),length(locations));

knob_vals = zeros(length(instances), length(locations), 2);
bar_values_corrected = zeros(1,9);

for i = 1:length(instances)
    inst = instances{i};
    for l = 1:length(locations)
        loc = locations{l};
        state = states{l};
            % how much energy did we have to start?
            energy_budget = AAA_2;
            % how much energy did we actually use?
            vemu_path = ['../results/multiblock_vemu/' ...
                inst '_' state '_0'];
            data = csvread(vemu_path);
            energy_used = data(end,4);
            dc_inst = data(end,3);
            dc_avg = data(end,2);
            
            app_path = ['../results/multiblock_app/' ...
                inst '_' state '_0'];

            data = csvread(app_path,410,0);
            sensor1_data = data(find(data(:,1) == 0),:);
            sensor2_data = data(find(data(:,1) == 1),:);
            sensor1_knob = sensor1_data(end,2);
            sensor2_knob = sensor2_data(end,2);
            
            knob_vals(i,l,1) = sensor1_knob;
            knob_vals(i,l,2) = sensor2_knob;
            
            
            energy_errors(i,l) = round(1000*(energy_budget-energy_used)/energy_budget)/10;
            bar_values_corrected(3*(i-1)+l) = energy_errors(i,l);

    end
end

knob_vals

%% Uncorrected

energy_errors = zeros(length(instances),length(locations));

knob_vals = zeros(length(instances), length(locations), 2);
bar_values_uncorrected = zeros(1,9);

for i = 1:length(instances)
    inst = instances{i};
    for l = 1:length(locations)
        loc = locations{l};
        state = states{l};
            % how much energy did we have to start?
            energy_budget = AAA_2;
            % how much energy did we actually use?
            vemu_path = ['../results/multiblock_baseline_vemu/' ...
                inst '_' state '_0'];
            data = csvread(vemu_path);
            energy_used = data(end,4);
            dc_inst = data(end,3);
            dc_avg = data(end,2);
            
            app_path = ['../results/multiblock_baseline_app/' ...
                inst '_' state '_0'];

            data = csvread(app_path,410,0);
            sensor1_data = data(find(data(:,1) == 0),:);
            sensor2_data = data(find(data(:,1) == 1),:);
            sensor1_knob = sensor1_data(end,2);
            sensor2_knob = sensor2_data(end,2);
            
            knob_vals(i,l,1) = sensor1_knob;
            knob_vals(i,l,2) = sensor2_knob;
            
            
            energy_errors(i,l) = round(1000*(energy_budget-energy_used)/energy_budget)/10;
            bar_values_uncorrected(3*(i-1)+l) = energy_errors(i,l);

    end
end

knob_vals

%% Plot
bar_values_corrected;

close all;
cfigure(18,10);
h = bar(1:9,[bar_values_uncorrected; bar_values_corrected]');

set(h(1),'facecolor',[1 0.5 0.5]);
set(h(2),'facecolor',[0 0 1]);
set(gca,'XTickLabel',{'B/B', 'B/N', 'B/W',...
    'N/B','N/N','N/W','W/B','W/N','W/W'})
ylabel('Error in Energy Expenditure (%)','FontSize',12);
xlabel('Instance and Temperature Profile (Inst/Temp)','FontSize',12);
legend('Assumed Worst Case','With Instance Modeling','Location','NorthEast');

ylim([-30 80]);
saveplot('../tecs/figures/app3_energycomp');

