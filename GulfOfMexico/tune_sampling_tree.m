%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/GulfOfMexico';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data_all_labels.mat']);
training_data = training_data';
training_labels = training_labels';

%% Tune sampling ratios
tune_sampling_base(@tree, training_data, training_labels, crossval_partition, 'Progress', true);

%% Model fitting function
function model = tree(data, labels, ~)
    model = compact(fitctree(data, labels));
end
