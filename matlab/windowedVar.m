function [ output ] = windowedVar( array, window )
output = zeros(1,length(array)/window);

output_idx = 1;

for i=1:window:length(array)
    
    if i+window > length(array)
        output(output_idx) = var(array(i:end));
    else
        output(output_idx) = var(array(i:(i+window)));
    end
    
    output_idx = output_idx +1;
end


end

