function [ z ] = GetVolt(  )
global z
persistent A H Q R F
persistent x P
persistent firstRun
persistent iter

if isempty(firstRun)
    A = 0.5;
    H = 1;
    Q = 1;
    R = 4;
    x = 0;
    P = 6;
    F = 0.5;
    z = 0;
    iter = 0;
    
    firstRun = 1;
end

zp = A*z;
w = 0 + 0.5*randn + 2*rectangularPulse(1,30,iter) + 4*rectangularPulse(60,90,iter) +...
    -3*rectangularPulse(180,220,iter);
z = zp + w;
iter = iter + 1;

end

