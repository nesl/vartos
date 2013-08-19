function [ error_pos, error_vel ] = getDvKalmanError( times, pos_data, vel_data, offset )

pos_real = 555*sin(0.1*(times));
vel_real = 555*0.1*cos(0.1*(times+offset));

error_pos = sqrt(mean((pos_data - pos_real).^2));
error_vel = sqrt(mean((vel_data - vel_real).^2));


 close all;
%  
%  plot(times,vel_data);
%  hold on;
%  plot(times,vel_real,'r');
%  xlim([0 300]);
%  
%  pause();




end

