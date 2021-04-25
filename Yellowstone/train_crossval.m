%% Setup
addpath('../common');
clear

box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

pool = parpool();
statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);

%%
trained_models = cell(1, crossval_partition.NumTestSets);
crossval_confusion = zeros(1, 2, 2);


tic
for i = 1:crossval_partition.NumTestSets
    validation_set_data = training_data(:, test(crossval_partition, i));
    validation_set_labels = training_labels(test(crossval_partition, i));
    training_set_data = training_data(:, training(crossval_partition, i));
    training_set_labels = training_labels(training(crossval_partition, i));

    trained_models{i} = fitcsvm(training_set_data.', training_set_labels, 'Cost', [0 1; 10 0]);

    pred_labels = predict(trained_models{i}, validation_set_data.');
    crossval_confusion(i, :, :) = confusionmat(validation_set_labels, pred_labels);
end
toc
