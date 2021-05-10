%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '../../data/fish-lidar/Data/Yellowstone';

if isempty(gcp('nocreate'))
    pool = parpool();
end
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);
training_data = training_data';
training_labels = training_labels';

%% Tune sampling ratios
tune_sampling_base(@svm, training_data, training_labels, crossval_partition, ...
    'Progress', true, 'UseParallel', true, 'NumThreads', 2);

%% Model fitting function
function model = svm(data, labels, ~)
    model = compact(fitcsvm(data, labels)); 
end
