%% Housekeeping
close all; clear all; clc;

locations = {'Mauna_Loa', 'Sioux_Fall','Stovepipe'};
states = {'HI', 'SD','CA'};
instances = {'bc','nc','wc'};

errors = zeros(length(instances),length(locations));
lifetimes = zeros(length(instances),length(locations));
dutycycles = zeros(length(instances),length(locations));
energyused = zeros(length(instances),length(locations));
energyerrors = zeros(length(instances),length(locations));

% Battery capacities
AA_2 = 2*2.7*1.5*3600;
AA_1 = 2.7*1.5*3600;
AAA_2 = 2*1.2*1.5*3600;
AAA_1 = 1*1.2*1.5*3600;
AAAA_2 = 2*0.625*1.5*3600;
CR2032_1 = 1*0.225*3*3600;



%% corrected run

% how much energy did we have to start?
energy_budget = AAA_2*1.0;

for i = 1:length(instances)
    inst = instances{i};
    for l = 1:length(locations)
        loc = locations{l};
        state = states{l};
        
        
        % how much energy did we actually use?
        vemu_path = ['../results/single_AAA2_var_vemu/' ...
            inst '_' state '_0'];
        data = csvread(vemu_path);
        energyused(i,l) = data(end,4);
        energyerrors(i,l) = 100*(energy_budget - data(end,4))/energy_budget;
        
        % what was our duty cycle over that time?
        dutycycles(i,l) = data(end,2);
        
        % how long until we depleted our energy reserves?
        energy_used_sofar = data(:,4);
        time_elapsed_sofar = data(:,1);
        
        lifetime = -1;
        for j=1:length(energy_used_sofar)
            e = energy_used_sofar(j);
            if e > energy_budget
                % convert lifetime from seconds to hours
                lifetime = time_elapsed_sofar(j)/3600;
                break;
            end
        end
        if lifetime == -1
            % we lasted the whole year
            lifetime = 365*24;
        end
        
        app_path = ['../results/single_AAA2_var_app/' ...
            inst '_' state '_0'];
        
        lifetimes(i,l) = lifetime;
    end
end

bar_values_corrected = [energyerrors(1,:) energyerrors(2,:) energyerrors(3,:)];
box_values_corrected = [energyerrors(:,1) energyerrors(:,2) energyerrors(:,3)];
dutycycles_corrected = [dutycycles(1,:) dutycycles(2,:) dutycycles(3,:)];
%% uncorrected run

% how much energy did we have to start?
energy_budget = AAA_2;

for i = 1:length(instances)
    inst = instances{i};
    for l = 1:length(locations)
        loc = locations{l};
        state = states{l};
        
        
        % how much energy did we actually use?
        vemu_path = ['../results/single_AAA2_vemu/' ...
            inst '_' state '_0'];
        data = csvread(vemu_path);
        energyused(i,l) = data(end,4);
        energyerrors(i,l) = 100*(energy_budget - data(end,4))/energy_budget;
        
        % what was our duty cycle over that time?
        dutycycles(i,l) = data(end,2);
        
        % how long until we depleted our energy reserves?
        energy_used_sofar = data(:,4);
        time_elapsed_sofar = data(:,1);
        
        lifetime = -1;
        for j=1:length(energy_used_sofar)
            e = energy_used_sofar(j);
            if e > energy_budget
                % convert lifetime from seconds to hours
                lifetime = time_elapsed_sofar(j)/3600;
                break;
            end
        end
        if lifetime == -1
            % we lasted the whole year
            lifetime = 365*24;
        end
        
        app_path = ['../results/single_AAA2_app/' ...
            inst '_' state '_0'];
        
        lifetimes(i,l) = lifetime;
    end
end

bar_values_uncorrected = [energyerrors(1,:) energyerrors(2,:) energyerrors(3,:)];
box_values_uncorrected = [energyerrors(:,1) energyerrors(:,1) energyerrors(:,3)];
dutycycles_uncorrected = [dutycycles(1,:) dutycycles(2,:) dutycycles(3,:)];

%% Plot Energy error
close all;
cfigure(14,8);
h = bar(1:9,[bar_values_uncorrected; bar_values_corrected]');
%h = boxplot(...
%    [box_values_uncorrected(:,1) box_values_corrected(:,1)...
%    box_values_uncorrected(:,2) box_values_corrected(:,2)...
%    box_values_uncorrected(:,3) box_values_corrected(:,3)],0);

% scatter([1 1 1], box_values_uncorrected(:,1), [200 200 200],'sr','MarkerFaceColor','r');
% hold on;
% scatter([1 1 1], box_values_corrected(:,1), [200 200 200],'^b','MarkerFaceColor','b');
% scatter([2 2 2], box_values_uncorrected(:,2), [200 200 200],'sr','MarkerFaceColor','r');
% scatter([2 2 2], box_values_corrected(:,2), [200 200 200],'^b','MarkerFaceColor','b');
% scatter([3 3 3], box_values_uncorrected(:,3), [200 200 200],'sr','MarkerFaceColor','r');
% scatter([3 3 3], box_values_corrected(:,3), [200 200 200],'^b','MarkerFaceColor','b');
% xlim([0 4]);
% set(gca,'XTickLabel',{'BC Temp','NC Temp','WC Temp'})
% set(gca,'XTick',[1 2 3]);

%errorbar([1

set(h(1),'facecolor',[1 0.5 0.5]);
set(h(2),'facecolor',[0 0 1]);
set(gca,'XTickLabel',{'B/B', 'B/N', 'B/W',...
    'N/B','N/N','N/W','W/B','W/N','W/W'})
ylabel('Error in Energy Expenditure (%)','FontSize',12);
xlabel('Instance and Temperature Profile (Inst/Temp)','FontSize',12);
legend('Assumed Worst Case','With Instance Modeling','Location','NorthEast');
grid on;
%saveplot('../tecs/figures/app1_energycomp');

%% Plot Duty cycles
close all;
cfigure(14,8);
h = bar(1:9,[dutycycles_uncorrected; dutycycles_corrected]');
set(h(1),'facecolor',[1 0.5 0.5]);
set(h(2),'facecolor',[0 0 1]);
set(gca,'XTickLabel',{'B/B', 'B/N', 'B/W',...
    'N/B','N/N','N/W','W/B','W/N','W/W'})
ylabel('Average Duty Cycle','FontSize',12);
xlabel('Instance and Temperature Profile (Inst/Temp)','FontSize',12);
legend('Assumed Worst Case','With Instance Modeling','Location','NorthEast');
grid on;
%saveplot('../tecs/figures/app1_dutycycles');

