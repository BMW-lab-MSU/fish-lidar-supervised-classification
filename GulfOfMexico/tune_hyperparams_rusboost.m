%% Configuration
box_dir = '/mnt/data/trevor/research/afrl/data/AFRL_Data/Data/GulfOfMexico';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

load([box_dir filesep 'training' filesep 'sampling_tuning_roi_rusboost.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

%% Tune rusboost hyperparameters
n_observations = length(training_data);

optimize_vars = [
   optimizableVariable('NumLearningCycles',[10, 500], 'Transform','log'),...
   optimizableVariable('LearnRate',[1e-3, 1], 'Transform','log'),...
   optimizableVariable('MaxNumSplits',[1,max(2, n_observations - 1)],'Transform','log'),...
   optimizableVariable('MinLeafSize',[1,max(2, floor(n_observations/2))],'Transform','log'),...
   optimizableVariable('SplitCriterion', {'gdi', 'deviance'}),...
   optimizableVariable('fncost', [1 20], 'Type', 'integer')
];

minfun = @(hyperparams)cvobjfun_roi(@rusboost, hyperparams, ...
    undersampling_ratio, crossval_partition, training_data, ...
    training_labels, training_roi_indicator);

t0 = tic;
results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);
runtime = toc(t0);

% save runtimes
tab = table(runtime, 'VariableNames', "hyperparam_tuning", 'RowNames', "rusboost");
if exist(['runtimes' filesep 'hyperparam_tuning_runtimes.mat'])
    load(['runtimes' filesep 'hyperparam_tuning_runtimes']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'hyperparam_tuning_runtimes'], 'runtimes')

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_rusboost.mat'],...
    'results', 'best_params', '-v7.3');

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
