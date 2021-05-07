function [objective, constraints, userdata] = cvobjfun(fitcfun, hyperparams, undersampling_ratio, crossval_partition, data, labels)
% bayesobjfun Optimize hyperparameters
    MINORITY_LABEL = 0;
    N_NEIGHBORS = 5;

    % trained_models = cell(1, crossval_partition.NumTestSets);
    crossval_confusion = zeros(2, 2, crossval_partition.NumTestSets);
    f3scores = zeros(1, crossval_partition.NumTestSets);

    for i = 1:crossval_partition.NumTestSets
        % Get validation and training partitions; transpose the data and labels
        % because our observations are in columns, but everybody else wants them
        % in rows.
        validation_set = test(crossval_partition, i); 
        training_set = training(crossval_partition, i);

        % Undersample the majority class
        idx_remove = random_undersample(...
            labels(training_set), MINORITY_LABEL, ...
            'UndersamplingRatio', undersampling_ratio);
        
        training_set(idx_remove) = [];

        % Train the model
        trained_model = fitcfun(data(training_set, :), labels(training_set), ...
            hyperparams);

        % Predict labels on the validation set
        pred_labels = logical(predict(trained_model, data(validation_set, :)));

        % Compute performance metrics
        crossval_confusion(:, :, i) = confusionmat(labels(validation_set), ...
            pred_labels);
        [~, ~, ~, f3scores(i)] = analyze_confusion(crossval_confusion(:, :, i));
        
        clearvars -except MINORITY_LABEL N_NEIGHBORS crossval_confusion f3scores fitcfun hyperparams data labels crossval_partition undersampling_ratio
    end
    
    objective = -mean(f3scores);

    constraints = [];

    % userdata.trained_models = trained_models;
    userdata.confusion = crossval_confusion;
    userdata.f3scores = f3scores;
end
