function [z_noise, z_real, v_real] = GetPos(idx)

global dt

persistent Posp

if isempty(Posp)
    Posp = 0;
end

v = 0 + 50*randn;

z_noise = 555*sin(0.1*dt*idx) + v;
z_real = z_noise - v;
v_real = (z_real-Posp)/dt;
Posp = z_real;