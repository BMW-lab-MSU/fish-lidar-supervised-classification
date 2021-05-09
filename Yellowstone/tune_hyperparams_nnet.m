%% Configuration
box_dir = '../../data/fish-lidar/Data/Yellowstone';

%% Setup
addpath('../common');
%clear

rng(0, 'twister');

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);
training_data = training_data';
training_labels = training_labels';

load([box_dir filesep 'training' filesep 'tune_sampling_nnet.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

%% Tune nnet hyperparameters

optimize_vars = [
   optimizableVariable('LayerSizes',[10,50], 'Type', 'integer'),...
   optimizableVariable('activations', {'relu', 'tanh', 'sigmoid'}),...
];

minfun = @(hyperparams)cvobjfun(@nnet, hyperparams, undersampling_ratio, ...
    crossval_partition, training_data, training_labels);

results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 30);

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_nnet.mat'],...
    'results', 'best_params');

%% Model fitting function
function model = nnet(data, labels, params)
    model = compact(fitcnet(data, labels, 'Standardize', true, ...
        'LayerSizes', params.LayerSizes, ...
        'Activations', char(params.activations)));
end
