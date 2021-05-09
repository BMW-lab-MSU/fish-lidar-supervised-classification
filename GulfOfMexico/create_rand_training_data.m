%% Setup
addpath('../common');
clear

% Set random number generator properties for reproducibility
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/GulfOfMexico';

input_data_files = {...
    'processed_data_09-24.mat'...
    'processed_data_09-25.mat'...
    'processed_data_09-26.mat'...
    'processed_data_09-29.mat'...
    'processed_data_09-30.mat'...
    'processed_data_10-01.mat'...
    'processed_data_10-02.mat'...
    'processed_data_10-03.mat'...
    'processed_data_10-04.mat'...
    'processed_data_10-05.mat'...
    'processed_data_10-06.mat'...
    'processed_data_10-07.mat'};

%% Load data
data = [];
labels = [];
for filename = input_data_files
    tmp = load([box_dir filesep 'processed data' filesep filename{:}], 'xpol_processed', 'labels');
    data = [data, single(tmp.xpol_processed)];
    labels = logical([labels, logical(tmp.labels)]);
end

labels = any(labels(1:4,:));

%% Partiion into training and test sets
TEST_PCT = 0.2;

holdout_partition = cvpartition(labels, 'Holdout', TEST_PCT, 'Stratify', true);

training_labels = labels(training(holdout_partition));
testing_labels = labels(test(holdout_partition));
training_data = data(:, training(holdout_partition));
testing_data = data(:, test(holdout_partition));


%% Partition the data for k-fold cross validation
N_FOLDS = 5;

crossval_partition = cvpartition(training_labels, 'KFold', N_FOLDS, 'Stratify', true);


%% Save training and testing data
mkdir(box_dir, 'testing');
save([box_dir filesep 'testing' filesep 'testing_data_all_labels.mat'], ...
    'testing_data', 'testing_labels', 'holdout_partition', '-v7.3');

mkdir(box_dir, 'training');
save([box_dir filesep 'training' filesep 'training_data_all_labels.mat'], ...
    'training_data', 'training_labels', 'crossval_partition', ...
    'holdout_partition', '-v7.3');
