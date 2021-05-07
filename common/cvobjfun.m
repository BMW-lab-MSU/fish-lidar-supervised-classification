function [objective, constraints, userdata] = cvobjfun(fitcfun, hyperparams, sampling_params, crossval_partition, data, labels, knn_index_full, knn_index_minority)
% bayesobjfun Optimize hyperparameters
    MINORITY_LABEL = 0;
    NUM_NEIGHBORS = 5;

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
            'UndersamplingRatio', sampling_params.undersampling_ratio);
        
        training_set(idx_remove) = [];

        % Oversample the minority class
        [synthetic_fish, synthetic_fish_labels] = ADASYN(...
            data(training_set, :), labels(training_set), ...
            sampling_params.oversampling_beta, NUM_NEIGHBORS, ...
            NUM_NEIGHBORS, knn_index_full(training_set, :), ...
            knn_index_minority);

        % Train the model
        trained_model = fitcfun([data(training_set, :); synthetic_fish], ...
            [labels(training_set); synthetic_fish_labels], hyperparams);

        % Predict labels on the validation set
        pred_labels = logical(predict(trained_model, data(validation_set, :)));

        % Compute performance metrics
        crossval_confusion(:, :, i) = confusionmat(labels(validation_set), ...
            pred_labels);
        [~, ~, ~, f3scores(i)] = analyze_confusion(crossval_confusion(:, :, i));
        
        clear trained_model validation_set training_set synthetic_fish synthetic_fish_labels pred_labels
    end
    
    objective = -mean(f3scores);

    constraints = [];

    % userdata.trained_models = trained_models;
    userdata.confusion = crossval_confusion;
    userdata.f3scores = f3scores;
end
