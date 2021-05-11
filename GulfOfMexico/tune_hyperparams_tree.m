%% Configuration
box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/GulfOfMexico';

%% Setup
addpath('../common');
%clear
rng(0, 'twister');

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

load([box_dir filesep 'training' filesep 'sampling_tuning_roi_tree.mat'])
undersampling_ratio = result.undersampling_ratio
clear result

%% Tune tree hyperparameters
n_observations = length(training_data);

optimize_vars = [
   optimizableVariable('MaxNumSplits',[1,max(2, n_observations - 1)],'Transform','log'),...
   optimizableVariable('MinLeafSize',[1,max(2, floor(n_observations/2))],'Transform','log'),...
   optimizableVariable('SplitCriterion', {'gdi', 'deviance'}),...
   optimizableVariable('fncost', [1 20], 'Type', 'integer')
];

minfun = @(hyperparams)cvobjfun_roi(@tree, hyperparams, ...
    undersampling_ratio, crossval_partition, training_data, ...
    training_labels, training_roi_indicator);

results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_tree.mat'],...
    'results', 'best_params');

%% Model fitting function
function model = tree(data, labels, params)
    model = compact(fitctree(data, labels, 'Cost', [0 1; params.fncost 0],...
        'MaxNumSplits', params.MaxNumSplits, ...
        'MinLeafSize', params.MinLeafSize, ...
        'SplitCriterion', char(params.SplitCriterion)));
    % model = compact(fitctree(data, labels, 'Cost', [0 1; params.fncost 0]));
end
