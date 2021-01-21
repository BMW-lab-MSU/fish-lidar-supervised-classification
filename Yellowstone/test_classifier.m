%% setup
% load data and classifier
addpath('../common')

box_dir = '../../data/';

data2015 = load([box_dir filesep 'processed_data_2015'], 'xpol_processed', 'labels');
data2016 = load([box_dir filesep 'processed_data_2016'], 'xpol_processed', 'labels');

load([box_dir filesep 'rusBoost']);

%% constants used when creating grouping labels into regions of interest
WINDOW_SIZE = 1000;
OVERLAP = 0.1;
TRUE_LABEL_THRESHOLD = 1;
PREDICTED_LABEL_THRESHOLD = 10;

%% 2015 results
results2015.Shot.PredictedLabels = rusBoost.predictFcn(data2015.xpol_processed');
results2015.Shot.Labels = data2015.labels;
results2015.Shot.Confusion = confusionmat(results2015.Shot.Labels, results2015.Shot.PredictedLabels);
[~, precision, recall, f3] = analyze_confusion(results2015.Shot.Confusion);
results2015.Shot.Precision = precision;
results2015.Shot.Recall = recall;
results2015.Shot.F3 = f3;

results2015.Roi.PredictedLabels = groupLabels(results2015.Shot.PredictedLabels, ...
    PREDICTED_LABEL_THRESHOLD, WINDOW_SIZE, OVERLAP);
results2015.Roi.Labels = groupLabels(results2015.Shot.Labels, TRUE_LABEL_THRESHOLD, ...
    WINDOW_SIZE, OVERLAP);
results2015.Roi.Confusion = confusionmat(results2015.Roi.Labels, results2015.Roi.PredictedLabels);
[~, precision, recall, f3] = analyze_confusion(results2015.Roi.Confusion);
results2015.Roi.Precision = precision;
results2015.Roi.Recall = recall;
results2015.Roi.F3 = f3;

%% 2016 results
results2016.Shot.PredictedLabels = rusBoost.predictFcn(data2016.xpol_processed');
results2016.Shot.Labels = data2016.labels;
results2016.Shot.Confusion = confusionmat(results2016.Shot.Labels, results2016.Shot.PredictedLabels);
[~, precision, recall, f3] = analyze_confusion(results2016.Shot.Confusion);
results2016.Shot.Precision = precision;
results2016.Shot.Recall = recall;
results2016.Shot.F3 = f3;

results2016.Roi.PredictedLabels = groupLabels(results2016.Shot.PredictedLabels, ...
    PREDICTED_LABEL_THRESHOLD, WINDOW_SIZE, OVERLAP);
results2016.Roi.Labels = groupLabels(results2016.Shot.Labels, TRUE_LABEL_THRESHOLD, ...
    WINDOW_SIZE, OVERLAP);
results2016.Roi.Confusion = confusionmat(results2016.Roi.Labels, results2016.Roi.PredictedLabels);
[~, precision, recall, f3] = analyze_confusion(results2016.Roi.Confusion);
results2016.Roi.Precision = precision;
results2016.Roi.Recall = recall;
results2016.Roi.F3 = f3;

%% display and save results
disp('2015 results')
disp('shot')
disp(results2015.Shot)
disp(results2015.Shot.Confusion)
disp('roi')
disp(results2015.Roi)
disp(results2015.Roi.Confusion)

disp('2016 results')
disp('shot')
disp(results2016.Shot)
disp(results2016.Shot.Confusion)
disp('roi')
disp(results2016.Roi)
disp(results2016.Roi.Confusion)

save([box_dir filesep 'results'], 'results2015', 'results2016')
