%% Setup
addpath('../common');
%clear

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/Yellowstone';

% pool = parpool();
% statset('UseParallel', true);

%% Load data
load([box_dir filesep 'training' filesep 'training_data.mat']);

%% Coarse grid search to determine general search area

UNDERSAMPLING_RATIO = 0:0.2:0.8;
OVERSAMPLING_BETA = 0:0.25:1;

% Create the grid
[under, over] = ndgrid(UNDERSAMPLING_RATIO, OVERSAMPLING_BETA);
under = reshape(under, 1, numel(under));
over = reshape(over, 1, numel(over));

% Preallocate data structures for grid search results
svm_objective = zeros(1, numel(under));
svm_userdata = cell(1, numel(under));
tree_objective = zeros(1, numel(under));
tree_userdata = cell(1, numel(under));
naivebayes_objective = zeros(1, numel(under));
naivebayes_userdata = cell(1, numel(under));
nnet_objective = zeros(1, numel(under));
nnet_userdata = cell(1, numel(under));
lda_objective = zeros(1, numel(under));
lda_userdata = cell(1, numel(under));
rusboost_objective = zeros(1, numel(under));
rusboost_userdata = cell(1, numel(under));

% Train SVM
disp('SVM: coarse search')
for i = 1:numel(under)
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [svm_objective(i), ~, svm_userdata{i}] = cvobjfun(@fitlinear, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(svm_objective);
svm.objective = svm_objective;
svm.userdata = svm_userdata;
svm.undersampling_ratio = under(minf3idx);
svm.oversampling_beta = over(minf3idx);


% Train decision tree
disp('tree: coarse search')
for i = 1:numel(under)
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [tree_objective(i), ~, tree_userdata{i}] = cvobjfun(@fittree, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(tree_objective);
tree.objective = tree_objective;
tree.userdata = tree_userdata;
tree.undersampling_ratio = under(minf3idx);
tree.oversampling_beta = over(minf3idx);

% Train Naive Bayes
disp('Naive Bayes: coarse search')
for i = 1:numel(under)
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [nb_objective(i), ~, nb_userdata{i}] = cvobjfun(@fitnb, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(nb_objective);
nb.objective = nb_objective;
nb.userdata = nb_userdata;
nb.undersampling_ratio = under(minf3idx);
nb.oversampling_beta = over(minf3idx);

% Train RUSBoost
disp('RUSBoost: coarse search')
for i = 1:numel(under)
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [rusboost_objective(i),~,rusboost_userdata{i}] = cvobjfun(@fitrusboost, ... 
        params, crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(rusboost_objective);
rusboost.objective = rusboost_objective;
rusboost.userdata = rusboost_userdata;
rusboost.undersampling_ratio = under(minf3idx);
rusboost.oversampling_beta = over(minf3idx);

% Train LDA
disp('LDA: coarse search')
for i = 1:numel(under)
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [lda_objective(i), ~, lda_userdata{i}] = cvobjfun(@fitlda, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(lda_objective);
lda.objective = lda_objective;
lda.userdata = lda_userdata;
lda.undersampling_ratio = under(minf3idx);
lda.oversampling_beta = over(minf3idx);

% Train neural net
disp('neural net: coarse search')
for i = 1:numel(under)
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [nnet_objective(i), ~, nnet_userdata{i}] = cvobjfun(@fitnnet, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(nnet_objective);
nnet.objective = nnet_objective;
nnet.userdata = nnet_userdata;
nnet.undersampling_ratio = under(minf3idx);
nnet.oversampling_beta = over(minf3idx);


save('tune_sampling_coarse.mat', 'svm', 'tree', 'nb', 'rusboost', 'lda', 'nnet');



%% Fine grid search
% We search around the coarse results using 0.05 increments of the coarse.
% When the coarse results were 0, we search between [0, 0.2]. Each search parameter
% has five uniformly-spaced search values (grid size = 25).

GRID_SIZE = 25;

% Preallocate data structures for grid search results
svm_objective = zeros(1, GRID_SIZE);
svm_userdata = cell(1, GRID_SIZE);
tree_objective = zeros(1, GRID_SIZE);
tree_userdata = cell(1, GRID_SIZE);
naivebayes_objective = zeros(1, GRID_SIZE);
naivebayes_userdata = cell(1, GRID_SIZE);
nnet_objective = zeros(1, GRID_SIZE);
nnet_userdata = cell(1, GRID_SIZE);
lda_objective = zeros(1, GRID_SIZE);
lda_userdata = cell(1, GRID_SIZE);
rusboost_objective = zeros(1, GRID_SIZE);
rusboost_userdata = cell(1, GRID_SIZE);

% Train SVM
disp('SVM: fine search')

[under, over] = ndgrid([0, 0.05, 0.1, 0.15, 0.2],[0.15, 0.2, 0.25, 0.3, 0.35]);
under = reshape(under, 1, numel(under));
over = reshape(over, 1, numel(over));

for i = 1:GRID_SIZE
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [svm_objective(i), ~, svm_userdata{i}] = cvobjfun(@fitlinear, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(svm_objective);
svm.objective = svm_objective;
svm.userdata = svm_userdata;
svm.undersampling_ratio = under(minf3idx);
svm.oversampling_beta = over(minf3idx);


% Train decision tree
disp('tree: fine search')

[under, over] = ndgrid([0.3, 0.35, 0.4, 0.45, 0.5],[0.15, 0.2, 0.25, 0.3, 0.35]);
under = reshape(under, 1, numel(under));
over = reshape(over, 1, numel(over));

for i = 1:GRID_SIZE
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [tree_objective(i), ~, tree_userdata{i}] = cvobjfun(@fittree, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(tree_objective);
tree.objective = tree_objective;
tree.userdata = tree_userdata;
tree.undersampling_ratio = under(minf3idx);
tree.oversampling_beta = over(minf3idx);

% Train Naive Bayes
disp('Naive Bayes: fine search')

[under, over] = ndgrid([0.7, 0.75, 0.8, 0.85, 0.9] ,[0.15, 0.2, 0.25, 0.3, 0.35]);
under = reshape(under, 1, numel(under));
over = reshape(over, 1, numel(over));

for i = 1:GRID_SIZE
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [nb_objective(i), ~, nb_userdata{i}] = cvobjfun(@fitnb, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(nb_objective);
nb.objective = nb_objective;
nb.userdata = nb_userdata;
nb.undersampling_ratio = under(minf3idx);
nb.oversampling_beta = over(minf3idx);

% Train RUSBoost
disp('RUSBoost: fine search')

[under, over] = ndgrid([0.3, 0.35, 0.4, 0.45, 0.5] ,[0, 0.05, 0.1, 0.15, 0.2]);
under = reshape(under, 1, numel(under));
over = reshape(over, 1, numel(over));

for i = 1:GRID_SIZE
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [rusboost_objective(i),~,rusboost_userdata{i}] = cvobjfun(@fitrusboost, ... 
        params, crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(rusboost_objective);
rusboost.objective = rusboost_objective;
rusboost.userdata = rusboost_userdata;
rusboost.undersampling_ratio = under(minf3idx);
rusboost.oversampling_beta = over(minf3idx);

% Train LDA
disp('LDA: fine search')

[under, over] = ndgrid([0.7, 0.75, 0.8, 0.85, 0.9] ,[0, 0.05, 0.1, 0.15, 0.2]);
under = reshape(under, 1, numel(under));
over = reshape(over, 1, numel(over));

for i = 1:GRID_SIZE
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [lda_objective(i), ~, lda_userdata{i}] = cvobjfun(@fitlda, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(lda_objective);
lda.objective = lda_objective;
lda.userdata = lda_userdata;
lda.undersampling_ratio = under(minf3idx);
lda.oversampling_beta = over(minf3idx);

% Train neural net
disp('neural net: fine search')

[under, over] = ndgrid([0.1, 0.15, 0.2, 0.25, 0.3] ,[0.15, 0.2, 0.25, 0.3, 0.35]);
under = reshape(under, 1, numel(under));
over = reshape(over, 1, numel(over));

for i = 1:GRID_SIZE
    params = struct('undersampling_ratio', under(i), ...
        'oversampling_beta', over(i));

    [nnet_objective(i), ~, nnet_userdata{i}] = cvobjfun(@fitnnet, params, ...
        crossval_partition, training_data, training_labels);
end
[minf3, minf3idx] = min(nnet_objective);
nnet.objective = nnet_objective;
nnet.userdata = nnet_userdata;
nnet.undersampling_ratio = under(minf3idx);
nnet.oversampling_beta = over(minf3idx);


save('tune_sampling_fine.mat', 'svm', 'tree', 'nb', 'rusboost', 'lda', 'nnet');



%% Model fitting functions
function model = fitlinear(data, labels, params)
    model = fitclinear(data, labels); 
end

function model = fittree(data, labels, params)
    model = fitctree(data, labels);
end

function model = fitnb(data, labels, params)
    model = fitcnb(data, labels);
end

function model = fitrusboost(data, labels, params)
    t = templateTree('Reproducible',true);
    model = fitcensemble(data, labels, 'Method', 'RUSBoost', 'Learners', t);
end

function model = fitlda(data, labels, params)
    model = fitcdiscr(data, labels);
end

function model = fitnnet(data, labels, params)
    model = fitcnet(data, labels, "Standardize", true);
end
