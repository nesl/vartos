function [pos vel] = DvKalman(z)

global dt

persistent A H Q R
persistent x P
persistent firstRun

if isempty(firstRun)
    firstRun = 1;
    
    
    A = [1 dt; 0 1];
    H = [1 0];
    Q = [1 0; 0 3];
    R = 2500;
    
    x = [0 0]';
    P = 5*eye(2);
end

%{
xp = A*x;
Pp = A*P*A' + Q;

K = Pp*H'*inv(H*Pp*H' + R);

x = xp + K*(z-H*xp);
P = Pp - K*H*Pp;

pos = x(1);
vel = x(2);

%}


% xp = A*x
xp(1) = A(1,1)*x(1) + A(1,2)*x(2);
xp(2) = A(2,1)*x(1) + A(2,2)*x(2);

% Pp = A*P*A' + Q
Pp(1,1) = P(1,1) + dt*P(2,1) + dt*P(1,2) + dt*dt*P(2,2) + Q(1,1);
Pp(1,2) = P(1,2) + dt*P(2,2);
Pp(2,1) = P(2,1) + dt*P(2,2);
Pp(2,2) = P(2,2) + Q(2,2);

% K = Pp*H'*inv(H*Pp*H' + R)
temp = Pp(1,1) + R;
K(1) = Pp(1,1)*(1/temp);
K(2) = Pp(2,1)*(1/temp);

x(1) = xp(1) + K(1)*(z-xp(1));
x(2) = xp(2) + K(2)*(z-xp(1));

P(1,1) = Pp(1,1) - K(1)*Pp(1,1);
P(1,2) = Pp(1,2) - K(1)*Pp(1,2);
P(2,1) = Pp(2,1) - K(2)*Pp(1,1);
P(2,2) = Pp(2,2) - K(2)*Pp(1,2);

pos = x(1);
vel = x(2);

















