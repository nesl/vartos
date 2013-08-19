function [ u ] = utilFcnEquiv( x )
%UTILFCN Summary of this function goes here
%   Detailed explanation goes here

global Apps;

utils = [];

for a = 1:length(Apps)
    dmin = Apps(a).dmin;
    dgood = Apps(a).dgood;
    dbest = Apps(a).dbest;
    priority = Apps(a).priority;
    
    % initial condition--last value must be 1
    %{
    if x(a) < dgood
        slope = 0.90*priority/(dgood-dmin);
        anchor = dgood;
        anchorVal = priority*0.90;
    elseif x(a) < dbest
        slope = (1.0-0.90)*priority/(dbest-dgood);
        anchor = dbest;
        anchorVal = priority;
    else
        anchor = 1;
        achorVal = priority;
        slope = 0;
    end
    
    val = anchorVal-slope*(anchor-x(a));
    
    utils(a) = val;
    %}
    %if x(a) < 1
        utils = [utils x(a)];
    %end
end
u = sum(utils);

end