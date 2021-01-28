%%
addpath('../common')

%% Setup data paths
box_dir = '/mnt/data/trevor/research/afrl/box/Data/GulfOfMexico/processed data';

datapaths = {
    [box_dir filesep 'processed_data_09-24'],
    [box_dir filesep 'processed_data_09-25'],
    [box_dir filesep 'processed_data_09-26'],
    [box_dir filesep 'processed_data_09-29'],
    [box_dir filesep 'processed_data_09-30'],
    [box_dir filesep 'processed_data_10-01'],
    [box_dir filesep 'processed_data_10-02'],
    [box_dir filesep 'processed_data_10-03'],
    [box_dir filesep 'processed_data_10-04'],
    [box_dir filesep 'processed_data_10-05'],
    [box_dir filesep 'processed_data_10-07'],
};

%% Load the classifier
disp('loading classifier')
trained_model_dir = box_dir;
load([trained_model_dir filesep 'rusBoost']);

%% Region of interest parameters
WINDOW_SIZE = 1000;
OVERLAP = 0.1;
TRUE_LABEL_THRESHOLD = 1;
PREDICTED_LABEL_THRESHOLD = 10;

%% Run the classifier on each day
results = containers.Map();

for datapath_idx = 1:numel(datapaths)
    datapath = datapaths{datapath_idx};
    date = datapath(end-4:end);

    disp(['running on ' date '...']);

    disp('loading data...')
    load(datapath, 'xpol_processed', 'labels');
    
    % turn labels into binary labels: nothing or any of {fish, school}
    labels = any(labels(1:2,:));

    disp('classifying...')
    shot.Labels = labels;
    shot.PredictedLabels = logical(rusBoost.predictFcn(xpol_processed.'));
    shot.Confusion = confusionmat(shot.Labels, shot.PredictedLabels);
    [~, precision, recall, f3] = analyze_confusion(shot.Confusion);
    shot.Precision = precision;
    shot.Recall = recall;
    shot.F3 = f3;

    roi.Labels = groupLabels(labels, TRUE_LABEL_THRESHOLD, WINDOW_SIZE, OVERLAP);
    roi.PredictedLabels = groupLabels(shot.PredictedLabels, ...
        PREDICTED_LABEL_THRESHOLD, WINDOW_SIZE, OVERLAP);
    roi.Confusion = confusionmat(roi.Labels, roi.PredictedLabels);
    [~, precision, recall, f3] = analyze_confusion(roi.Confusion);
    roi.Precision = precision;
    roi.Recall = recall;
    roi.F3 = f3;

    results(date) = struct('Shot', shot, 'Roi', roi);
end

%% Create summary of results from all days
shot = struct();
roi = struct();
roi.F3 = 0;
roi.Recall = 0;
roi.Precision = 0;
roi.Confusion = zeros(2);
shot.F3 = 0;
shot.Recall = 0;
shot.Precision = 0;
shot.Confusion = zeros(2);

disp('computing average results');
for date = results.keys
    shot.Precision = shot.Precision + results(date{:}).Shot.Precision;
    shot.Recall = shot.Recall + results(date{:}).Shot.Recall;
    shot.F3 = shot.F3 + results(date{:}).Shot.F3;
    shot.Confusion = shot.Confusion + results(date{:}).Shot.Confusion;

    roi.Precision = roi.Precision + results(date{:}).Roi.Precision;
    roi.Recall = roi.Recall + results(date{:}).Roi.Recall;
    roi.F3 = roi.F3 + results(date{:}).Roi.F3;
    roi.Confusion = roi.Confusion + results(date{:}).Roi.Confusion;
end

% average results
shot.Precision = shot.Precision / double(results.Count);
shot.Recall = shot.Recall / double(results.Count);
shot.F3 = shot.F3 / double(results.Count);
roi.Precision = roi.Precision / double(results.Count);
roi.Recall = roi.Recall / double(results.Count);
roi.F3 = roi.F3 / double(results.Count);

results('average') = struct('Shot', shot, 'Roi', roi);

save('results', 'results', '-v7.3');

%% Display results
for date = results.keys
    disp([date{:} ' results'])
    disp('shot')
    disp(results(date{:}).Shot)
    disp(results(date{:}).Shot.Confusion)
    disp('roi')
    disp(results(date{:}).Roi)
    disp(results(date{:}).Roi.Confusion)
end
