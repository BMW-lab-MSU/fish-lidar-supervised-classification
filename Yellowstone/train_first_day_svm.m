% SPDX-License-Identifier: BSD-3-Clause
%% Configuration
box_dir = '../../data/fish-lidar/Yellowstone';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

%% Load data
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

%% Load params
% NOTE: after tuning, the SVM was still uninformative, so we're using
% default parameters
disp('using default parameters because the SVM was uninformative')

load([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_svm.mat'])
undersampling_ratio = result.undersampling_ratio
clear result
% 
% load([box_dir filesep 'training' filesep 'hyperparameter_tuning_first_day_roi_svm.mat'], 'best_params')
% params = best_params

%% Train SVM
model = train_base(@svm, [], undersampling_ratio, training_roi_data, ...
    training_roi_labels, training_roi_indicator);

% save the model and results
model_dir = [box_dir filesep 'training' filesep 'models'];
mkdir(model_dir);
save([model_dir filesep 'svm_first_day.mat'], 'model');

%% Model fitting function
function model = svm(data, labels, params)
    model = fitclinear(data, labels);
end
