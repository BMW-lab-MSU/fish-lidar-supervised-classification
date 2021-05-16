%% Configuration
box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/GulfOfMexico';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

%% Load data
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

%% Load params
load([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_rusboost.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

load([box_dir filesep 'training' filesep 'hyperparameter_tuning_first_day_roi_rusboost.mat'], 'best_params')
params = best_params

%% Train rusboost
model = train_base(@rusboost, params, undersampling_ratio, training_roi_data, ...
    training_roi_labels, training_roi_indicator);

% save the model and results
model_dir = [box_dir filesep 'training' filesep 'models'];
mkdir(model_dir);
save([model_dir filesep 'rusboost_first_day.mat'], 'model');

%% Model fitting function
function model = rusboost(data, labels, params)
    t = templateTree('Reproducible',true, ...
       'MaxNumSplits', params.MaxNumSplits, ...
       'MinLeafSize', params.MinLeafSize, ...
       'SplitCriterion', char(params.SplitCriterion));

    model = compact(fitcensemble(data, labels, 'Method', 'RUSBoost', ...
       'Learners', t, 'Cost', [0 1; params.fncost 0], ...
       'NumLearningCycles', params.NumLearningCycles, ...
       'LearnRate', params.LearnRate));
end