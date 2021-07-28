% SPDX-License-Identifier: BSD-3-Clause
%% Setup
addpath('../common');
clear

% Set random number generator properties for reproducibility
rng(0, 'twister');

box_dir = '../../data/fish-lidar/Yellowstone';
training_file = 'processed_data_2015';
testing_file = 'processed_data_2016';

%% Load data
tmp = load([box_dir filesep 'processed' filesep training_file], 'xpol_processed', 'labels');
training_data = single(tmp.xpol_processed)';
training_labels = logical(tmp.labels)';

tmp = load([box_dir filesep 'processed' filesep testing_file], 'xpol_processed', 'labels');
testing_data = single(tmp.xpol_processed)';
testing_labels = logical(tmp.labels)';

clear tmp

%% Partition data into regions of interest
WINDOW_SIZE = 1000;
OVERLAP = 0;
training_roi_labels = create_regions(training_labels, WINDOW_SIZE, OVERLAP);
training_roi_data = create_regions(training_data, WINDOW_SIZE, OVERLAP);
training_roi_indicator = cellfun(@(c) any(c), training_roi_labels);

testing_roi_labels = create_regions(testing_labels, WINDOW_SIZE, OVERLAP);
testing_roi_data = create_regions(testing_data, WINDOW_SIZE, OVERLAP);
testing_roi_indicator = cellfun(@(c) any(c), testing_roi_labels);

%% Partition the data for k-fold cross validation
N_FOLDS = 3;

crossval_partition = cvpartition(training_roi_indicator, 'KFold', N_FOLDS, 'Stratify', true);


%% Save training and testing data
mkdir(box_dir, 'testing');
save([box_dir filesep 'testing' filesep 'first_day_roi_testing_data.mat'], ...
    'testing_roi_data', 'testing_roi_labels', 'testing_roi_indicator');

mkdir(box_dir, 'training');
save([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat'], ...
    'training_roi_data', 'training_roi_labels', 'crossval_partition', ...
    'training_roi_indicator');
