function [ means, maxs, mins, stds ] = statsNoInf( m_in )

means = zeros(1,size(m_in,2));
stds = zeros(1,size(m_in,2));
maxs = zeros(1,size(m_in,2));
mins = zeros(1,size(m_in,2));

for i=1:size(m_in,2)
    idx = 1;
    col = m_in(:,i);
    temp = zeros(1,length(col));
    for j=1:length(col)
        if ~isnan(col(j)) && ~isinf(col(j)) && col(j) < 100
            temp(idx) = col(j);
            idx = idx + 1;
        end
    end

    means(i) = mean(temp(1:(idx-1)));
    stds(i) = std(temp(1:(idx-1)));
    maxs(i) = max(temp(1:(idx-1)));
    mins(i) = min(temp(1:(idx-1)));
end

end

