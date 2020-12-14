%% Choose classifier
% Choose which classifier to use by finding which one has the highest f2 score 
% on regions of interest in the data that is a superset of the training data

%% Constants
TRUE_LABEL_THRESHOLD = 1;
PREDICTED_LABEL_THRESHOLD = 10;
WINDOW_SIZE = 1000;
OVERLAP = 0.05;

%% Load data
box_dir = '/mnt/data/trevor/research/AFRL/Box/Data/Yellowstone';
data_filename = 'processed_data_2015_max_surface';
trained_models_dir = 'trained_models_max_surface_2015';

data = load([box_dir filesep data_filename], 'xpol_processed', 'labels');

% get the names of all the trained model mat files
trained_models = what(trained_models_dir);
trained_models = trained_models.mat;


%% Run models on the data
results = containers.Map;

for i = 1:numel(trained_models)
    classifier = load([trained_models_dir filesep trained_models{i}]);
    file_info = whos('-file', [trained_models_dir filesep trained_models{i}]);
    model_name = file_info.name;

    disp(['running ' model_name])

    predicted_labels = classifier.(model_name).predictFcn(data.xpol_processed');

    % analyize results for each lidar shot
    confusion = confusionmat(data.labels, predicted_labels);
    [~, precision, recall, f2] = analyze_confusion(confusion);

    shot = struct('Confusion', confusion, 'F2', f2, ...
        'Precison', precision, 'Recall', recall, ...
        'HumanLabels', data.labels, 'PredictedLabels', predicted_labels);

    % analyize results for regions of interest
    labels_roi = groupLabels(data.labels, ...
        TRUE_LABEL_THRESHOLD, WINDOW_SIZE, OVERLAP);
    predicted_labels_roi = groupLabels(predicted_labels, ...
        PREDICTED_LABEL_THRESHOLD, WINDOW_SIZE, OVERLAP);

    confusion_roi = confusionmat(labels_roi, predicted_labels_roi);
    [~, precision_roi, recall_roi, f2_roi] = analyze_confusion(confusion_roi);

    roi = struct('Confusion', confusion_roi, 'F2', f2_roi, ...
        'Precison', precision_roi, 'Recall', recall_roi, ...
        'HumanLabels', labels_roi, 'PredictedLabels', predicted_labels_roi);

    results(model_name) = struct('shot', shot, 'roi', roi);
end

%% Find which classifier has the best performance
max_f2 = intmin;
best_model = '';

for model = results.keys
    if results(model{:}).roi.F2 >= max_f2
        max_f2 = results(model{:}).roi.F2;
        best_model = model{:};
    end
end

disp('Best model:')
disp(best_model)
disp('')
disp('shot results:')
disp(results(best_model).shot)
disp('    confusion')
disp(results(best_model).shot.Confusion)
disp('')
disp('roi results:')
disp(results(best_model).roi)
disp('    confusion')
disp(results(best_model).roi.Confusion)