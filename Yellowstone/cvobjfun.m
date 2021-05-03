function [objective, constraints, userdata] = cvobjfun(fitfun, params, crossval_partition, data, labels)
% bayesobjfun Optimize hyperparameters
    MINORITY_LABEL = 0;

    trained_models = cell(1, crossval_partition.NumTestSets);
    crossval_confusion = zeros(2, 2, crossval_partition.NumTestSets);
    f3scores = zeros(1, crossval_partition.NumTestSets);

    for i = 1:crossval_partition.NumTestSets
        % Get validation and training partitions; transpose the data and labels
        % because our observations are in columns, but everybody else wants them
        % in rows.
        validation_set_data = data(:, test(crossval_partition, i))';
        validation_set_labels = labels(test(crossval_partition, i))';
        training_set_data = data(:, training(crossval_partition, i))';
        training_set_labels = labels(training(crossval_partition, i))';

        % Undersample the majority class
        idx_remove = random_undersample(training_set_labels, MINORITY_LABEL, ...
            'UndersamplingRatio', params.undersampling_ratio);

        training_set_data(idx_remove, :) = [];
        training_set_labels(idx_remove) = [];

        % Oversample the minority class
        [synthetic_fish, synthetic_fish_labels] = ADASYN(training_set_data, ...
            training_set_labels, params.oversampling_beta, [], [], false);

        training_set_data = [training_set_data; synthetic_fish];
        training_set_labels = [training_set_labels; synthetic_fish_labels];

        % Train the model
        trained_models{i} = fitfun(training_set_data, training_set_labels, params);

        % Predict labels on the validation set
        pred_labels = predict(trained_models{i}, validation_set_data);

        % Compute performance metrics
        crossval_confusion(:, :, i) = confusionmat(validation_set_labels, pred_labels);
        [~, ~, ~, f3scores(i)] = analyze_confusion(crossval_confusion(:, :, i));
    end
    
    objective = -mean(f3scores);

    constraints = [];

    % userdata.trained_models = trained_models;
    userdata.confusion = crossval_confusion;
    userdata.f3scores = f3scores;
end