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
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

load([box_dir filesep 'training' filesep 'sampling_tuning_roi_lda.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

%% Tune LDA hyperparameters

optimize_vars = [
   optimizableVariable('delta',[1e-6,1e3], 'Transform','log'),...
   optimizableVariable('gamma', [0, 1]),...
   optimizableVariable('fncost', [1 20], 'Type', 'integer')
];

minfun = @(hyperparams)cvobjfun_roi(@lda, hyperparams, undersampling_ratio, ...
    crossval_partition, training_data, training_labels, ...
    training_roi_indicator);

t0 = tic;
results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);
runtime = toc(t0);

% save runtimes
tab = table(runtime, 'VariableNames', "hyperparam_tuning", 'RowNames', "lda");
if exist(['runtimes' filesep 'hyperparam_tuning_runtimes.mat'])
    load(['runtimes' filesep 'hyperparam_tuning_runtimes']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'hyperparam_tuning_runtimes'], 'runtimes')

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_lda.mat'],...
    'results', 'best_params');

%% Model fitting function
function model = lda(data, labels, params)
    model = compact(fitcdiscr(data, labels, 'DiscrimType', 'pseudoLinear', ...
        'Cost', [0 1; params.fncost 0], 'Delta', params.delta, ...
        'Gamma', params.gamma));
    % model = compact(fitcdiscr(data, labels, 'DiscrimType', 'pseudoLinear', ...
    %     'Cost', [0 1; params.fncost 0]));
end
