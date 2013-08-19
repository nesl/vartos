%% Housekeeping
close all; clear all; clc;

locations = {'Mauna_Loa', 'Sioux_Fall','Stovepipe'};
states = {'HI', 'SD','CA'};
instances = {'bc','nc','wc'};
dutycycles = [0.002 0.005 0.01 0.05 0.1];

errors = zeros(length(instances),length(locations),length(dutycycles));
avg_dc = zeros(length(instances),length(locations),length(dutycycles));

for i = 1:length(instances)
    inst = instances{i};
    for l = 1:length(locations)
        loc = locations{l};
        state = states{l};
        for j = 1:length(dutycycles)
            dc = dutycycles(j);
            % how much energy did we have to start?
            energy_budget = dcToEnergy(dc,loc,['pm/' inst]);
            % how much energy did we actually use?
            vemu_path = ['../results/controlloop_vemu/' ...
                inst '_' state '_' num2str(j-1)];
            data = csvread(vemu_path);
            energy_used = data(end,4);
            dc_inst = data(end,3);
            dc_avg = data(end,2);
            
            app_path = ['../results/controlloop_app/' ...
                inst '_' state '_' num2str(j-1)];
            %fid  = fopen(app_path);
            %data = textscan(fid,'%f,%f,%f','Delimiter',',','HeaderLines',10);
            %fclose(fid);
            %data = csvread(app_path,11,0,[11 0 40 2]);
            %dc_tgt = mean(data(:,3))/10000;
            dc_tgt = 0;
            
            avg_dc(i,l,j) = dc_avg;
            errors(i,l,j) = round(1000*(energy_budget-energy_used)/energy_budget)/10;
            %errors(i,l,j) = round(1000*(dc_tgt-dc_avg)/dc_tgt)/10;
            %errors(i,l,j) = energy_used;
            %fprintf('%d\t%d\n',energy_budget, energy_used);
        end
    end
end

%% Display
disp('Instance: BC');
disp(reshape(errors(1,:,:),...
    length(locations),...
    length(dutycycles)))

disp('Instance: NC');
disp(reshape(errors(2,:,:),...
    length(locations),...
    length(dutycycles)))

disp('Instance: WC');
disp(reshape(errors(3,:,:),...
    length(locations),...
    length(dutycycles)))

%imagesc( reshape(errors(3,:,:),...
%    length(locations),...
%    length(dutycycles)) );

%colorbar;

%% Plot
cfigure(40,8);

subaxis(1,3,1,'Margin', 0.03, 'MarginBottom',0.2,'Padding',0);
inst = 1;
semilogx(dutycycles,reshape(errors(inst,1,:),1,5),...
    'o-r','MarkerSize',10,'LineWidth',2);
hold on;
semilogx(dutycycles,reshape(errors(inst,2,:),1,5),...
    's-.b','MarkerSize',10,'LineWidth',2);
semilogx(dutycycles,reshape(errors(inst,3,:),1,5),...
    '^--k','MarkerSize',10,'LineWidth',2);
ylim([-6 6]);
xlim([10e-4 2e-1]);
xlabel('Target Duty Cycle (Inst: BC)','FontSize',12);
ylabel('Error in Energy Consumption (%)','FontSize',12);
legend('T: mild','T: medium','T: harsh','Location','NorthEast');
grid on;


subaxis(1,3,2,'Margin', 0.03, 'MarginBottom',0.2,'Padding',0);
inst = 2;
semilogx(dutycycles,reshape(errors(inst,1,:),1,5),...
    'o-r','MarkerSize',10,'LineWidth',2);
hold on;
semilogx(dutycycles,reshape(errors(inst,2,:),1,5),...
    's-.b','MarkerSize',10,'LineWidth',2);
semilogx(dutycycles,reshape(errors(inst,3,:),1,5),...
    '^--k','MarkerSize',10,'LineWidth',2);
ylim([-6 6]);
xlim([10e-4 2e-1]);
xlabel('Target Duty Cycle (Inst: NC)','FontSize',12);
ylabel('Error in Energy Consumption (%)','FontSize',12);
legend('T: mild','T: medium','T: harsh','Location','NorthEast');
grid on;



subaxis(1,3,3,'Margin', 0.03, 'MarginBottom',0.2,'Padding',0);
inst = 3;
semilogx(dutycycles,reshape(errors(inst,1,:),1,5),...
    'o-r','MarkerSize',10,'LineWidth',2);
hold on;
semilogx(dutycycles,reshape(errors(inst,2,:),1,5),...
    's-.b','MarkerSize',10,'LineWidth',2);
semilogx(dutycycles,reshape(errors(inst,3,:),1,5),...
    '^--k','MarkerSize',10,'LineWidth',2);
ylim([-6 6]);
xlim([10e-4 2e-1]);
xlabel('Target Duty Cycle (Inst: WC)','FontSize',12);
ylabel('Error in Energy Consumption (%)','FontSize',12);
legend('T: mild','T: medium','T: harsh','Location','NorthEast');
grid on;


saveplot('../rtss/figures/app1_controlloop');

