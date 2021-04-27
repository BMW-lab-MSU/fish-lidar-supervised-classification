%% Setup
addpath('../common');
clear

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/Yellowstone';

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);

%%
sigma = optimizableVariable('sigma',[1e-5,1e5],'Transform','log');
box = optimizableVariable('box',[1e-5,1e5],'Transform','log');
standardize = optimizableVariable('standardize', [0 1], 'Type', 'integer');
fncost = optimizableVariable('fncost', [1 20], 'Type', 'integer');

minfn = @(z)svmobjfun(z, crossval_partition, training_data, training_labels);

results = bayesopt(minfn, [sigma, box, standardize, fncost], 'IsObjectiveDeterministic', true, 'AcquisitionFunctionName', 'expected-improvement-plus', 'UseParallel', false, 'MaxObjectiveEvaluations', 3);



%% SVM objective function for Bayesian optimization
function [objective, constraints, userdata] = svmobjfun(z, crossval_partition, training_data, training_labels)
    trained_models = cell(1, crossval_partition.NumTestSets);
    crossval_confusion = zeros(2, 2, crossval_partition.NumTestSets);
    losses = zeros(1, crossval_partition.NumTestSets);

    for i = 1:crossval_partition.NumTestSets
        validation_set_data = training_data(:, test(crossval_partition, i));
        validation_set_labels = training_labels(test(crossval_partition, i));
        training_set_data = training_data(:, training(crossval_partition, i));
        training_set_labels = training_labels(training(crossval_partition, i));

        sum(training_set_labels == 0)
        sum(training_set_labels == 1)

        % Undersample the majority class
        idx_remove = random_undersample(training_set_labels, 0, 'UndersamplingRatio', 0.75);
        training_set_data(:, idx_remove) = [];
        training_set_labels(idx_remove) = [];

        % Oversample the minority class
        [synthetic_fish, synthetic_fish_labels] = ADASYN(training_set_data', ...
            training_set_labels, 0.5, [], [], false);
        training_set_data = [training_set_data, synthetic_fish'];
        training_set_labels = [training_set_labels, synthetic_fish_labels'];

        sum(training_set_labels == 0)
        sum(training_set_labels == 1)

        trained_models{i} = fitcsvm(training_set_data', training_set_labels, 'Cost', [0 1; z.fncost 0], 'BoxConstraint', z.box, 'KernelScale', z.sigma, 'Standardize', logical(z.standardize));

        pred_labels = predict(trained_models{i}, validation_set_data');

        crossval_confusion(:, :, i) = confusionmat(validation_set_labels, pred_labels);

        losses(i) = loss(trained_models{i}, validation_set_data', validation_set_labels);
    end
    
    objective = mean(losses);

    constraints = [];

    userdata.trained_models = trained_models;
    userdata.confusion = crossval_confusion;
    userdata.losses = losses;
end
