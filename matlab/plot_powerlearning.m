%% Housekeeping
clc; clear all; close all;

instances = {'bc','nc','wc'};
data_colors = {'-k','-b','-r'};
model_colors = {'--k','--c','--m'};
error_colors = {'sk','ob','^r'};

cfigure(30,16);

for idx = 1:length(instances)
    inst = instances{idx};
    
    %% Load VarEMU data
    
    data = csvread(['pm/' inst]);
    N = length(data(:,1));
    T_array = data(:,1);
    Ps_array = data(:,2)*1e9;
    Pa_array = data(:,3)*1e9;
    
    
    %% Model sleep power: approximate linearization and least squares
    subplot(221);
    plot(T_array, Ps_array/1e3,data_colors{idx},'LineWidth',2);
    hold on;
    grid on;
    
    p = polyfit(T_array, log(Ps_array), 1);
    Ps_linear = exp(polyval(p,T_array));
    plot(T_array, Ps_linear/1e3,model_colors{idx},'LineWidth',2,'MarkerSize',7);
    xlim([-20 100]);
    
    
    %% Calculate error
    subplot(222);
    error = 100*(Ps_array-Ps_linear)./Ps_array;
    plot(T_array,error,error_colors{idx},'LineWidth',1);
    hold on;
    
    
    %% Model active power: linear addition to sleep power
    subplot(223);
    
    plot(T_array, Pa_array/1e6, data_colors{idx},'LineWidth',2);
    hold on;
    grid on;
    
    p = polyfit(T_array, Pa_array-Ps_linear, 1);
    Pa_linear = Ps_linear+polyval(p,T_array);
    plot(T_array, Pa_linear/1e6,model_colors{idx},'LineWidth',2);
    
    
    %% Get active est. error
    subplot(224);
    error = 100*(Pa_array-Pa_linear)./Pa_array;
    plot(T_array,error,error_colors{idx},'LineWidth',1,'MarkerSize',7);
    hold on;
    grid on;
    
    
end


%% Legend
subplot(221);
legend('BC','BC fit','NC','NC fit','WC','WC fit',...
    'Location','NorthWest');
xlabel('Temperature (\circC)','FontSize',12);
ylabel('Idle Power (\muW)','FontSize',12);

subplot(222);
legend('BC fit error','NC fit error','WC fit error',...
    'Location','NorthWest');
xlabel('Temperature (\circC)','FontSize',12);
ylim([-15 15]);
xlim([-20 100]);
plot([min(T_array) max(T_array)], [0 0], '-k');

xlabel('Temperature (\circC)','FontSize',12);
ylabel('Error (%)','FontSize',12);
grid on;

subplot(223);
xlim([-20 100]);
legend('BC','BC fit','NC','NC fit','WC','WC fit',...
    'Location','NorthWest');
xlabel('Temperature (\circC)','FontSize',12);
ylabel('Active Power (mW)','FontSize',12);

subplot(224);
legend('BC fit error','NC fit error','WC fit error',...
    'Location','NorthWest');xlabel('Temperature (\circC)','FontSize',12);
ylim([-15 15]);
xlim([-20 100]);


xlabel('Temperature (\circC)','FontSize',12);
ylabel('Error (%)','FontSize',12);
plot([min(T_array) max(T_array)], [0 0], '-k');

%saveplot('../tecs/figures/powerlearning');




