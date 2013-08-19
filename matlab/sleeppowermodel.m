%% Housekeeping
clc; close all; clear all;

%% Tech. params ( 130 / 90 / 65 / 45 nm )
tech_names = {'130nm','90nm','65nm','45nm'};
A_array = [1.0 1.26 1.76 2.52];
B_array = [2605.5 2400 2300 2100];
Igl_array = [0 0.2 0.6 1];
Vdd_array = [1.8 1.8 1.8 1.8];

% select a technology
tech = 2;
A = A_array(tech);
B = B_array(tech);
Igl = Igl_array(tech);
Vdd = Vdd_array(tech);

noise_variance = 10; %uW

%% Play data
T_array = (0:70); %k
for i=1:length(T_array)
    T = T_array(i)+273;
    Ps_array(i) = 0;
    while Ps_array(i) <= 0
        Ps_array(i) = Vdd*(A*T^2*exp(-B/T) + Igl) + ...
            randn()*noise_variance;
    end
end


%% Plot data
scatter(T_array, Ps_array);
hold on;

%% Model attempt #1: true exponential fit
F = @(c,t)1.8*( c(1).*(t+273).*(t+273).*exp(-c(2)./(t+273)) + c(3) );
c0 = [1 2000 0];
[c,resnorm,~,exitflag,output] = lsqcurvefit(F,c0,T_array,Ps_array);

plot(T_array, F(c,T_array),'k','LineWidth',2);

%% Model attempt #2: approximate linearization and least squares
p = polyfit(T_array, log(Ps_array), 1);
plot(T_array, exp(polyval(p,T_array)),':r','LineWidth',2);

%% Plot VaRTOS estimated Ps curve
p = [0.045 2.871];
plot(T_array, exp(polyval(p,T_array)),':c','LineWidth',2);

%% Legend
legend('Data','True Model Fit','Linearized Fit','Sim. fit','Location','NorthWest');
xlabel('Temperature (C)','FontSize',12);
ylabel('Power (uW)','FontSize',12);

%% Testing linearity
%figure();
%scatter(T_array-273,log(Ps_array),'b');
hold on;
T0 = 20+273;
P0 = Vdd*(A*T0^2*exp(-B/T0) + Igl);

P_taylor = zeros(1,length(T_array));

for i = 1:length(T_array);
    T = T_array(i);
    dT = T-T0;
    scalar = ( 2*A*T0*exp(-B/T0) + B*A*exp(-B/T) )/( A*T0^2*exp(-B/T)+Igl );
    P_taylor(i) = P0 + scalar*dT;
    
end

%plot(T_array-273, P_taylor);


%% Testing linearity
%figure();
%scatter(T_array-273,log(Ps_array),'b');
hold on;

P_taylor = zeros(1,length(T_array));
for i = 1:length(T_array);
    T = T_array(i);
    
    sum = 0;
    for k = 0:25
        sum = sum + ((-B/T)^k)/factorial(k);
    end
    
    P_taylor(i) = log( Vdd*(Igl + A*T^2*sum) );
    
end

%plot(T_array-273, P_taylor);


% TAKES k >= 25 before it is a good approx! wow!




