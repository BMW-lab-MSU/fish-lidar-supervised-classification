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

load([box_dir filesep 'training' filesep 'tune_sampling_tree.mat'])
undersampling_ratio = result.undersampling_ratio;
clear result

load([box_dir filesep 'training' filesep 'hyperparameter_tuning_tree.mat'])
params = best_params;

%% Train LDA
[model, metrics, pred_labels] = train_base(@tree, params,...
    undersampling_ratio, training_data, training_labels);

% save the model and results
model_dir = [box_dir filesep 'training' filesep 'models'];
mkdir(model_dir);
save([model_dir filesep 'tree.mat'], 'model', 'metrics', 'pred_labels');

%% Model fitting function
function model = tree(data, labels, params)
    model = compact(fitctree(data, labels, 'Cost', [0 1; params.fncost 0]));
end
