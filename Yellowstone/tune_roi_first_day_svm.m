% SPDX-License-Identifier: BSD-3-Clause
%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '../../data/fish-lidar/Yellowstone';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

%% Load params
% NOTE: the SVM was an uninformative classifier during all tuning, so we
% just use the defaults here.
disp('using default values becuase the classifier was uninformative')
load([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_svm.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

% load([box_dir filesep 'training' filesep 'hyperparameter_tuning_first_day_roi_svm.mat'])
% params = best_params;
% clear best_params

%% Tune number of labels per ROI
t0 = tic;
result = tune_roi_base(@svm, params, undersampling_ratio,...
    crossval_partition, training_roi_data, training_roi_labels,...
    training_roi_indicator, 'Progress', true)
runtime = toc(t0);

% save runtimes
tab = table(runtime, 'VariableNames', "roi_tuning_first_day", 'RowNames', "svm");
if exist(['runtimes' filesep 'roi_tuning_runtimes_first_day.mat'])
    load(['runtimes' filesep 'roi_tuning_runtimes_first_day']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'roi_tuning_runtimes_first_day'], 'runtimes')

result.confusion(:,:,result.min_idx)
result.objective(result.min_idx)

save([box_dir filesep 'training' filesep 'roi_label_tuning_first_day_svm.mat'], 'result')

%% Model fitting function
function model = svm(data, labels, ~)
    model = compact(fitclinear(data, labels)); 
end
