%% Configuration
box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

%% Configuration
box_dir = 'D:\Box Sync\AFRL_Data\Data\Yellowstone';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

%% Load params
load([box_dir filesep 'training' filesep 'sampling_tuning_roi_rusboost.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

load([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_rusboost.mat'], 'best_params')
params = best_params

%% Train rusboost
model = train_base(@rusboost, params, undersampling_ratio, training_data, ...
    training_labels, training_roi_indicator);

% save the model and results
model_dir = [box_dir filesep 'training' filesep 'models'];
mkdir(model_dir);
save([model_dir filesep 'rusboost.mat'], 'model');

%% Model fitting function
function model = rusboost(data, labels, params)
    %t = templateTree('Reproducible',true, ...
    %    'MaxNumSplits', params.MaxNumSplits, ...
    %    'MinLeafSize', params.MinLeafSize, ...
    %    'SplitCriterion', char(params.SplitCriterion));
    t = templateTree('Reproducible',true);

    %model = compact(fitcensemble(data, labels, 'Method', 'RUSBoost', ...
    %    'Learners', t, 'Cost', [0 1; params.fncost 0], ...
    %    'NumLearningCycles', params.NumLearningCycles, ...
    %    'LearnRate', params.LearnRate));
    model = compact(fitcensemble(data, labels, 'Method', 'RUSBoost', ...
        'Learners', t, 'Cost', [0 1; params.fncost 0]));
end