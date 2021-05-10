%% Setup
clear
addpath('../common')

box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';

%% Load data
load([box_dir filesep 'testing' filesep 'testing_data.mat']);
testing_data = testing_data';
testing_labels = testing_labels';

%% Test SVM
% load([box_dir filesep 'training' filesep 'models' filesep 'svm.mat'], 'model');

% svm.pred_labels = predict(svm, testing_data);

% svm.confusion = confusionmat(testing_labels, ...
%     svm.pred_labels);

% [a, p, r, f3] = analyze_confusion(svm.confusion);
% svm.accuracy = a;
% svm.precision = p;
% svm.recall = r;
% svm.f3 = f3;

% disp(svm)

%% Test LDA
load([box_dir filesep 'training' filesep 'models' filesep 'lda.mat'], 'model');

lda.pred_labels = predict(model, testing_data);

lda.confusion = confusionmat(testing_labels, lda.pred_labels);

[a, p, r, f3] = analyze_confusion(lda.confusion);
lda.accuracy = a;
lda.precision = p;
lda.recall = r;
lda.f3 = f3;

disp(lda)

%% Test neural net
load([box_dir filesep 'training' filesep 'models' filesep 'nnet.mat'], 'model');

nnet.pred_labels = predict(model, testing_data);

nnet.confusion = confusionmat(testing_labels, nnet.pred_labels);

[a, p, r, f3] = analyze_confusion(nnet.confusion);
nnet.accuracy = a;
nnet.precision = p;
nnet.recall = r;
nnet.f3 = f3;

disp(nnet)

%% Test decision tree
load([box_dir filesep 'training' filesep 'models' filesep 'tree.mat'], 'model');

tree.pred_labels = predict(model, testing_data);

tree.confusion = confusionmat(testing_labels, tree.pred_labels);

[a, p, r, f3] = analyze_confusion(tree.confusion);
tree.accuracy = a;
tree.precision = p;
tree.recall = r;
tree.f3 = f3;

disp(tree)

%% Test RUSBoost
load([box_dir filesep 'training' filesep 'models' filesep 'rusboost.mat'], 'model');

rusboost.pred_labels = predict(model, testing_data);

rusboost.confusion = confusionmat(testing_labels, ...
    rusboost.pred_labels);

[a, p, r, f3] = analyze_confusion(rusboost.confusion);
rusboost.accuracy = a;
rusboost.precision = p;
rusboost.recall = r;
rusboost.f3 = f3;

disp(rusboost)


%% Save results
save([box_dir filesep 'testing' filesep 'results.mat'], 'results', '-v7.3');