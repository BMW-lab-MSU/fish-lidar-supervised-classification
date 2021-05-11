%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/GulfOfMexico';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

%% Tune sampling ratios
result = tune_sampling_roi_base(@lda, training_data, ...
    training_labels, training_roi_indicator, crossval_partition, ...
    'Progress', true);

save([box_dir filesep 'training' filesep 'sampling_tuning_roi_lda.mat'], 'result')

%% Model fitting function
function model = lda(data, labels, ~)
    model = compact(fitcdiscr(data, labels, 'DiscrimType', 'pseudolinear'));
end
