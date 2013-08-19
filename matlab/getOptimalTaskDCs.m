function [ dc_i ] = getOptimalTaskDCs(tasks_external,dc_optimal)

tasks = tasks_external;

%% Optimization from algorithm
delta = 0.0001;
dc_remaining = dc_optimal;

% try to assign minimum d.c.
for t = 1:length(tasks);
    if dc_remaining > tasks(t).dmin
        dc_remaining = dc_remaining - tasks(t).dmin;
        tasks(t).dc = tasks(t).dmin;
    end
end


% divy up the rest
while(dc_remaining > 0)
    % find max m.u.
    max_mu = 0;
    for t = 1:length(tasks)
        mu = tasks(t).getMarginalUtil(delta);
        if mu > max_mu
            max_mu = mu;
        end
    end
        
    % how many had the max mu?
    num_max_mu = 0;
    for t = 1:length(tasks)
        mu = tasks(t).getMarginalUtil(delta);
        if mu == max_mu
            num_max_mu = num_max_mu + 1;
        end
    end
    
    dc_requested = num_max_mu*delta;
    if dc_requested > dc_remaining
        dc_requested = dc_remaining;
    end
    
    for t = 1:length(tasks);
        if tasks(t).getMarginalUtil(delta) == max_mu
            tasks(t).dc = tasks(t).dc + dc_requested/num_max_mu;
            dc_remaining = dc_remaining - dc_requested/num_max_mu;
        end
    end
    
    
end

dc_i = [];

for t=1:length(tasks)
    dc_i = [dc_i; tasks(t).dc];
end

end

