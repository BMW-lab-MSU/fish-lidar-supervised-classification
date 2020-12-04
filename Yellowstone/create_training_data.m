%% Setup
clear
box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';
input_data_filename = 'processed_data_2016';
training_data_filename = 'training_data_2016';

load([box_dir filesep input_data_filename], 'xpol_processed', 'labels')

%% Remove open water shots
%
SHOT_THRESHOLD = 0.10;

shot_avg = mean(sum(xpol_processed));

shots_to_remove = find(sum(xpol_processed) < shot_avg * SHOT_THRESHOLD);

if any(labels(shots_to_remove))
    error('shot containing a fish was removed')
end

xpol_processed(:,shots_to_remove) = [];
labels(shots_to_remove) = [];

%% Save training data
data.xpol_processed = xpol_processed;
data.labels = labels;
save([box_dir filesep training_data_filename], 'data')