function result = tune_roi_base(fitcfun, hyperparams, undersampling_ratio, crossval_partition, data, labels, roi_indicator, opts)
% cvobjfun Optimize hyperparameters via cross-validation
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
NUM_FISH_LABELS = 1:100;

crossval_confusion = zeros(2, 2, crossval_partition.NumTestSets);
crossval_f3= zeros(1, crossval_partition.NumTestSets);
pred_labels = cell(1, crossval_partition.NumTestSets);
roi_confusion = zeros(2, 2, numel(NUM_FISH_LABELS));
roi_f3 = zeros(1, numel(NUM_FISH_LABELS));


if opts.Progress
    progressbar = ProgressBar(crossval_partition.NumTestSets, ...
        'Title', 'Cross validation');
    progressbar.setup([], [], []);
end

% Train models for each fold
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
    pred_labels_tmp = logical(predict(model, cell2mat(data(validation_set))));

    % Split labels back into ROIs
    pred_labels{i} = mat2cell(pred_labels_tmp, ...
        cellfun('length', labels(validation_set)), 1);

    
    if opts.Progress
        progressbar([], [], []);
        clearvars -except MINORITY_LABEL crossval_confusion f3scores fitcfun hyperparams data labels crossval_partition undersampling_ratio progressbar opts roi_indicator NUM_FISH_LABELS pred_labels
    else
        clearvars -except MINORITY_LABEL crossval_confusion f3scores fitcfun hyperparams data labels crossval_partition undersampling_ratio opts roi_indicator NUM_FISH_LABELS pred_labels
    end
end

if opts.Progress
    progressbar.release();
    progressbar = ProgressBar(numel(NUM_FISH_LABELS), ...
        'Title', 'Tuning');
    progressbar.setup([], [], []);
end

for n_labels = NUM_FISH_LABELS

    for i = 1:crossval_partition.NumTestSets
        validation_set = test(crossval_partition, i);
        validation_labels = roi_indicator(validation_set);

        % Group labels by region of interest
        pred_roi_labels = cellfun(@(c) sum(c) >= n_labels, pred_labels{i});

        % Compute cross-validation ROI performance metrics
        crossval_confusion(:, :, i) = confusionmat(validation_labels, ...
            pred_roi_labels);
        [~,~,~,crossval_f3(i)] = analyze_confusion(crossval_confusion(:, :, i));
    end

    roi_confusion(:, :, n_labels) = sum(crossval_confusion, 3);

    crossval_f3(isnan(crossval_f3)) = 0;
    objective(n_labels) = -mean(crossval_f3);

    if opts.Progress
        progressbar([],[],[]);
    end
end

if opts.Progress
    progressbar.release();
end

result.objective = objective;
result.confusion = roi_confusion;
[minf3, minf3idx] = min(result.objective);
result.n_labels = NUM_FISH_LABELS(minf3idx);
result.min_idx = minf3idx;
result.pred_labels = pred_labels;
end

