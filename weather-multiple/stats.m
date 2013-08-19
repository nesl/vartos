f=load('estimation_error');
# 1-ntrain, 2-observedP, 3-err3, 4-err5, 5-err10, 6-err100

mus = zeros(7,4);
sig = zeros(7,4);
amus = zeros(7,4);
asig = zeros(7,4);
ncdf = zeros(7,4);
err_threshold = 3

for i = 2:8, # n-train
	idx = find(f(:,1)==i);
	sel = f(idx,:);
	for j = 3:6 # err-N
        amus(i-1, j-2) = mean(abs(sel(:,j))./sel(:,2))*100;
        asig(i-1, j-2) = std(abs(sel(:,j))./sel(:,2))*100;
        mus(i-1, j-2) = mean(sel(:,j)./sel(:,2))*100;
        sig(i-1, j-2) = std(sel(:,j)./sel(:,2))*100;
        ancdf(i-1, j-2) = normcdf(err_threshold, amus(i-1, j-2), asig(i-1, j-2) );
        ncdf(i-1, j-2) = normcdf(err_threshold, -mus(i-1, j-2), sig(i-1, j-2) );
	end
end

plot(ncdf)

abs_results = [[2:8]', amus, asig];
results = [[2:8]', mus, sig];
