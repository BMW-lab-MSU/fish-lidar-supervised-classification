%% Configuration
box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/GulfOfMexico';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

%% Load data
load([box_dir filesep 'training' filesep 'training_data_all_labels.mat']);
training_data = training_data';
training_labels = training_labels';

load([box_dir filesep 'training' filesep 'tune_sampling_svm.mat'])
undersampling_ratio = result.undersampling_ratio;
clear result

load([box_dir filesep 'training' filesep 'hyperparameter_tuning_svm.mat'])

%% Train SVM
[model, metrics, pred_labels] = train_base(@svm, [], undersampling_ratio, ...
    training_data, training_labels);

mkdir([box_dir filesep 'trained_models']);
save([box_dir filesep 'trained_models' filesep 'svm.mat'], ...
    'model', 'metrics', 'pred_labels');

%% Model fitting function
function model = svm(data, labels, params)
    model = compact(fitclinear(data, labels, ...
        'Cost', [0 1; params.fncost 0], 'Lambda', params.lambda, ...
        'Regularization', char(params.regularization))); 
end
