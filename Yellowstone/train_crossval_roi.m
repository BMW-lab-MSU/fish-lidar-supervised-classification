%% Setup
addpath('../common');
clear

box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

n_observations = length(cell2mat(training_data));

%%
% optimize_vars = [
%     optimizableVariable('lambda',[1e-5,1e5]/n_observations,'Transform','log'),...
%     optimizableVariable('learner', {'svm', 'logistic'}),...
%     optimizableVariable('regularization', {'ridge', 'lasso'}),...
%     optimizableVariable('fncost', [1 20], 'Type', 'integer'),...
% ];
sigma = optimizableVariable('sigma',[1e-5,1e5],'Transform','log');
box = optimizableVariable('box',[1e-5,1e5],'Transform','log');
standardize = optimizableVariable('standardize', [0 1], 'Type', 'integer');
fncost = optimizableVariable('fncost', [1 20], 'Type', 'integer');

minfn = @(z)svmobjfun(z, crossval_partition, training_data, training_labels);

results = bayesopt(minfn, [sigma box standardize fncost], 'IsObjectiveDeterministic', true, 'AcquisitionFunctionName', 'expected-improvement-plus', 'UseParallel', false, 'MaxObjectiveEvaluations', 30);



%% SVM objective function for Bayesian optimization
function [objective, constraints, userdata] = svmobjfun(z, crossval_partition, training_data, training_labels)
    trained_models = cell(1, crossval_partition.NumTestSets);
    crossval_confusion = zeros(2, 2, crossval_partition.NumTestSets);
    f3scores = zeros(1, crossval_partition.NumTestSets);

    for i = 1:crossval_partition.NumTestSets
        validation_set_data = cell2mat(training_data(test(crossval_partition, i)));
        validation_set_labels = cell2mat(training_labels(test(crossval_partition, i)));
        training_set_data = cell2mat(training_data(training(crossval_partition, i)));
        training_set_labels = cell2mat(training_labels(training(crossval_partition, i)));

        % Undersample the majority class
        idx_remove = random_undersample(training_set_labels, 0, 'UndersamplingRatio', 0.75);
        training_set_data(:, idx_remove) = [];
        training_set_labels(idx_remove) = [];

        % Oversample the minority class
        [synthetic_fish, synthetic_fish_labels] = ADASYN(training_set_data', ...
            training_set_labels, 0.5, [], [], false);
        training_set_data = [training_set_data, synthetic_fish'];
        training_set_labels = [training_set_labels, synthetic_fish_labels'];

        trained_models{i} = fitcsvm(training_set_data', training_set_labels, 'Cost', [0 1; z.fncost 0], 'BoxConstraint', z.box, 'KernelScale', z.sigma, 'Standardize', logical(z.standardize));
        % trained_models{i} = fitclinear(training_set_data', training_set_labels, 'Cost', [0 1; z.fncost 0], 'Lambda', z.lambda, 'Learner', char(z.learner), 'Regularization', char(z.regularization));

        pred_labels = predict(trained_models{i}, validation_set_data');

        crossval_confusion(:, :, i) = confusionmat(validation_set_labels, pred_labels);

        % losses(i) = loss(trained_models{i}, validation_set_data', validation_set_labels);
        [~, ~, ~, f3scores(i)] = analyze_confusion(crossval_confusion(:, :, i));
    end
    
    objective = -mean(f3scores);

    constraints = [];

    userdata.trained_models = trained_models;
    userdata.confusion = crossval_confusion;
    userdata.f3scores = f3scores;
end