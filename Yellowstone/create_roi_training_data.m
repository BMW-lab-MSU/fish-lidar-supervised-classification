%% Setup
addpath('../common');
clear

% Set random number generator properties for reproducibility
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';
input_data_files = {'processed_data_2015', 'processed_data_2016'};


%% Load data
data = [];
labels = [];
for filename = input_data_files
    tmp = load([box_dir filesep filename{:}], 'xpol_processed', 'labels');
    data = [data, tmp.xpol_processed];
    labels = [labels, tmp.labels];
end

%% Partition data into regions of interest
WINDOW_SIZE = 1000;
OVERLAP = 0;
roi_labels = create_regions(labels, WINDOW_SIZE, OVERLAP);
roi_data = create_regions(data, WINDOW_SIZE, OVERLAP);
roi_indicator = cellfun(@(c) any(c), roi_labels);

%% Partiion into training and test sets
TEST_PCT = 0.2;

holdout_partition = cvpartition(roi_indicator, 'Holdout', TEST_PCT, 'Stratify', true);

training_labels = roi_labels(training(holdout_partition));
testing_labels = roi_labels(test(holdout_partition));
training_data = roi_data(training(holdout_partition));
testing_data = roi_data(test(holdout_partition));


%% Partition the data for k-fold cross validation
N_FOLDS = 5;

training_roi_indicator = cellfun(@(c) any(c), training_labels);

crossval_partition = cvpartition(training_roi_indicator, 'KFold', N_FOLDS, 'Stratify', true);


%% Save training and testing data
mkdir(box_dir, 'testing');
save([box_dir filesep 'testing' filesep 'roi_testing_data.mat'], ...
    'testing_data', 'testing_labels', 'holdout_partition');

mkdir(box_dir, 'training');
save([box_dir filesep 'training' filesep 'roi_training_data.mat'], ...
    'training_data', 'training_labels', 'crossval_partition', ...
    'holdout_partition');
