clc; close all; clear all;

%% Load Temp. Profile
sleep_variance = 5e3; %uW
num_bins = 10;
temp_path = '../weather-multiple/data/';
all_files = dir(temp_path);
temp_files = {};

for i = 1:length(all_files)
    str = all_files(i).name;
    match_str = ['.*20.*'];
    if ~isempty(regexp(str,match_str,'match'))
        temp_files = [temp_files; str];
    end
    
end

inst = 'wc';
vemu_file = ['pm/' inst];
NUM_ITER = 200;

%%
error_array = zeros(length(temp_files), NUM_ITER);


for i = 1:length(temp_files)
    fname = temp_files{i};
    fprintf('file %d\tof\t%d\n',i,length(temp_files));
    
    %disp('Loading temperature profile from:');
    %disp(good_file);
    temp_data = csvread([temp_path fname]);
    
    [temp_hist,bin_centers] = hist(temp_data,num_bins);
    % scale temp_hist to 50% =  1 byte like VaRTOS does
    temp_hist = 2*255*(temp_hist./length(temp_data));
    temp_hist = round(temp_hist);
    bin_width = bin_centers(2)-bin_centers(1);
    start_temp = round(bin_centers(1));
    
    %% Load VarEMU data
    data = csvread(vemu_file);
    N = length(data(:,1));
    T_array = data(:,1);
    Ps_array = data(:,2)*1e9; % to nW
    
    %% Model sleep power: approximate linearization and least squares
    p_s = polyfit(T_array, log(Ps_array), 1);
    %p_s = [0.01947 11.728];
    %Ps_linear = exp(polyval(p_s,T_array));
    
    %% iterate through learning
    errors = zeros(1,length(N));
    
    for j = 1:NUM_ITER
        n = j+1;
        test_temp = temp_data(1:n);
        test_ps = polyval(p_s,test_temp) + randn(n,1)*sleep_variance;
        test_temp = round(test_temp);
        tp_s = abs(polyfit(test_temp, log(test_ps), 1));
        
        Ps_linear = exp(polyval(tp_s,T_array))/1e9;

        e = norm(Ps_linear-Ps_array,2);
        errors(n-1) = e;
    end
    
    error_array(i,:) = errors;
  
    
end

% save results
fstring = sprintf('pow_errors_%s',inst);
%save(fstring,'error_array');

%% Plot
close all;
end_iter = 200;
start_iter = 3;

cfigure(14,8);
hold on;

% BC
load('pow_errors_bc.mat');
bc_errors = error_array(:,1:end_iter);
bc_ss = diag(bc_errors(:,end))*ones(length(temp_files), end_iter);
bc_perc = 100*(bc_errors - bc_ss)./bc_ss;
[bc_mean, bc_max, bc_min, bc_std] = statsNoInf(abs(bc_perc));

% NC
load('pow_errors_nc.mat');
nc_errors = error_array(:,1:end_iter);
nc_ss = diag(nc_errors(:,end))*ones(length(temp_files), end_iter);
nc_perc = 100*(nc_errors - nc_ss)./nc_ss;
[nc_mean, nc_max, nc_min, nc_std] = statsNoInf(abs(nc_perc));

% WC
load('pow_errors_wc.mat');
wc_errors = error_array(:,1:end_iter);
wc_ss = diag(wc_errors(:,end))*ones(length(temp_files), end_iter);
wc_perc = 100*(wc_errors - wc_ss)./wc_ss;
[wc_mean, wc_max, wc_min, wc_std] = statsNoInf(abs(wc_perc));

% stats
all_perc = [bc_perc;nc_perc;wc_perc];
[the_mean, the_max, the_min, the_std] = statsNoInf(abs(all_perc));
the_std = medfilt1(the_std,6);
the_std(60:end) = 0;
conf_99 = the_mean + 2.33*the_std;
conf_90 = the_mean + 1.28*the_std;

%plot(1+(1:end_iter),nc_max,'-k');
plot(1+(1:end_iter),the_mean,'-b', 'LineWidth',2);
plot(1+(1:end_iter),conf_90,'o-r', 'LineWidth',2);
plot(1+(1:end_iter),conf_99,'^-k', 'LineWidth',2);


xlim([start_iter 100]);
xlabel('Time (hours)','FontSize',12);
ylabel('Error (%)','FontSize',12);
legend('Mean Error','90% Confidence Interval','99% Confidence Interval'...
    ,'Location','NorthEast');
grid on;

saveplot('../tecs/figures/powerconvergence');


