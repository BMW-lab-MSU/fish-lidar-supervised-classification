%% Setup
addpath('../common');
clear

% Set random number generator properties for reproducibility
rng(0, 'twister');

box_dir = 'D:\Box Sync\AFRL_Data\Data\GulfOfMexico';

training_file = 'processed_data_09-24.mat';
testing_files = {...
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
testing_days = {'09-25', '09-26', '09-29', '09-30', '10-01', ...
    '10-02', '10-03', '10-04', '10-05', '10-06', '10-07'}; 

n_testing = numel(testing_files);

%% Load data
tmp = load([box_dir filesep 'processed data' filesep training_file], 'xpol_processed', 'labels');
training_data = single(tmp.xpol_processed)';
training_labels = any(tmp.labels)';

testing_data = struct('data', cell(n_testing, 1), ...
    'labels', cell(n_testing, 1), 'day', cell(n_testing, 1));

for i = 1:n_testing
    tmp = load([box_dir filesep 'processed data' filesep testing_files{1}], 'xpol_processed', 'labels');
    testing_data(i).data = single(tmp.xpol_processed)';
    testing_data(i).labels = any(tmp.labels(1:3,:))';
    testing_data(i).day = testing_days{i};
end

clear tmp

%% Partition data into regions of interest
WINDOW_SIZE = 1000;
OVERLAP = 0;
training_roi_labels = create_regions(training_labels, WINDOW_SIZE, OVERLAP);
training_roi_data = create_regions(training_data, WINDOW_SIZE, OVERLAP);
training_roi_indicator = cellfun(@(c) any(c), training_roi_labels);

testing_roi = struct('data', cell(n_testing, 1), ...
    'labels', cell(n_testing, 1), 'day', cell(n_testing, 1), ...
    'indicator', cell(n_testing, 1));

for i = 1:n_testing
    testing_roi(i).labels = create_regions(...
        testing_data(i).labels, WINDOW_SIZE, OVERLAP);
    testing_roi(i).data = create_regions(...
        testing_data(i).data, WINDOW_SIZE, OVERLAP);
    testing_roi(i).indicator = cellfun(@(c) any(c), testing_roi(i).labels);
    testing_roi(i).day = testing_days{i};
end

%% Partition the data for k-fold cross validation
N_FOLDS = 3;

crossval_partition = cvpartition(training_roi_indicator, 'KFold', N_FOLDS, 'Stratify', true);


%% Save training and testing data
mkdir(box_dir, 'testing');
save([box_dir filesep 'testing' filesep 'first_day_roi_testing_data.mat'], ...
    'testing_roi', '-v7.3');

mkdir(box_dir, 'training');
save([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat'], ...
    'training_roi_data', 'training_roi_labels', 'crossval_partition', ...
    'training_roi_indicator', '-v7.3');
