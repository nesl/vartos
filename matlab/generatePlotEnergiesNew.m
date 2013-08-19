%%
clc;

locations = {'Mauna_Loa', 'Sioux_Fall','Stovepipe'};
instances = {'bc','nc','wc'};
% Battery capacities
AA_2 = 2*2.7*1.5*3600
AA_1 = 2.7*1.5*3600
AAA_2 = 2*1.2*1.5*3600
AAA_1 = 1*1.2*1.5*3600
AAAA_2 = 2*0.625*1.5*3600
CR2032_1 = 1*0.225*3*3600

energies = [
duty_cycles = [0.002 0.005 0.01 0.05 0.1];

fid = fopen('energy_matrix.h','w');
fprintf(fid, '#ifndef _ENERGY_MATRIX_H_\n');
fprintf(fid, '#define _ENERGY_MATRIX_H_\n');

fprintf(fid,'const char energy_matrix[%d][%d][%d] = {',length(instances),...
    length(locations),length(duty_cycles));


for i = 1:(length(instances)-1)
    inst = instances{i};
    disp(inst);
    fprintf(fid,'\n\n{');
    
    for j = 1:(length(locations)-1)
        loc = locations{j};
        disp(loc);
        fprintf(fid,'\n{');
        for k = 1:(length(duty_cycles)-1)
            dc = duty_cycles(k);
            E = dcToEnergy(dc, loc, ['pm/' inst]);
            fprintf(fid,'%d,',round(E));
        end
        % last one
        dc = duty_cycles(end);
        E = dcToEnergy(dc, loc, ['pm/' inst]);
        fprintf(fid,'%d',round(E));
        fprintf(fid,'},');
    end
    % last one
    loc = locations{end};
    disp(loc);
    fprintf(fid,'\n{');
    for k = 1:(length(duty_cycles)-1)
        dc = duty_cycles(k);
        E = dcToEnergy(dc, loc, ['pm/' inst]);
        fprintf(fid,'%d,',round(E));
    end
    % last one
    dc = duty_cycles(end);
    E = dcToEnergy(dc, loc, ['pm/' inst]);
    fprintf(fid,'%d',round(E));
    fprintf(fid,'}');
    
    fprintf(fid,'\n},');
end
% last one
inst = instances{end};
disp(inst);
fprintf(fid,'\n\n{');

for j = 1:(length(locations)-1)
    loc = locations{j};
    disp(loc);
    fprintf(fid,'\n{');
    for k = 1:(length(duty_cycles)-1)
        dc = duty_cycles(k);
        E = dcToEnergy(dc, loc, ['pm/' inst]);
        fprintf(fid,'%d,',round(E));
    end
    % last one
    dc = duty_cycles(end);
    E = dcToEnergy(dc, loc, ['pm/' inst]);
    fprintf(fid,'%d',round(E));
    fprintf(fid,'},');
end
% last one
loc = locations{end};
disp(loc);
fprintf(fid,'\n{');
for k = 1:(length(duty_cycles)-1)
    dc = duty_cycles(k);
    E = dcToEnergy(dc, loc, ['pm/' inst]);
    fprintf(fid,'%d,',round(E));
end
% last one
dc = duty_cycles(end);
E = dcToEnergy(dc, loc, ['pm/' inst]);
fprintf(fid,'%d',round(E));
fprintf(fid,'}');

fprintf(fid,'\n}');



fprintf(fid,'\n};\n');
fprintf(fid, '#endif //_ENERGY_MATRIX_H_\n');


fclose(fid);