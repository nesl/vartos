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

%% How long would it take to converge?
for i = 30:30
    % load the file
    f = load(['temps/' files{i}]);
    avg_array = zeros(1,length(f));
    % loop through every hour, trying to calculate mean
    for j = 1:length(f)
        runningAvg = mean(f(1:j));
        avg_array(j) = runningAvg;
    end
end

plot((1:length(f))./24,avg_array,'m')
hold on;
plot([1 length(f)]./24,[mean(f) mean(f)],'b');
xlim([0 365]);
xlabel('Day of the Year','FontSize',12);
ylabel('Average Temperature','FontSize',12);
legend('Running Average','Year-long Average','Location','SouthEast');
title('Averaging Temperature','FontSize',12);
grid on;
%saveplot('../figs/runningAvgTemp');

%% Error of converging temperature across all
errors = zeros(2,length(f));
% min; max; mean x length(f)

for startday = 1:1
    fprintf('%d / 365\n',startday);
    for i = 1:length(files)
        % load the file
        f = load(['temps/' files{i}]);
        % reconstruct f based on startday
        f = [f(startday:end); f(1:startday-1)];
        % loop through every hour, trying to calculate mean
        for j = 1:length(f)
            runningAvg = mean(f(1:j));
            thisErr = abs(runningAvg-mean(f));
            % max?
            if thisErr > errors(1,j)
                errors(1,j) = thisErr;
            end
            % update mean
            errors(2,j) = errors(2,j) + thisErr/(365*1);
        end
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
saveplot('../figs/runningAvgTempErrorBounds');

%% is there a correlation between variance of a day and variance over a year?
varArray = zeros(2,length(files)*365);

for i = 1:length(files)
    % load the file
    f = load(['temps/' files{i}]);
    avg_array = zeros(1,length(f));
    % loop through every hour, trying to calculate mean
    for j = 1:(length(f)/24)
        varArray(1,j+24*(i-1)) = var(f);    
        varArray(2,j+24*(i-1)) = var(f((24*(j-1)+1):24*j));
    end
end

scatter(varArray(2,:),varArray(1,:),'or');
xlabel('Variance (1 day)','FontSize',12);
ylabel('Variance (1 year)', 'FontSize',12);
title('Predicting Variance','FontSize',12);
grid on;