function tune_sampling_base(fitcfun, data, labels, crossval_partition, opts)
arguments
    fitcfun (1,1) function_handle
    data (:,:) single
    labels (:,:) logical
    crossval_partition (1,1) cvpartition
    opts.Progress (1,1) logical = false
    opts.UseParallel (1,1) logical = false
end

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
objective = zeros(1, GRID_SIZE);
userdata = cell(1, GRID_SIZE);

if opts.Progress
    if opts.UseParallel
        progressbar = ProgressBar(GRID_SIZE, 'IsParallel', true);
        progress.setup([],[],[]);
    else
        progressbar = ProgressBar(GRID_SIZE);
    end
end

% Training
disp([name, ': coarse search'])
if opts.UseParallel
    parfor i = 1:GRID_SIZE
        params = struct('undersampling_ratio', under(i), ...
            'oversampling_beta', over(i));

        [objective(i), ~, userdata{i}] = cvobjfun(fitcfun, [], ...
            params, crossval_partition, data, labels);
        
        if opts.Progress
            updateParallel([], pwd);
        end
    end
else
    for i = 1:GRID_SIZE
        params = struct('undersampling_ratio', under(i), ...
            'oversampling_beta', over(i));

        [objective(i), ~, userdata{i}] = cvobjfun(fitcfun, [], ...
            params, crossval_partition, data, labels);

        if opts.Progress
            progressbar([], [], []);
        end
    end
end
[minf3, minf3idx] = min(result.objective);
result.undersampling_ratio = under(minf3idx);
result.oversampling_beta = over(minf3idx);
result.objective = objective;
result.userdata = userdata;

if opts.Progress
    progressbar.release();
end

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
objective = zeros(1, GRID_SIZE);
userdata = cell(1, GRID_SIZE);

if opts.Progress
    if opts.UseParallel
        progressbar = ProgressBar(GRID_SIZE, 'IsParallel', true);
        progressbar.setup([],[],[]);
    else
        progressbar = ProgressBar(GRID_SIZE);
    end
end

% Training
disp([name, ': fine search'])
if opts.UseParallel
    parfor i = 1:GRID_SIZE
        params = struct('undersampling_ratio', under(i), ...
            'oversampling_beta', over(i));

        [objective(i), ~, userdata{i}] = cvobjfun(fitcfun, [], ...
            params, crossval_partition, data, labels);
        
        if opts.Progress
            updateParallel([], pwd);
        end
    end
else
    for i = 1:GRID_SIZE
        params = struct('undersampling_ratio', under(i), ...
            'oversampling_beta', over(i));

        [objective(i), ~, userdata{i}] = cvobjfun(fitcfun, [], ...
            params, crossval_partition, data, labels);

        if opts.Progress
            progressbar([], [], []);
        end
    end
end
[minf3, minf3idx] = min(result.objective);
result.undersampling_ratio = under(minf3idx);
result.oversampling_beta = over(minf3idx);
result.objective = objective;
result.userdata = userdata;

if opts.Progress
    progressbar.release();
end

save(['tune_sampling_fine_' name '.mat'], 'result');