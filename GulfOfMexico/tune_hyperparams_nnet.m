% SPDX-License-Identifier: BSD-3-Clause
%% Configuration
box_dir = '../../data/fish-lidar/GulfOfMexico';

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

t0 = tic;
results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);
runtime = toc(t0);

% save runtimes
tab = table(runtime, 'VariableNames', "hyperparam_tuning", 'RowNames', "nnet");
if exist(['runtimes' filesep 'hyperparam_tuning_runtimes.mat'])
    load(['runtimes' filesep 'hyperparam_tuning_runtimes']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'hyperparam_tuning_runtimes'], 'runtimes')

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_nnet.mat'],...
    'results', 'best_params', '-v7.3');

%% Model fitting function
function model = nnet(data, labels, params)
    model = compact(fitcnet(data, labels, 'Standardize', true, ...
        'LayerSizes', params.LayerSizes, ...
        'Activations', char(params.activations)));
end
