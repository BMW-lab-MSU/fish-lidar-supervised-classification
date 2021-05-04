%% Setup
addpath('../common');
%clear

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/Yellowstone';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);

%% Tune sampling ratios
tune_sampling_base(@nb, training_data, training_labels, crossval_partition);

%% Model fitting function
function model = nb(data, labels, ~)
    model = fitcnb(data, labels); 
end