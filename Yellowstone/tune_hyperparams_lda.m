%% Configuration
box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

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

results = bayesopt(minfun, optimize_vars, ...
    'IsObjectiveDeterministic', true, 'UseParallel', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'MaxObjectiveEvaluations', 20);

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
