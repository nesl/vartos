function [ E ] = dcToEnergy( dcopt, temp_desc, vemu_file )

%% Variables
%V * A * sec * min * hour * days
E = 0; %?
% days * hours * mins * seconds
L = 365 * 24 * 60 * 60;

%% Load Temp. Profile
num_bins = 5;
descriptor = temp_desc;
temp_path = '../weather-multiple/data/';
potential_files = dir(temp_path);
good_file = [];

for i = 1:length(potential_files)
    str = potential_files(i).name;
    match_str = ['.*' descriptor '.*2011.*'];
    if ~isempty(regexp(str,match_str,'match'))
        good_file = str;
    end
end

%disp('Loading temperature profile from:');
%disp(good_file);
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

data = csvread(vemu_file);
N = length(data(:,1));
T_array = data(:,1);
Ps_array = data(:,2)*1e9+randn(N,1)*sleep_variance; % to nW
Pa_array = data(:,3)*1e9+randn(N,1)*active_variance; % to nW

%% Model sleep power: approximate linearization and least squares
p_s = polyfit(T_array, log(Ps_array), 1);
%p_s = [0.01947 11.728];
Ps_linear = exp(polyval(p_s,T_array));

%% Model active power: linear addition to sleep power
p_a = polyfit(T_array, Pa_array-Ps_linear, 1);
%p_a = [-0.00112 7.51653440e5];

%% Calculate the lifetime that gives dcOpt as per lucas' equations in the
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

E = L*( dcopt*sum2 + sum1 );

end

