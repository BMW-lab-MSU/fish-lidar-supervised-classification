% SPDX-License-Identifier: BSD-3-Clause
%% Setup
addpath('../common');
clear

% Set random number generator properties for reproducibility
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';
data_files = {'processed_data_2015', 'processed_data_2016'};
years = {'2015', '2016'};


%% Load data
data = struct('data', cell(numel(data_files), 1), ...
    'labels', cell(numel(data_files), 1), 'year', cell(numel(data_files), 1));

for i = 1:numel(data_files)
    tmp = load([box_dir filesep data_files{i}], 'xpol_processed', 'labels');
    data(i).data = single(tmp.xpol_processed)';
    data(i).labels = logical(tmp.labels)';
    data(i).year = years{i};
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
    roi(i).year = years{i};
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
    'holdout_partition');

mkdir(box_dir, 'training');
save([box_dir filesep 'training' filesep 'roi_training_data.mat'], ...
    'training_data', 'training_labels', 'training_roi_indicator',...
    'crossval_partition', 'holdout_partition');

save([box_dir filesep 'full_roi_data.mat'], 'roi');