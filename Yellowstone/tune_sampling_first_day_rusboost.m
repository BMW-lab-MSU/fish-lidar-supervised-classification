%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

%% Tune sampling ratios
tic
result = tune_sampling_roi_base(@rusboost, training_roi_data, ...
    training_roi_labels, training_roi_indicator, crossval_partition, ...
    'Progress', true);
runtime = toc;

% save runtimes
tab = table(runtime, 'VariableNames', "sampling_tuning_runtime", 'RowNames', "rusboost");
if exist(['runtimes' filesep 'sampling_tuning_runtimes'])
    runtimes_tab = load(['runtimes' filesep 'sampling_tuning_runtimes']);
    runtimes_tab = [runtimes_tab; tab];
else
    runtimes_tabl = tab;
    mkdir('runtimes');
end
runtimes_tab = load(['runtimes' filesep 'sampling_tuning_runtimes']);
runtimes_tab = [runtimes_tab; tab];
save('sampling_tuning_runtimes', 'runtimes_tab')

save([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_rusboost.mat'], 'result')

%% Model fitting function
function model = rusboost(data, labels, ~)
    t = templateTree('Reproducible',true);
    model = compact(fitcensemble(data, labels, 'Method', 'RUSBoost', 'Learners', t));
end
