% SPDX-License-Identifier: BSD-3-Clause
%% Configuration
box_dir = '../../data/fish-lidar/GulfOfMexico';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

%% Load params
load([box_dir filesep 'training' filesep 'sampling_tuning_roi_lda.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

load([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_lda.mat'], 'best_params')
params = best_params

%% Train LDA
model = train_base(@lda, params, undersampling_ratio, training_data, ...
    training_labels, training_roi_indicator);

% save the model and results
model_dir = [box_dir filesep 'training' filesep 'models'];
mkdir(model_dir);
save([model_dir filesep 'lda.mat'], 'model');

%% Model fitting function
function model = lda(data, labels, params)
    % model = compact(fitcdiscr(data, labels, 'DiscrimType', 'pseudoLinear', ...
    %     'Cost', [0 1; params.fncost 0], 'Delta', params.delta, ...
    %     'Gamma', params.gamma));
    model = compact(fitcdiscr(data, labels, 'DiscrimType', 'pseudoLinear', ...
        'Cost', [0 1; params.fncost 0]));
end
