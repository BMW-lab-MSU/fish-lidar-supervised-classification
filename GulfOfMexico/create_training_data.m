%% Setup
clear
box_dir = '/mnt/data/trevor/research/afrl/box/Data/GulfOfMexico/processed data';
input_data_filename = 'processed_data_09-24';
training_data_filename = 'training_data_09-24_undersampled75_no_plankton';

load([box_dir filesep input_data_filename], 'xpol_processed', 'labels')

%% Create binary classification labels
% label indices: 1 = single fish, 2 = fish schools, 3 = jellyfish, 4 = plankton
labels = any(labels(1:3,:));

%% Undersample the majority class
UNDERSAMPLING_RATIO = 0.75;

no_fish = find(labels == 0);
shots_to_remove = no_fish(randperm(numel(no_fish), ceil(UNDERSAMPLING_RATIO * numel(no_fish))));

xpol_processed(:,shots_to_remove) = [];
labels(shots_to_remove) = [];

%% Save training data
data.xpol_processed = xpol_processed;
data.labels = labels;
save([box_dir filesep training_data_filename], 'data')
