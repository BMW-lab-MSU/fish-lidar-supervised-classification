%% Setup
addpath('../common');

box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/GulfOfMexico';

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);
training_data = training_data';
training_labels = training_labels';

%% Compute knn indices for each cross validation set
N_NEIGHBORS_CONSTRUCTION = 50;
N_NEIGHBORS = 5;

knn_index_full = cell(1, crossval_partition.NumTestSets);
knn_index_minority = cell(1, crossval_partition.NumTestSets);

for i = 1:crossval_partition.NumTestSets
    training_set = training(crossval_partition, i);
    data = training_data(training_set, :);
    labels = training_labels(training_set, :);

    disp(['partition ' num2str(i) ' full index'])
    tmp = knnindex(data, ...
        N_NEIGHBORS_CONSTRUCTION, 'Method', 'nndescent');
    
    knn_index_full{i} = tmp(labels == 1, 1:N_NEIGHBORS);

    disp(['partition ' num2str(i) ' minority class index'])
    knn_index_minority{i} = knnindex(...
        data(labels == 1, :), ...
        N_NEIGHBORS_CONSTRUCTION, 'Method', 'nndescent');
    
    knn_index_minority{i} = knn_index_minority{i}(:, 1:N_NEIGHBORS);
end

save([box_dir filesep 'training' filesep 'training_data_knn_indices'], 'knn_index_full', 'knn_index_minority');