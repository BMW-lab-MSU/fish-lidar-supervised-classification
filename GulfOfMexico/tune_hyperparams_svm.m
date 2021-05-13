%% Configuration
box_dir = '../../AFRL_Data/Data/GulfOfMexico';

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
   optimizableVariable('lambda',[1e-5,1e5]/n_observations,'Transform','log'),...
   optimizableVariable('regularization', {'ridge', 'lasso'}),...
   optimizableVariable('fncost', [1 20], 'Type', 'integer')
];

minfun = @(hyperparams)cvobjfun_roi(@svm, hyperparams, ...
    undersampling_ratio, crossval_partition, training_data, ...
    training_labels, training_roi_indicator);

results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);

best_params = bestPoint(results);

save([box_dir filesep 'training' filesep 'hyperparameter_tuning_roi_svm.mat'],...
    'results', 'best_params', '-v7.3');

%% Model fitting function
function model = svm(data, labels, params)
    model = fitclinear(data, labels, ...
        'Cost', [0 1; params.fncost 0], 'Lambda', params.lambda, ...
        'Regularization', char(params.regularization)); 
end
