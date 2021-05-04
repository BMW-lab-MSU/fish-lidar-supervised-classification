%% Configuration
box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/Yellowstone';

%% Setup
addpath('../common');
%clear

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);

n_observations = length(training_data);

%% Tune SVM hyperparameters

optimize_vars = [
   optimizableVariable('lambda',[1e-5,1e5]/n_observations,'Transform','log'),...
   optimizableVariable('regularization', {'ridge', 'lasso'}),...
   optimizableVariable('fncost', [1 20], 'Type', 'integer')
];

sampling_params.undersampling_ratio = 0.2;
sampling_params.oversampling_beta = 0.25;

minfun = @(hyperparams)cvobjfun(@fitlinear, hyperparams, ...
    sampling_params, crossval_partition, training_data, training_labels);

results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 25);


%% Model fitting function
function model = fitlinear(data, labels, params)
    model = fitclinear(data, labels, ...
        'Cost', [0 1; params.fncost 0], 'Lambda', params.lambda, ...
        'Regularization', char(params.regularization)); 
end
