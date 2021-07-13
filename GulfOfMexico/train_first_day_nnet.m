% SPDX-License-Identifier: BSD-3-Clause
%% Configuration
box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/GulfOfMexico';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

%% Load data
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

%% Load params
load([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_nnet.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

load([box_dir filesep 'training' filesep 'hyperparameter_tuning_first_day_roi_nnet.mat'], 'best_params')
params = best_params

%% Train neural network
model = train_base(@nnet, params, undersampling_ratio, training_roi_data, ...
    training_roi_labels, training_roi_indicator);

% save the model and results
model_dir = [box_dir filesep 'training' filesep 'models'];
mkdir(model_dir);
save([model_dir filesep 'nnet_first_day.mat'], 'model');


%% Model fitting function
function model = nnet(data, labels, params)
    model = compact(fitcnet(data, labels, 'Standardize', true, ...
        'LayerSizes', params.LayerSizes, ...
        'Activations', char(params.activations)));
end
