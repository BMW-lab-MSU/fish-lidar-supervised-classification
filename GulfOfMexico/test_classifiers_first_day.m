%% Setup
clear
addpath('../common')

box_dir = '/mnt/data/trevor/research/afrl/AFRL_Data/Data/GulfOfMexico';

%% Load data
load([box_dir filesep 'testing' filesep 'first_day_roi_testing_data.mat']);


%% Test SVM
disp('Testing SVM....')
disp('---------------')
disp('')
load([box_dir filesep 'training' filesep 'models' filesep 'svm_first_day.mat']);
load([box_dir filesep 'training' filesep 'roi_label_tuning_first_day_svm.mat']);
n_labels = result.n_labels;
clear result

%%%%%%%%%%%%%%%%%%
% Shot results
%%%%%%%%%%%%%%%%%%
svm.shot.pred_labels = predict(model, cell2mat(testing_roi_data));

svm.shot.confusion = confusionmat(cell2mat(testing_roi_labels), ...
    svm.shot.pred_labels);

[a, p, r, f3] = analyze_confusion(svm.shot.confusion);
svm.shot.accuracy = a;
svm.shot.precision = p;
svm.shot.recall = r;
svm.shot.f3 = f3;

%%%%%%%%%%%%%%%%%%
% ROI results
%%%%%%%%%%%%%%%%%%
% Split labels back into ROIs
svm.roi.pred_labels = mat2cell(svm.shot.pred_labels, ...
    cellfun('length', testing_roi_labels), 1);

% Create ROI indicator labels
svm.roi.pred_indicator = cellfun(@(c) sum(c) >= n_labels, svm.roi.pred_labels);

% Compute metrics
svm.roi.confusion = confusionmat(testing_roi_indicator, svm.roi.pred_indicator);

[a, p, r, f3] = analyze_confusion(svm.roi.confusion);
svm.roi.accuracy = a;
svm.roi.precision = p;
svm.roi.recall = r;
svm.roi.f3 = f3;

%%%%%%%%%%%%%%%%%%
% Display results
%%%%%%%%%%%%%%%%%%
disp('Shot results')
disp(svm.shot.confusion)
disp(svm.shot)
disp('ROI results')
disp(svm.roi.confusion)
disp(svm.roi)

%% Test LDA
disp('')
disp('Testing LDA....')
disp('---------------')
disp('')
load([box_dir filesep 'training' filesep 'models' filesep 'lda_first_day.mat']);
load([box_dir filesep 'training' filesep 'roi_label_tuning_first_day_lda.mat']);
n_labels = result.n_labels;
clear result

%%%%%%%%%%%%%%%%%%
% Shot results
%%%%%%%%%%%%%%%%%%
lda.shot.pred_labels = predict(model, cell2mat(testing_roi_data));

lda.shot.confusion = confusionmat(cell2mat(testing_roi_labels), ...
    lda.shot.pred_labels);

[a, p, r, f3] = analyze_confusion(lda.shot.confusion);
lda.shot.accuracy = a;
lda.shot.precision = p;
lda.shot.recall = r;
lda.shot.f3 = f3;

%%%%%%%%%%%%%%%%%%
% ROI results
%%%%%%%%%%%%%%%%%%
% Split labels back into ROIs
lda.roi.pred_labels = mat2cell(lda.shot.pred_labels, ...
    cellfun('length', testing_roi_labels), 1);

% Create ROI indicator labels
lda.roi.pred_indicator = cellfun(@(c) sum(c) >= n_labels, lda.roi.pred_labels);

% Compute metrics
lda.roi.confusion = confusionmat(testing_roi_indicator, lda.roi.pred_indicator);

[a, p, r, f3] = analyze_confusion(lda.roi.confusion);
lda.roi.accuracy = a;
lda.roi.precision = p;
lda.roi.recall = r;
lda.roi.f3 = f3;

%%%%%%%%%%%%%%%%%%
% Display results
%%%%%%%%%%%%%%%%%%
disp('Shot results')
disp(lda.shot.confusion)
disp(lda.shot)
disp('ROI results')
disp(lda.roi.confusion)
disp(lda.roi)

%% Test neural net
disp('')
disp('Testing neural net....')
disp('----------------------')
disp('')
load([box_dir filesep 'training' filesep 'models' filesep 'nnet_first_day.mat']);
load([box_dir filesep 'training' filesep 'roi_label_tuning_first_day_nnet.mat']);
n_labels = result.n_labels;
clear result

%%%%%%%%%%%%%%%%%%
% Shot results
%%%%%%%%%%%%%%%%%%
nnet.shot.pred_labels = predict(model, cell2mat(testing_roi_data));

nnet.shot.confusion = confusionmat(cell2mat(testing_roi_labels), ...
    nnet.shot.pred_labels);

[a, p, r, f3] = analyze_confusion(nnet.shot.confusion);
nnet.shot.accuracy = a;
nnet.shot.precision = p;
nnet.shot.recall = r;
nnet.shot.f3 = f3;

%%%%%%%%%%%%%%%%%%
% ROI results
%%%%%%%%%%%%%%%%%%
% Split labels back into ROIs
nnet.roi.pred_labels = mat2cell(nnet.shot.pred_labels, ...
    cellfun('length', testing_roi_labels), 1);

% Create ROI indicator labels
nnet.roi.pred_indicator = cellfun(@(c) sum(c) >= n_labels, nnet.roi.pred_labels);

% Compute metrics
nnet.roi.confusion = confusionmat(testing_roi_indicator, nnet.roi.pred_indicator);

[a, p, r, f3] = analyze_confusion(nnet.roi.confusion);
nnet.roi.accuracy = a;
nnet.roi.precision = p;
nnet.roi.recall = r;
nnet.roi.f3 = f3;

%%%%%%%%%%%%%%%%%%
% Display results
%%%%%%%%%%%%%%%%%%
disp('Shot results')
disp(nnet.shot.confusion)
disp(nnet.shot)
disp('ROI results')
disp(nnet.roi.confusion)
disp(nnet.roi)

%% Test decision tree
disp('')
disp('Testing decision tree....')
disp('-------------------------')
disp('')
load([box_dir filesep 'training' filesep 'models' filesep 'tree_first_day.mat']);
load([box_dir filesep 'training' filesep 'roi_label_tuning_first_day_tree.mat']);
n_labels = result.n_labels;
clear result

%%%%%%%%%%%%%%%%%%
% Shot results
%%%%%%%%%%%%%%%%%%
tree.shot.pred_labels = predict(model, cell2mat(testing_roi_data));

tree.shot.confusion = confusionmat(cell2mat(testing_roi_labels), ...
    tree.shot.pred_labels);

[a, p, r, f3] = analyze_confusion(tree.shot.confusion);
tree.shot.accuracy = a;
tree.shot.precision = p;
tree.shot.recall = r;
tree.shot.f3 = f3;

%%%%%%%%%%%%%%%%%%
% ROI results
%%%%%%%%%%%%%%%%%%
% Split labels back into ROIs
tree.roi.pred_labels = mat2cell(tree.shot.pred_labels, ...
    cellfun('length', testing_roi_labels), 1);

% Create ROI indicator labels
tree.roi.pred_indicator = cellfun(@(c) sum(c) >= n_labels, tree.roi.pred_labels);

% Compute metrics
tree.roi.confusion = confusionmat(testing_roi_indicator, tree.roi.pred_indicator);

[a, p, r, f3] = analyze_confusion(tree.roi.confusion);
tree.roi.accuracy = a;
tree.roi.precision = p;
tree.roi.recall = r;
tree.roi.f3 = f3;

%%%%%%%%%%%%%%%%%%
% Display results
%%%%%%%%%%%%%%%%%%
disp('Shot results')
disp(tree.shot.confusion)
disp(tree.shot)
disp('ROI results')
disp(tree.roi.confusion)
disp(tree.roi)

%% Test RUSBoost
disp('')
disp('Testing RUSBoost....')
disp('--------------------')
disp('')
load([box_dir filesep 'training' filesep 'models' filesep 'rusboost_first_day.mat']);
load([box_dir filesep 'training' filesep 'roi_label_tuning_first_day_rusboost.mat']);
n_labels = result.n_labels;
clear result

%%%%%%%%%%%%%%%%%%
% Shot results
%%%%%%%%%%%%%%%%%%
rusboost.shot.pred_labels = predict(model, cell2mat(testing_roi_data));

rusboost.shot.confusion = confusionmat(cell2mat(testing_roi_labels), ...
    rusboost.shot.pred_labels);

[a, p, r, f3] = analyze_confusion(rusboost.shot.confusion);
rusboost.shot.accuracy = a;
rusboost.shot.precision = p;
rusboost.shot.recall = r;
rusboost.shot.f3 = f3;

%%%%%%%%%%%%%%%%%%
% ROI results
%%%%%%%%%%%%%%%%%%
% Split labels back into ROIs
rusboost.roi.pred_labels = mat2cell(rusboost.shot.pred_labels, ...
    cellfun('length', testing_roi_labels), 1);

% Create ROI indicator labels
rusboost.roi.pred_indicator = cellfun(@(c) sum(c) >= n_labels, rusboost.roi.pred_labels);

% Compute metrics
rusboost.roi.confusion = confusionmat(testing_roi_indicator, rusboost.roi.pred_indicator);

[a, p, r, f3] = analyze_confusion(rusboost.roi.confusion);
rusboost.roi.accuracy = a;
rusboost.roi.precision = p;
rusboost.roi.recall = r;
rusboost.roi.f3 = f3;

%%%%%%%%%%%%%%%%%%
% Display results
%%%%%%%%%%%%%%%%%%
disp('Shot results')
disp(rusboost.shot.confusion)
disp(rusboost.shot)
disp('ROI results')
disp(rusboost.roi.confusion)
disp(rusboost.roi)


%% Save results
save([box_dir filesep 'testing' filesep 'results_first_day.mat'], 'svm', 'lda', ...
    'nnet', 'tree', 'rusboost', '-v7.3');