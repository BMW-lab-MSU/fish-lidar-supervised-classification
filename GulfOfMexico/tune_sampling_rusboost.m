%% Setup
addpath('../common');
%clear

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/GulfOfMexico';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);
training_data = training_data';
training_labels = training_labels';

%% Tune sampling ratios
tune_sampling_base(@rusboost, training_data, training_labels, ...
    crossval_partition);

%% Model fitting function
function model = rusboost(data, labels, ~)
    t = templateTree('Reproducible',true);
    model = compact(fitcensemble(data, labels, 'Method', 'RUSBoost', 'Learners', t));
end
