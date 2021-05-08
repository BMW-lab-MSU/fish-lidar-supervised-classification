%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/Yellowstone';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);
training_data = training_data';
training_labels = training_labels';

%% Tune sampling ratios
tune_sampling_base(@nnet, training_data, training_labels, crossval_partition);

%% Model fitting function
function model = nnet(data, labels, ~)
    model = compact(fitcnet(data, labels, 'Standardize', true)); 
end