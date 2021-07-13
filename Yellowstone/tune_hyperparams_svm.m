% SPDX-License-Identifier: BSD-3-Clause
%% Configuration
box_dir = '/mnt/data/trevor/research/afrl/data/AFRL_Data/Data/Yellowstone';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

load([box_dir filesep 'training' filesep 'sampling_tuning_roi_svm.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

n_observations = length(training_data);

%% Tune SVM hyperparameters

optimize_vars = [
%    optimizableVariable('lambda',[1e-5,1e5]/n_observations,'Transform','log'),...
%    optimizableVariable('regularization', {'ridge', 'lasso'}),...
   optimizableVariable('fncost', [1 20], 'Type', 'integer')
];

minfun = @(hyperparams)cvobjfun_roi(@svm, hyperparams, ...
    undersampling_ratio, crossval_partition, training_data, ...
    training_labels, training_roi_indicator);

t0 = tic;
results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);
runtime = toc(t0);

% save runtimes
tab = table(runtime, 'VariableNames', "hyperparam_tuning", 'RowNames', "svm");
if exist(['runtimes' filesep 'hyperparam_tuning_runtimes.mat'])
    load(['runtimes' filesep 'hyperparam_tuning_runtimes']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'hyperparam_tuning_runtimes'], 'runtimes')

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_svm.mat'],...
    'results', 'best_params');

%% Model fitting function
function model = svm(data, labels, params)
    model = fitclinear(data, labels, ...
        'Cost', [0 1; params.fncost 0]); 
    % model = fitclinear(data, labels, ...
    %     'Cost', [0 1; params.fncost 0], 'Lambda', params.lambda, ...
    %     'Regularization', char(params.regularization)); 
end
