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
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

load([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_lda.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

%% Tune LDA hyperparameters

optimize_vars = [
   optimizableVariable('delta',[1e-6,1e3], 'Transform','log'),...
   optimizableVariable('gamma', [0, 1]),...
   optimizableVariable('fncost', [1 20], 'Type', 'integer')
];

minfun = @(hyperparams)cvobjfun_roi(@lda, hyperparams, undersampling_ratio, ...
    crossval_partition, training_roi_data, training_roi_labels, ...
    training_roi_indicator);

t0 = tic;
results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);
runtime = toc(t0);

% save runtimes
tab = table(runtime, 'VariableNames', "hyperparam_tuning_first_day", 'RowNames', "lda");
if exist(['runtimes' filesep 'hyperparam_tuning_runtimes_first_day.mat'])
    load(['runtimes' filesep 'hyperparam_tuning_runtimes_first_day']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'hyperparam_tuning_runtimes_first_day'], 'runtimes')

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_first_day_roi_lda.mat'],...
    'results', 'best_params', '-v7.3');

%% Model fitting function
function model = lda(data, labels, params)
    model = compact(fitcdiscr(data, labels, 'DiscrimType', 'pseudoLinear', ...
        'Cost', [0 1; params.fncost 0], 'Delta', params.delta, ...
        'Gamma', params.gamma));
    % model = compact(fitcdiscr(data, labels, 'DiscrimType', 'pseudoLinear', ...
    %     'Cost', [0 1; params.fncost 0]));
end
