%% Housekeeping
clc; close all; clear all;

% offset: 2.306696e4
% slope: 1.4352e2
% kmin: 1
% kmax: 60000

wf_wc = '../weather-multiple/data/CA_Stovepipe_Wells_1_S-2011';
wf_nc = '../weather-multiple/data/SD_Sioux_Falls_14_NN-2011';
wf_bc = '../weather-multiple/data/HI_Mauna_Loa_5_NN-2011';
wf = {wf_bc wf_nc wf_wc};

pf_wc = 'pm/wc';
pf_nc = 'pm/nc';
pf_bc = 'pm/bc';
pf = {pf_bc pf_nc pf_wc};

%% Load data
%load('app1_oracle2.mat');
%oracle = app1_oracle;
vartos_dc = zeros(3,3); % inst/temp
vartos_dc(:,1) = [0.4514 0.4506 0.4377];
vartos_dc(:,2) = [0.3905 0.3881 0.3566];
vartos_dc(:,3) = [0.2067 0.1987 0.0951];

vartos_err = zeros(3,3);
vartos_err(1,:) = [
  -0.680555555555575
  -0.707561728395081
  -0.540123456790138
  ];
vartos_err(2,:) = [
  -0.760030864197545
  -0.814043209876557
  -1.079475308641987
  ];
vartos_err(3,:) = [
  -1.033950617283965
  -1.233024691358033
  -3.090277777777792
  ];

vartos_err = vartos_err'/100;

%duty_cycle_errors = 100*(oracle(:,:,2) - vartos_dc)./oracle(:,:,2);



% construct vartos knob array
vartos_k = zeros(3,3);
kmin = 1;
kmax = 60000;
pi = 1;
offset = 2.306696e4; % in cycles
slope = 1.4352e2; % in cycles
freq = 8;

task = VartosTask('sensor', kmin, kmax, pi, offset, slope, freq);

%for i=1:3
%    for j=1:3
%        vartos_k(i,j) = task.DCtoKnob(vartos_dc(i,j));
%    end
%end

oracle = zeros(3,3);
for inst = 1:3
    for loc = 1:3
        oracle(loc,inst) = energyFileToDC(12960,...
            wf{loc}, pf{inst}, 10000, 0);
    end
end

%knob_errors = 100*(oracle(:,:,1) - vartos_k)./oracle(:,:,1);

util_oracle = zeros(3,3);
util_vartos = zeros(3,3);


for i=1:3
    for j=1:3
        util_oracle(i,j) = task.dcToUtil(oracle(i,j));
        util_vartos(i,j) = task.dcToUtil(vartos_dc(i,j));
        
        % scale vartos util
        %util_vartos(i,j) = util_vartos(i,j)*(1-vartos_err(i,j));
    end
end

bars_oracle= [util_oracle(:,1);util_oracle(:,2);util_oracle(:,3)];
bars_vartos= [util_vartos(:,1);util_vartos(:,2);util_vartos(:,3)];

util_errors = 100*(util_oracle - util_vartos)./util_oracle;


%% Plot this like there's no tomorrow
close all;
cfigure(14,8);
h = bar(1:9,[bars_oracle bars_vartos]);
set(h(1),'facecolor',[1 0.5 0.5]);
set(h(2),'facecolor',[0 0 1]);
set(gca,'XTickLabel',{'B/B', 'B/N', 'B/W',...
    'N/B','N/N','N/W','W/B','W/N','W/W'})
ylabel('Total Utility (a.u.)','FontSize',12);
xlabel('Instance and Temperature Profile (Inst/Temp)','FontSize',12);
legend('Oracle','VaRTOS','Location','NorthEast');
grid on;

%saveplot('../tecs/figures/app1_oracle');



























