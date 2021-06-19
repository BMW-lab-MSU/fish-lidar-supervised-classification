%% Setup
addpath('../common');
%clear
rng(0, 'twister');

box_dir = '/mnt/data/trevor/research/afrl/data/AFRL_Data/Data/Yellowstone';

%pool = parpool();
%statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'first_day_roi_training_data.mat']);

%% Tune sampling ratios
t0 = tic;
result = tune_sampling_roi_base(@lda, training_roi_data, ...
    training_roi_labels, training_roi_indicator, crossval_partition, ...
    'Progress', true);
runtime = toc(t0);

% save runtimes
tab = table(runtime, 'VariableNames', "sampling_tuning_first_day", 'RowNames', "lda");
if exist(['runtimes' filesep 'sampling_tuning_runtimes_first_day.mat'])
    load(['runtimes' filesep 'sampling_tuning_runtimes_first_day']);
    runtimes = [runtimes; tab];
else
    runtimes = tab;
    mkdir('runtimes');
end
save(['runtimes' filesep 'sampling_tuning_runtimes_first_day'], 'runtimes')

save([box_dir filesep 'training' filesep 'sampling_tuning_first_day_roi_lda.mat'], 'result')

%% Model fitting function
function model = lda(data, labels, ~)
    model = compact(fitcdiscr(data, labels, 'DiscrimType', 'pseudolinear'));
end
