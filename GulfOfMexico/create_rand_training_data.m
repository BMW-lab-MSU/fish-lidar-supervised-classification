% SPDX-License-Identifier: BSD-3-Clause
%% Setup
addpath('../common');
clear

% Set random number generator properties for reproducibility
rng(0, 'twister');

box_dir = 'D:\Box Sync\AFRL_Data\Data\GulfOfMexico';

data_files = {...
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
day = {'09-24', '09-25', '09-26', '09-29', '09-30', '10-01', '10-02', ...
    '10-03', '10-04', '10-05', '10-06', '10-07'};


%% Load data
data = struct('data', cell(numel(data_files), 1), ...
    'labels', cell(numel(data_files), 1), 'year', cell(numel(data_files), 1));

for i = 1:numel(data_files)
    tmp = load([box_dir filesep 'processed data' filesep data_files{i}], 'xpol_processed', 'labels');
    data(i).data = single(tmp.xpol_processed)';
    data(i).labels = any(tmp.labels(1:3,:))';
    data(i).day = day{i};
end

%% Partition data into regions of interest
WINDOW_SIZE = 1000;
OVERLAP = 0;

roi = struct('data', cell(numel(data_files), 1), ...
    'labels', cell(numel(data_files), 1), ...
    'year', cell(numel(data_files), 1), ...
    'indicator', cell(numel(data_files), 1));

for i = 1:numel(data_files)
    roi(i).labels = create_regions(data(i).labels, WINDOW_SIZE, OVERLAP);
    roi(i).data = create_regions(data(i).data, WINDOW_SIZE, OVERLAP);
    roi(i).indicator = cellfun(@(c) any(c), roi(i).labels);
    roi(i).day = day{i};
end

roi_data = vertcat(roi(:).data);
roi_labels = vertcat(roi(:).labels);
roi_indicator = vertcat(roi(:).indicator);

%% Partiion into training and test sets
TEST_PCT = 0.2;

holdout_partition = cvpartition(roi_indicator, 'Holdout', TEST_PCT, 'Stratify', true);

training_labels = roi_labels(training(holdout_partition));
testing_labels = roi_labels(test(holdout_partition));
training_data = roi_data(training(holdout_partition), :);
testing_data = roi_data(test(holdout_partition), :);
training_roi_indicator = roi_indicator(training(holdout_partition));
testing_roi_indicator = roi_indicator(test(holdout_partition));

%% Partition the data for k-fold cross validation
N_FOLDS = 3;

crossval_partition = cvpartition(training_roi_indicator, 'KFold', N_FOLDS, 'Stratify', true);


%% Save training and testing data
mkdir(box_dir, 'testing');
save([box_dir filesep 'testing' filesep 'roi_testing_data.mat'], ...
    'testing_data', 'testing_labels', 'testing_roi_indicator', ...
    'holdout_partition', '-v7.3');

mkdir(box_dir, 'training');
save([box_dir filesep 'training' filesep 'roi_training_data.mat'], ...
    'training_data', 'training_labels', 'training_roi_indicator',...
    'crossval_partition', 'holdout_partition', '-v7.3');

save([box_dir filesep 'full_roi_data.mat'], 'roi', '-v7.3');