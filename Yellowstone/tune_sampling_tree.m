%% Setup
addpath('../common');
%clear

box_dir = '~/research/afrl/data/fish-lidar/Yellowstone';

if isempty(gcp('nocreate'))
    pool = parpool(2);
end
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);
training_data = training_data';
training_labels = training_labels';

%% Tune sampling ratios
tune_sampling_base(@tree, training_data, training_labels, ...
    crossval_partition, 'Progress', true, 'UseParallel', true, ...
    'NumThreads', 4);

%% Model fitting function
function model = tree(data, labels, ~)
    model = compact(fitctree(data, labels)); 
end