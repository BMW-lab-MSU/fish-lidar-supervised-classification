% SPDX-License-Identifier: BSD-3-Clause
%% Configuration
box_dir = '../../data/fish-lidar/Yellowstone';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

load([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_rusboost.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

%% Tune rusboost hyperparameters
n_observations = length(training_roi_data);

optimize_vars = [
   optimizableVariable('NumLearningCycles',[10, 500], 'Transform','log'),...
   optimizableVariable('LearnRate',[1e-3, 1], 'Transform','log'),...
   optimizableVariable('MaxNumSplits',[1,max(2, n_observations - 1)],'Transform','log'),...
   optimizableVariable('MinLeafSize',[1,max(2, floor(n_observations/2))],'Transform','log'),...
   optimizableVariable('SplitCriterion', {'gdi', 'deviance'}),...
   optimizableVariable('fncost', [1 20], 'Type', 'integer')
];

minfun = @(hyperparams)cvobjfun_roi(@rusboost, hyperparams, ...
    undersampling_ratio, crossval_partition, training_roi_data, ...
    training_roi_labels, training_roi_indicator);

t0 = tic;
results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);
runtime = toc(t0);

% save runtimes
tab = table(runtime, 'VariableNames', "hyperparam_tuning_first_day", 'RowNames', "rusboost");
if exist(['runtimes' filesep 'hyperparam_tuning_runtimes_first_day.mat'])
    load(['runtimes' filesep 'hyperparam_tuning_runtimes_first_day']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'hyperparam_tuning_runtimes_first_day'], 'runtimes')

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_first_day_roi_rusboost.mat'],...
    'results', 'best_params');

%% Model fitting function
function model = rusboost(data, labels, params)
    t = templateTree('Reproducible',true, ...
        'MaxNumSplits', params.MaxNumSplits, ...
        'MinLeafSize', params.MinLeafSize, ...
        'SplitCriterion', char(params.SplitCriterion));

    model = compact(fitcensemble(data, labels, 'Method', 'RUSBoost', ...
        'Learners', t, 'Cost', [0 1; params.fncost 0], ...
        'NumLearningCycles', params.NumLearningCycles, ...
        'LearnRate', params.LearnRate));
end
