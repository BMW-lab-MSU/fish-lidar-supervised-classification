%% Choose classifier
% Choose which classifier to use by finding which one has the highest f3 score 
% on regions of interest in the data that is a superset of the training data

addpath('../common')

%% Constants
TRUE_LABEL_THRESHOLD = 1;
PREDICTED_LABEL_THRESHOLD = 10;
WINDOW_SIZE = 1000;
OVERLAP = 0.1;

%% Load data
box_dir = '/mnt/data/trevor/research/afrl/box/Data/Yellowstone';
data_filename = 'processed_data_2016';
trained_models_dir = 'trained_models';
trained_model_results_dir = 'trained_model_results';

data = load([box_dir filesep data_filename], 'xpol_processed', 'labels');

% get the names of all the trained model mat files
trained_models = what(trained_models_dir);
trained_models = trained_models.mat;

% get saved results mat file
trained_model_results = what(trained_model_results_dir);
trained_model_results = trained_model_results.mat;



%% Run models on the data
results = containers.Map;

if isempty(trained_model_results)
    for i = 1:numel(trained_models)
        classifier = load([trained_models_dir filesep trained_models{i}]);
        file_info = whos('-file', [trained_models_dir filesep trained_models{i}]);
        model_name = file_info.name;

        disp(['running ' model_name])

        predicted_labels = classifier.(model_name).predictFcn(data.xpol_processed');

        % analyize results for each lidar shot
        confusion = confusionmat(data.labels, predicted_labels);
        [~, precision, recall, f3] = analyze_confusion(confusion);

        shot = struct('Confusion', confusion, 'F3', f3, ...
            'Precison', precision, 'Recall', recall, ...
            'HumanLabels', data.labels, 'PredictedLabels', predicted_labels);

        % analyize results for regions of interest
        labels_roi = groupLabels(data.labels, ...
            TRUE_LABEL_THRESHOLD, WINDOW_SIZE, OVERLAP);
        predicted_labels_roi = groupLabels(predicted_labels, ...
            PREDICTED_LABEL_THRESHOLD, WINDOW_SIZE, OVERLAP);

        confusion_roi = confusionmat(labels_roi, predicted_labels_roi);
        [~, precision_roi, recall_roi, f3_roi] = analyze_confusion(confusion_roi);

        roi = struct('Confusion', confusion_roi, 'F3', f3_roi, ...
            'Precison', precision_roi, 'Recall', recall_roi, ...
            'HumanLabels', labels_roi, 'PredictedLabels', predicted_labels_roi);

        results(model_name) = struct('Shot', shot, 'Roi', roi);
    end
    save([trained_model_results_dir filesep 'results'], 'results', '-v7.3');
else
    load([trained_model_results_dir filesep trained_model_results{:}]);
end

%% Find which classifier has the best performance
max_f3 = intmin;
best_model = '';

for model = results.keys
    if results(model{:}).Roi.F3 >= max_f3
        max_f3 = results(model{:}).Roi.F3;
        best_model = model{:};
    end
end

disp('Best model:')
disp(best_model)
disp('')
disp('shot results:')
disp(results(best_model).Shot)
disp('    confusion')
disp(results(best_model).Shot.Confusion)
disp('')
disp('roi results:')
disp(results(best_model).Roi)
disp('    confusion')
disp(results(best_model).Roi.Confusion)
