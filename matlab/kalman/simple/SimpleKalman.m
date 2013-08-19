function [ volt ] = SimpleKalman( z )

persistent A H Q R F
persistent x P
persistent firstRun

if isempty(firstRun)
    A = 0.5;
    H = 1;
    Q = 2;
    R = 2;
    x = 0;
    P = 6;
    F = 0.5;
    
    firstRun = 1;
end

xp = A*x;
Pp = A*P*A' + Q;
K = Pp*H'*inv(H*Pp*H' + R);

x = xp + K*(z - H*xp);
p = Pp - K*H*Pp;

volt = x;


end

