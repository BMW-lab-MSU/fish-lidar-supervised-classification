%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

%% Load params
load([box_dir filesep 'training' filesep 'sampling_tuning_roi_tree.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

load([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_tree.mat'])
params = best_params;
clear best_params

%% Tune number of labels per ROI
result = tune_roi_base(@tree, params, undersampling_ratio, ....
    crossval_partition, training_data, training_labels, ...
    training_roi_indicator, 'Progress', true)

result.confusion(:,:,result.min_idx)
result.objective(result.min_idx)

save([box_dir filesep 'training' filesep 'roi_label_tuning_tree.mat'], 'result')

%% Model fitting function
function model = tree(data, labels, params)
    model = compact(fitctree(data, labels, 'Cost', [0 1; params.fncost 0],...
        'MaxNumSplits', params.MaxNumSplits, ...
        'MinLeafSize', params.MinLeafSize, ...
        'SplitCriterion', char(params.SplitCriterion)));
    % model = compact(fitctree(data, labels, 'Cost', [0 1; params.fncost 0]));
end