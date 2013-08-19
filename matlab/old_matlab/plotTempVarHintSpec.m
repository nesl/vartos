%% Housekeeping
clc; close all;

%% Load the Temp Files
cd temps;
files=sortrows(ls);
files = strread(files, '%s', 'delimiter', sprintf('\n'));
cd ..;

% calculate temp statistics
tempStats = [];
for i = 1:length(files)
    f = load(['temps/' files{i}]);
    tempStats(i,:) = [median(f), mean(f), mode(f), max(f), min(f)];
end

%% Get average temp profile for "Hint"
averageTemps = zeros(1,length(f));
for i = 1:length(files)
    % load the file
    f = load(['temps/' files{i}]);
    % loop through every hour, trying to calculate mean
    for j = 1:length(f)
        averageTemps(j) = averageTemps(j) + f(j)/length(files);
    end
end
%%
plot(1:365,averageTemps(1:24:end),'LineWidth',2)
xlabel('Day','FontSize',12);
ylabel('Temperature (\circC)','FontSize',12);
saveplot('../figs/averageTempProfile');

%% Start with this "Hint" and some weight. you can look
% at the weight as representing how many days before the
% deployment we were collecting this fake average data.
% an alpha of 1 would be a whole year before, because
% we are only taking a 1 year window
alpha = 1.00;
avg_hours = round(365*24*alpha);


%% Error of converging temperature across all
errors = zeros(2,length(f));
% min; max; mean x length(f)

for i = 1:length(files)
    disp(i/length(files));
    % load the file
    f = load(['temps/' files{i}]);
    temp_avg = mean(f);
    % loop through every hour, trying to calculate mean
    for j = 1:length(f)
        % determine data to run average over
        to_avg = [ones(1,avg_hours)*temp_avg f(1:j)'];
        % take at most the last 365 of these^
        if(length(to_avg) > 365*24)
            to_avg = to_avg(length(to_avg)-365*24+1:end);
        end
        runningAvg = mean(to_avg);
        thisErr = abs(runningAvg-mean(f));
        % max?
        if thisErr > errors(1,j)
            errors(1,j) = thisErr;
        end
        % update mean
        errors(2,j) = errors(2,j) + thisErr/(365*1);
    end
end

%% Plot em
plot((1:length(f))./24,errors,'LineWidth',2)
xlim([0 365]);
xlabel('System On-time (days)','FontSize',12);
ylabel('Error (\circK)','FontSize',12);
title('Averaging Temperature','FontSize',12);
legend('Max','Mean','Location','NorthEast');
grid on;
ylim([0 25]);
saveplot('../figs/runningAvgTempErrorBoundsHintSpecAlpha100');
