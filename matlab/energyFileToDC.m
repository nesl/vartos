
function [ DC ] = energyFileToDC( E, temp_file, vemu_file, num_bins, approx_bool )

%% Variables
%V * A * sec * min * hour * days
% days * hours * mins * seconds
L = 365 * 24 * 60 * 60;
L = 30326665;

%% Load Temp. Profile
temp_data = csvread(temp_file);

[temp_hist,bin_centers] = hist(temp_data,num_bins);
% scale temp_hist to 50% =  1 byte like VaRTOS does
temp_hist = 2*255*(temp_hist./length(temp_data));
temp_hist = round(temp_hist);
bin_width = bin_centers(2)-bin_centers(1);
start_temp = round(bin_centers(1));

%% Load VarEMU data
sleep_variance = 0*1e3*10; %nW
active_variance = 0*1e3*10; %nW

data = csvread(vemu_file);
N = length(data(:,1));
T_array = data(:,1);
Ps_array = data(:,2)*1e9 + randn(N,1)*sleep_variance; % to nW
Pa_array = data(:,3)*1e9 + randn(N,1)*active_variance; % to nW

%% Model sleep power: approximate linearization and least squares
p_s = polyfit(T_array, log(Ps_array), 1);
%p_s = [0.0199 12.252];
p_s_full = polyfit(T_array, Ps_array, 6);
Ps_linear = exp(polyval(p_s,T_array));

%% Model active power: linear addition to sleep power
p_a = polyfit(T_array, Pa_array-Ps_linear, 1);
p_a_full = polyfit(T_array, Pa_array, 6);
%p_a = [0 8.57e5];

%% Calculate the lifetime that gives dcOpt as per lucas' equations in the
% earlier paper

sum1 = 0;
sum2 = 0;
for i=1:length(temp_hist)
    temp = start_temp + (i-1)*bin_width;
    freq = 0.5*(temp_hist(i)/255.0);
    if approx_bool
        ps = exp(polyval(p_s,temp));
        pa = polyval(p_a,temp);
    else
        ps = polyval(p_s_full,temp);
        pa = polyval(p_a_full,temp);
    end
    sum1 = sum1 + 1e-9*ps*freq;
    sum2 = sum2 + 1e-9*(pa)*freq;
end
%sum1*10000
%sum2*10000

DC = ((E/L) - sum1)/sum2;

end

