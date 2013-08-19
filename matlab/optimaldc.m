%% Housekeeping
clc; clear all; close all;

%% Variables
%V * A * sec * min * hour * days
E = 1*1e-3 * 60 * 60 * 24 * 80;
E = 11323;
% days * hours * mins * seconds
L = 365 * 24 * 60 * 60; % seconds

%% Load Temp. Profile
num_bins = 5;
descriptor = 'Stovepipe';
temp_path = '../varemu/weather/';
potential_files = dir(temp_path);
good_file = [];

for i = 1:length(potential_files)
    str = potential_files(i).name;
    match_str = ['CRNH0202.*\_' descriptor '.*'];
    if ~isempty(regexp(str,match_str,'match'))
        good_file = str;
    end
end

disp('Loading temperature profile from:');
disp(good_file);
temp_data = csvread([temp_path good_file]);

[temp_hist,bin_centers] = hist(temp_data,num_bins);
% scale temp_hist to 50% =  1 byte like VaRTOS does
temp_hist = 2*255*(temp_hist./length(temp_data));
temp_hist = round(temp_hist);
bin_width = bin_centers(2)-bin_centers(1);
start_temp = round(bin_centers(1));

%% Load VarEMU data
sleep_variance = 0*1e3*10; %nW
active_variance = 0*1e3*10; %nW

data = csvread('vemu_power_45nm.csv');
N = length(data(:,1));
T_array = data(:,1);
Ps_array = data(:,2)*1e9+randn(N,1)*sleep_variance; % to nW
Pa_array = data(:,3)*1e9+randn(N,1)*active_variance; % to nW

%% Model sleep power: approximate linearization and least squares
p_s = polyfit(T_array, log(Ps_array), 1);
p_s = [0.01947 11.728];
Ps_linear = exp(polyval(p_s,T_array));

%% Model active power: linear addition to sleep power
p_a = polyfit(T_array, Pa_array-Ps_linear, 1);
p_a = [-0.00112 7.51653440e5];

%% Calculate the optimal DC as per lucas' equations in the
% earlier paper

sum1 = 0;
sum2 = 0;
for i=1:length(temp_hist)
    temp = start_temp + (i-1)*bin_width;
    freq = 0.5*(temp_hist(i)/255.0);
    ps = exp(polyval(p_s,temp));
    pa = polyval(p_a,temp);
    sum1 = sum1 + 1e-9*ps*freq;
    sum2 = sum2 + 1e-9*(pa)*freq;
end

gamma = ( E - L*sum1 )/( L*sum2 );
disp('gamma = ');
disp(gamma);

%% Plot optimal duty cycles for various lifetimes and num_bins

bin_sizes = [1 3 10 50];
days = 150:1:250;

dcopt = zeros(length(bin_sizes),length(days));

for m = 1:length(bin_sizes);
    bin_size = bin_sizes(m);
    
    [temp_hist,bin_centers] = hist(temp_data,bin_size);
    % scale temp_hist to 50% =  1 byte like VaRTOS does
    temp_hist = 2*(temp_hist./length(temp_data))*255;
    temp_hist = round(temp_hist);
    
    if length(bin_centers) > 1
        bin_width = bin_centers(2)-bin_centers(1);
    else
        bin_width = 0;
    end
    
    start_temp = round(bin_centers(1));
    
    for n = 1:length(days);
        d = days(n);
        
        % days * hours * mins * seconds
        L = d*24*60*60; % seconds
        
        sum1 = 0;
        for i=1:length(temp_hist)
            temp = start_temp + (i-1)*bin_width;
            sum1 = sum1 + 1e-9*exp(polyval(p_s,temp))*0.5*(temp_hist(i)/255);
        end
        
        sum2 = 0;
        for i=1:length(temp_hist)
            temp = start_temp + (i-1)*bin_width;
            sum2 = sum2 + 0.5*(temp_hist(i)/255)*...
                1e-9*(polyval(p_a,temp) - polyval(p_s,temp));
        end
        
        gamma = ( E - L*sum1 )/( L*sum2 );
        dc = max(min(gamma,1),0);
        dcopt(m,n) = dc;
        
    end
    
end

cfigure(15,10);
colors = hsv(length(bin_sizes));
hold on;
grid on;

for i=1:length(bin_sizes)
    plot(days,100*dcopt(i,:),'Color',colors(i,:));
end

xlabel('Lifetime Goal (days)','FontSize',12);
ylabel('Optimal DC (%)','FontSize',12);
legend('nBins = 1','nBins = 3','nBins = 10','nBins = 50','nBins = 10');
ylim([0 5]);
