%% Configuration
box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/GulfOfMexico';

%% Setup
addpath('../common');
%clear

rng(0, 'twister');

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

load([box_dir filesep 'training' filesep 'sampling_tuning_roi_nnet.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

%% Tune nnet hyperparameters

optimize_vars = [
   optimizableVariable('LayerSizes',[10,50], 'Type', 'integer'),...
   optimizableVariable('activations', {'relu', 'tanh', 'sigmoid'}),...
];

minfun = @(hyperparams)cvobjfun_roi(@nnet, hyperparams, ...
    undersampling_ratio, crossval_partition, training_data, ...
    training_labels, training_roi_indicator);

results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_nnet.mat'],...
    'results', 'best_params', '-v7.3');

%% Model fitting function
function model = nnet(data, labels, params)
    model = compact(fitcnet(data, labels, 'Standardize', true, ...
        'LayerSizes', params.LayerSizes, ...
        'Activations', char(params.activations)));
end
