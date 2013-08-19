function x=maxAlloc_cvx(total_resources,N,utility_hook,mins)
% USAGE: assignments = maxAlloc_cvx( total_resources, N, utility_hooks, dcmins)
% 
% where total_resources is the total amount to be allocated, utility_hook
% is the function handle of the N users, and mins are the minimum
% allowable resource allocations to those users

cvx_quiet(true)
cvx_clear
cvx_begin
    variable x(N) 
    maximize (utility_hook(x))
    subject to
        x > mins;
        sum(x) < total_resources;
cvx_end
