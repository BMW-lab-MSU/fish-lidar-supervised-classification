function tune_sampling_base(fitcfun, data, labels, crossval_partition)

name = functions(fitcfun).function;

%% Coarse grid search to determine general search area
undersampling = 0:0.2:0.8;
oversampling = 0:0.25:1;

% Create the grid
[under, over] = ndgrid(undersampling, oversampling);
under = reshape(under, 1, numel(under));
over = reshape(over, 1, numel(over));

GRID_SIZE = numel(under);

% Preallocate data structures for grid search results
result.objective = zeros(1, GRID_SIZE);
result.userdata = cell(1, GRID_SIZE);

% Training
disp([name, ': coarse search'])
for i = progress(1:GRID_SIZE)
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [result.objective(i), ~, result.userdata{i}] = cvobjfun(fitcfun, [], ...
        params, crossval_partition, data, labels);
end
[minf3, minf3idx] = min(result.objective);
result.undersampling_ratio = under(minf3idx);
result.oversampling_beta = over(minf3idx);

save(['tune_sampling_coarse_' name '.mat'], 'result');


%% Fine grid search
% We search around the coarse results using 0.05 increments of the coarse.
% When the coarse results were 0, we search between [0, 0.2].
% Each search parameter has five uniformly-spaced search values.

if result.undersampling_ratio == 0
    undersampling = linspace(0, 0.2, 5);
else
    undersampling = linspace(result.undersampling_ratio - 0.1, ...
        result.undersampling_ratio + 0.1, 5);
end

if result.oversampling_beta == 0
    oversampling = linspace(0, 0.2, 5);
else
    oversampling = linspace(result.oversampling_beta - 0.1, ...
        result.oversampling_beta + 0.1, 5);
end

[under, over] = ndgrid(undersampling, oversampling);
under = reshape(under, 1, numel(under));
over = reshape(over, 1, numel(over));

GRID_SIZE = numel(under);

% Preallocate data structures for grid search results
result.objective = zeros(1, GRID_SIZE);
result.userdata = cell(1, GRID_SIZE);


% Training
disp([name, ': fine search'])
for i = progress(1:GRID_SIZE)
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [result.objective(i), ~, result.userdata{i}] = cvobjfun(fitcfun, [], ...
        params, crossval_partition, data, labels);
end
[minf3, minf3idx] = min(result.objective);
result.undersampling_ratio = under(minf3idx);
result.oversampling_beta = over(minf3idx);

save(['tune_sampling_fine_' name '.mat'], 'result');