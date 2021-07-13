function [objective, constraints, userdata] = cvobjfun_roi(fitcfun, hyperparams, undersampling_ratio, crossval_partition, data, labels, roi_indicator, opts)
% cvobjfun_roi Optimize hyperparameters via cross-validation

% SPDX-License-Identifier: BSD-3-Clause
arguments
    fitcfun (1,1) function_handle
    hyperparams
    undersampling_ratio (1,1) double
    crossval_partition (1,1) cvpartition
    data (:,1) cell
    labels (:,1) cell
    roi_indicator (:,1) logical
    opts.Progress (1,1) logical = false
end

MINORITY_LABEL = 0;

crossval_confusion = zeros(2, 2, crossval_partition.NumTestSets);
f3scores = zeros(1, crossval_partition.NumTestSets);

if opts.Progress
    progressbar = ProgressBar(crossval_partition.NumTestSets, ...
        'UpdateRate', inf, 'Title', 'Cross validation');
    progressbar.setup([], [], []);
end

for i = 1:crossval_partition.NumTestSets
    % Get validation and training partitions
    validation_set = test(crossval_partition, i); 
    training_set = training(crossval_partition, i);
    
    training_data = data(training_set);
    training_labels = labels(training_set);

    % Undersample the majority class
    idx_remove = random_undersample(...
        roi_indicator(training_set), MINORITY_LABEL, ...
        'UndersamplingRatio', undersampling_ratio, ...
        'Reproducible', true);
    
    training_data(idx_remove) = [];
    training_labels(idx_remove) = [];

    % Train the model
    model = fitcfun(cell2mat(training_data), ...
        cell2mat(training_labels), hyperparams);

    % Predict labels on the validation set
    pred_labels = logical(predict(model, cell2mat(data(validation_set))));

    % Compute performance metrics
    crossval_confusion(:, :, i) = confusionmat(...
        cell2mat(labels(validation_set)), pred_labels);
    [~, ~, ~, f3scores(i)] = analyze_confusion(crossval_confusion(:, :, i));
    
    if opts.Progress
        progressbar([], [], []);
        clearvars -except MINORITY_LABEL crossval_confusion f3scores fitcfun hyperparams data labels crossval_partition undersampling_ratio progressbar opts roi_indicator
    else
        clearvars -except MINORITY_LABEL crossval_confusion f3scores fitcfun hyperparams data labels crossval_partition undersampling_ratio opts roi_indicator
    end
end

if opts.Progress
    progressbar.release();
end

f3scores_tmp = f3scores;
f3scores_tmp(isnan(f3scores_tmp)) = 0;
objective = -mean(f3scores_tmp);

constraints = [];

userdata.confusion = crossval_confusion;
userdata.f3scores = f3scores;
end
