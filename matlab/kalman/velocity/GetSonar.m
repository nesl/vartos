function h = GetSonar()

persistent sonarAlt
persistent k firstRun

if isempty(firstRun)
    load SonarAlt %.mat file
    k = 1;
    
    firstRun = 1;
end

h = sonarAlt(k);
h = k + 1;