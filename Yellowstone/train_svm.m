%% Configuration
box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);
training_data = training_data';
training_labels = training_labels';

load([box_dir filesep 'training' filesep 'tune_sampling_svm.mat'])
undersampling_ratio = result.undersampling_ratio;
clear result

% NOTE: the SVM always had an F3 score of NaN, i.e. it prediced everything
% as the negative class. Thus, there's no need to load the hyperparamter
% tuning results because we might as well just use default values.
% load([box_dir filesep 'training' filesep 'hyperparameter_tuning_svm.mat'])

%% Train SVM
[model, metrics, pred_labels] = train_base(@svm, [], undersampling_ratio, ...
    training_data, training_labels);

mkdir([box_dir filesep 'trained_models']);
save([box_dir filesep 'trained_models' filesep 'svm.mat'], ...
    'model', 'metrics', 'pred_labels');

%% Model fitting function
function model = svm(data, labels, params)
    model = fitcsvm(data, labels);
end
