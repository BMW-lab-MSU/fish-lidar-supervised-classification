%% Configuration
box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

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

load([box_dir filesep 'training' filesep 'tune_sampling_rusboost.mat'])
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

minfun = @(hyperparams)cvobjfun(@rusboost, hyperparams, undersampling_ratio, ...
    crossval_partition, training_data, training_labels);

results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 30);

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_rusboost.mat'],...
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
