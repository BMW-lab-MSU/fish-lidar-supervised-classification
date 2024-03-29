function result = tune_sampling_roi_base(fitcfun, data, labels, roi_indicator, crossval_partition, opts)
% Tune the undersampling ratio via cross-validation

% SPDX-License-Identifier: BSD-3-Clause
arguments
    fitcfun (1,1) function_handle
    data (:,1) cell
    labels (:,1) cell
    roi_indicator (:,1) logical
    crossval_partition (1,1) cvpartition
    opts.Progress (1,1) logical = false
    opts.UseParallel (1,1) logical = false
    opts.NumThreads (1,1) int8 = 1
end

name = functions(fitcfun).function;

% Create the grid
undersampling = 0:0.05:0.95;

GRID_SIZE = numel(undersampling);

% Preallocate data structures for grid search results
objective = zeros(1, GRID_SIZE);
userdata = cell(1, GRID_SIZE);

if opts.Progress
    if opts.UseParallel
        progressbar = ProgressBar(GRID_SIZE, ...
            'IsParallel', true, 'WorkerDirectory', pwd(), ...
            'Title', 'Grid search');
    else
        progressbar = ProgressBar(GRID_SIZE, 'Title', 'Grid search');
    end
end

% Training
disp([name, ': undersampling grid search'])

if opts.Progress
    progressbar.setup([],[],[]);
end

if opts.UseParallel
    parfor i = 1:GRID_SIZE
        maxNumCompThreads(opts.NumThreads);

        [objective(i), ~, userdata{i}] = cvobjfun_roi(fitcfun, [], ...
            undersampling(i), crossval_partition, data, labels, roi_indicator);
        
        if opts.Progress
            updateParallel([], pwd);
        end
    end
else
    for i = 1:GRID_SIZE
        [objective(i), ~, userdata{i}] = cvobjfun_roi(fitcfun, [], ...
            undersampling(i), crossval_partition, data, labels, ...
            roi_indicator, 'Progress', opts.Progress);

        if opts.Progress
            progressbar([], [], []);
        end
    end
end

if opts.Progress
    progressbar.release();
end

% Find the undersampling ratio that resulted in the maximum f3 score
result.objective = objective;
result.userdata = userdata;
[minf3, minf3idx] = min(result.objective);
result.undersampling_ratio = undersampling(minf3idx);