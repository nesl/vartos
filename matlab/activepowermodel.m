%% Housekeeping
clc; clear all; close all;

%% Tech. params ( 130 / 90 / 65 / 45 nm )
tech_name_array = {'130nm','90nm','65nm','45nm'};
% dynamic
k1_array = [0.0511 0.0246 0.0094 0.0046];
k2_array = [0.0095 0.0046 0.00175 0.000855];
k3_array = [0.00325 0.0016 0.000615 0.0003];
a_array = [0.669 0.71 0.735 0.755];
b_array = [1.3456 1.5228 1.6335 1.722];
Pt1_array = [7.7 2.82 0.9 0.364];
Pt2_array = [8.6 3.33 1.125 0.479];
Pt3_array = [8.68 3.37 1.14 0.4867];
T1_array = [-50 -50 -50 -50];
T2_array = [21 21 21 21];
T3_array = [30 30 3 30];
% sleep
A_array = [1.0 1.26 1.76 2.52];
B_array = [2605.5 2400 2300 2100];
Igl_array = [0 0.2 0.6 1];
Vdd_array = [1.8 1.8 1.8 1.8];

% select a technology
tech = 1;
tech_name = tech_name_array{tech};
% active
k1 = k1_array(tech);
k2 = k2_array(tech);
k3 = k3_array(tech);
a = a_array(tech);
b = b_array(tech);
Pt1 = Pt1_array(tech);
Pt2 = Pt2_array(tech);
Pt3 = Pt3_array(tech);
T1 = T1_array(tech);
T2 = T2_array(tech);
T3 = T3_array(tech);
% sleep
A = A_array(tech);
B = B_array(tech);
Igl = Igl_array(tech);
Vdd = Vdd_array(tech);



%% Play data
T_array = (0:70); %k
sleep_variance = 0*10; %uW
active_variance = 0*20e-3; %mW

%% sleep power curve
Ps_array = zeros(1,length(T_array));
for i=1:length(T_array)
    T = T_array(i)+273;
    Ps_array(i) = 0;
    while Ps_array(i) <= 0
        Ps_array(i) = Vdd*(A*T^2*exp(-B/T) + Igl) + ...
            randn()*sleep_variance;
    end
end

%% active power curve (containing sleep power)
Pa_array = zeros(1,length(T_array));
for i=1:length(T_array)
    T = T_array(i)+273;
    Pa_array(i) = 0;
    while Pa_array(i) <= 0
        if T <= T2+273
            Pa_array(i) = Pt1 + k1*(T-T1-273)^a + randn()*active_variance;
        elseif T > T2+273 && T < T3+273
            Pa_array(i) = Pt2 + k2*(T-T2-273) + randn()*active_variance;
        elseif T >= T3+273
            Pa_array(i) = Pt3 + k3*(T-T3-273)^b + randn()*active_variance;
        else
            disp('ERROR!');
        end
        
    end
end


%% Plot sleep data
cfigure(35,15);
subplot(1,2,1);
scatter(T_array, Ps_array);


%% Plot active data
subplot(1,2,2);
scatter(T_array, Pa_array);

%% Model sleep and active with accurate models
% model sleep
F = @(c,t)1.8*( c(1).*(t+273).*(t+273).*exp(-c(2)./(t+273)) + c(3) );
c0 = [1 2000 0];
[c,resnorm,~,exitflag,output] = lsqcurvefit(F,c0,T_array,Ps_array);

subplot(1,2,1);
hold on;
plot(T_array, F(c,T_array),'k','LineWidth',2);

% model active

% nonlinear regime 1
temps1 = T_array(find(T_array <= T2));
data1 = Pa_array(find(T_array <= T2));
F1 = @(c,t)( c(1) + c(2)*(t-T1).^c(3) );
c0 = [0 0 0];
[c_r1,resnorm,~,exitflag,output] = lsqcurvefit(F1,c0,temps1,data1);

% linear regime 2
temps2 = T_array(find(T_array < T3 & T_array > T2));
data2 = Pa_array(find(T_array < T3 & T_array > T2));
F2 = @(c,t)( c(1) + c(2)*(t-T2) );
c0 = [0 0];
[c_r2,resnorm,~,exitflag,output] = lsqcurvefit(F2,c0,temps2,data2);

% nonlinear regime 3
temps3 = T_array(find(T_array >= T3));
data3 = Pa_array(find(T_array >= T3));
F3 = @(c,t)( c(1) + c(2)*(t-T3).^c(3) );
c0 = [0 0 1];
[c_r3,resnorm,~,exitflag,output] = lsqcurvefit(F3,c0,temps3,data3);

subplot(1,2,2);
hold on;
plot(T_array, [F1(c_r1,temps1) F2(c_r2,temps2) F3(c_r3,temps3)]);

%% Model sleep power: approximate linearization and least squares
p = polyfit(T_array, log(Ps_array), 1);
subplot(1,2,1);
Ps_linear = exp(polyval(p,T_array));
plot(T_array, Ps_linear,':r','LineWidth',2);
legend('Data','True Model Fit','Linearized Fit','Location','NorthWest');
xlabel('Temperature (C)','FontSize',12);
ylabel('Power (uW)','FontSize',12);

%% Model active power: linear addition to sleep power
subplot(1,2,2);
p = polyfit(T_array, Pa_array-1e-3*Ps_linear, 1);
plot(T_array, 1e-3*Ps_linear+polyval(p,T_array),'.-k');

p = polyfit(T_array, Pa_array, 1);
plot(T_array, polyval(p,T_array),'^-m');

%% Legend
legend('Data','True Model Fit','Linearized Fit','Location','NorthWest');
xlabel('Temperature (C)','FontSize',12);
ylabel('Power (mW)','FontSize',12);



%% Testing linearity
%figure();
%scatter(T_array-273,log(Ps_array),'b');
hold on;
T0 = 20;
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




