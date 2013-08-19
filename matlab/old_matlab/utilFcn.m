function [ u ] = utilFcn( x )
%UTILFCN Summary of this function goes here
%   Detailed explanation goes here

global Apps;

u = 0;
for i=1:length(Apps)
    thisApp = Apps(i);
    %dUtil = thisApp.priority*2*...
    %    (2./(1 + exp(-thisApp.utilC*x(i))) - 1);
    dUtil = thisApp.priority*log(thisApp.utilC*x(i)+1)/(log(thisApp.utilC+1));
    u = u + dUtil;
end

end

function u=utilVal(App,x)
    u = thisApp.priority*log(thisApp.utilC*x+1)./(log(thisApp.utilC+1));
end