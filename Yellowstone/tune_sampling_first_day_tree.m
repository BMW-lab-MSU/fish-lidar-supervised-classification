%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

%% Tune sampling ratios
result = tune_sampling_roi_base(@tree, training_roi_data, ...
    training_roi_labels, training_roi_indicator, crossval_partition, ...
    'Progress', true);

save([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_tree.mat'], 'result')

%% Model fitting function
function model = tree(data, labels, ~)
    model = compact(fitctree(data, labels)); 
end