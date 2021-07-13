% SPDX-License-Identifier: BSD-3-Clause
%% Configuration
box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/GulfOfMexico';

%% Setup
addpath('../common');
%clear

rng(0, 'twister');
% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data_all_labels.mat']);
training_data = training_data';
training_labels = training_labels';

load([box_dir filesep 'training' filesep 'tune_sampling_nb.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

%% Tune Naive Bayes hyperparameters

optimize_vars = [
   optimizableVariable('DistributionNames', {'normal', 'kernel'}),...
   optimizableVariable('Kernel', {'normal', 'box', 'epanechnikov', 'triangle'}),...
   optimizableVariable('fncost', [1 20], 'Type', 'integer')
];

minfun = @(hyperparams)cvobjfun(@nb, hyperparams, undersampling_ratio, ...
    crossval_partition, training_data, training_labels);

results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 30);

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_nb.mat'],...
    'results', 'best_params');

%% Model fitting function
function model = nb(data, labels, params)
    model = compact(fitcnb(data, labels, ...
        'Cost', [0 1; params.fncost 0], ...
        'DistributionNames', char(params.DistributionNames), ...
        'Kernel', char(params.Kernel)));
end
