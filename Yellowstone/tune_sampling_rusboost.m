% SPDX-License-Identifier: BSD-3-Clause
%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '../../data/fish-lidar/Yellowstone';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'roi_training_data.mat']);

%% Tune sampling ratios
t0 = tic;
result = tune_sampling_roi_base(@rusboost, training_data, ...
    training_labels, training_roi_indicator, crossval_partition, ...
    'Progress', true);
runtime = toc(t0);

% save runtime
tab = table(runtime, 'VariableNames', "sampling_tuning", 'RowNames', "rusboost");
if exist(['runtimes' filesep 'sampling_tuning_runtimes.mat'])
    load(['runtimes' filesep 'sampling_tuning_runtimes']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'sampling_tuning_runtimes'], 'runtimes')

save([box_dir filesep 'training' filesep 'sampling_tuning_roi_rusboost.mat'], 'result')

%% Model fitting function
function model = rusboost(data, labels, ~)
    t = templateTree('Reproducible',true);
    model = compact(fitcensemble(data, labels, 'Method', 'RUSBoost', 'Learners', t));
end
