%% Setup
addpath('../common');
clear

% Set random number generator properties for reproducibility
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/Yellowstone';
input_data_files = {'processed_data_2015', 'processed_data_2016'};


%% Load data
data = [];
labels = [];
for filename = input_data_files
    tmp = load([box_dir filesep filename{:}], 'xpol_processed', 'labels');
    data = [data, tmp.xpol_processed];
    labels = [labels, tmp.labels];
end


%% Partiion into training and test sets
TEST_PCT = 0.2;

holdout_partition = cvpartition(labels, 'Holdout', TEST_PCT, 'Stratify', true);

training_labels = labels(training(holdout_partition));
testing_labels = labels(test(holdout_partition));
training_data = data(:, training(holdout_partition));
testing_data = data(:, test(holdout_partition));


%% Partition the data for cross-fold validation
N_FOLDS = 5;

crossval_partition = cvpartition(training_labels, 'KFold', N_FOLDS, 'Stratify', true);


%% Save training and testing data
mkdir(box_dir, 'testing');
save([box_dir filesep 'testing' filesep 'testing_data.mat'], ...
    'testing_data', 'testing_labels', 'holdout_partition');

mkdir(box_dir, 'training');
save([box_dir filesep 'training' filesep 'training_data.mat'], ...
    'training_data', 'training_labels', 'crossval_partition', ...
    'holdout_partition');