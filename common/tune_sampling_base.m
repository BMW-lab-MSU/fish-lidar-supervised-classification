function tune_sampling_base(fitcfun, data, labels, crossval_partition)

name = functions(fitcfun).function;

% Create the grid
undersampling = 0:0.05:0.95;

GRID_SIZE = numel(undersampling);

% Preallocate data structures for grid search results
result.objective = zeros(1, GRID_SIZE);
result.userdata = cell(1, GRID_SIZE);

% Training
disp([name, ': undersampling grid search'])
for i = progress(1:GRID_SIZE)
    [result.objective(i), ~, result.userdata{i}] = cvobjfun(fitcfun, [], ...
        undersampling(i), crossval_partition, data, labels);
end

% Find the undersampling ratio that resulted in the maximum f3 score
[minf3, minf3idx] = min(result.objective);
result.undersampling_ratio = undersampling(minf3idx);

save(['tune_sampling_' name '.mat'], 'result');