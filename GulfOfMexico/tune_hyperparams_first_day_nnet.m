% SPDX-License-Identifier: BSD-3-Clause
%% Configuration
box_dir = '/mnt/data/trevor/research/afrl/data/AFRL_Data/Data/GulfOfMexico';

%% Setup
addpath('../common');
%clear

rng(0, 'twister');

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

load([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_nnet.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

%% Tune nnet hyperparameters

optimize_vars = [
   optimizableVariable('LayerSizes',[10,50], 'Type', 'integer'),...
   optimizableVariable('activations', {'relu', 'tanh', 'sigmoid'}),...
];

minfun = @(hyperparams)cvobjfun_roi(@nnet, hyperparams, ...
    undersampling_ratio, crossval_partition, training_roi_data, ...
    training_roi_labels, training_roi_indicator);

t0 = tic;
results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);
runtime = toc(t0);

% save runtimes
tab = table(runtime, 'VariableNames', "hyperparam_tuning_first_day", 'RowNames', "nnet");
if exist(['runtimes' filesep 'hyperparam_tuning_runtimes_first_day.mat'])
    load(['runtimes' filesep 'hyperparam_tuning_runtimes_first_day']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'hyperparam_tuning_runtimes_first_day'], 'runtimes')

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_first_day_roi_nnet.mat'],...
    'results', 'best_params');

%% Model fitting function
function model = nnet(data, labels, params)
    model = compact(fitcnet(data, labels, 'Standardize', true, ...
        'LayerSizes', params.LayerSizes, ...
        'Activations', char(params.activations)));
end
