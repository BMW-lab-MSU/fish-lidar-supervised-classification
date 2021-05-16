%% Setup
addpath('../../common');

data_dir = '/Users/trevvvy/research/afrl/data/fish-lidar/Yellowstone';

% load data
data2016 = load([data_dir filesep 'processed_data_2016.mat'], 'xpol_processed', 'location');
data2015 = load([data_dir filesep 'processed_data_2015.mat'], 'xpol_processed', 'location');

% load results
results = load([data_dir filesep 'testing' filesep 'results']);
results_first_day = load([data_dir filesep 'testing' filesep 'results_first_day']);
cv_results = load([data_dir filesep 'training' filesep 'cv_results']);
cv_results_first_day = load([data_dir filesep 'training' filesep 'cv_results_first_day']);

model_fields = {'svm', 'lda', 'nnet', 'tree', 'rusboost'};
model_names = {'SVM', 'LDA', 'Neural net', 'Tree', 'RUSBoost'};

SPEED_OF_LIGHT = 299792458 / 1.3; % water has an index of refraction ~1.3
SAMPLE_RATE = 800e6;
DEPTH_INCREMENT = SPEED_OF_LIGHT / SAMPLE_RATE / 2;

%% Cross validation shot confusion matrices
cv_shot_confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 8.5, 5]);
t = tiledlayout(cv_shot_confusion_fig, 3,2);
t.Padding = 'none';
t.TileSpacing = 'compact';

for i = 1:numel(model_fields)
    nexttile
    c1 = confusionchart(cv_results.(model_fields{i}).shot.confusion, {'no fish', 'fish'});
    c1.ColumnSummary = 'column-normalized';
    c1.RowSummary = 'row-normalized';
    c1.FontSize = 11;
    sortClasses(c1, {'no fish', 'fish'})
    title(model_names{i})
end

exportgraphics(cv_shot_confusion_fig, 'yellowstone_cv_shot_confusion.pdf', 'ContentType', 'vector');

%% Cross validation ROI confusion matrices
cv_roi_confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 8.5, 5]);
t = tiledlayout(cv_roi_confusion_fig, 3,2);
t.Padding = 'none';
t.TileSpacing = 'compact';

for i = 1:numel(model_fields)
    nexttile
    c1 = confusionchart(cv_results.(model_fields{i}).roi.confusion, {'no fish', 'fish'});
    c1.ColumnSummary = 'column-normalized';
    c1.RowSummary = 'row-normalized';
    c1.FontSize = 11;
    sortClasses(c1, {'no fish', 'fish'})
    title(model_names{i})
end

exportgraphics(cv_roi_confusion_fig, 'yellowstone_cv_roi_confusion.pdf', 'ContentType', 'vector');

%% Holdout shot confusion matrices
holdout_shot_confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 8.5, 5]);
t = tiledlayout(holdout_shot_confusion_fig, 3,2);
t.Padding = 'none';
t.TileSpacing = 'compact';

for i = 1:numel(model_fields)
    nexttile
    c1 = confusionchart(results.(model_fields{i}).shot.confusion, {'no fish', 'fish'});
    c1.ColumnSummary = 'column-normalized';
    c1.RowSummary = 'row-normalized';
    c1.FontSize = 11;
    sortClasses(c1, {'no fish', 'fish'})
    title(model_names{i})
end

exportgraphics(holdout_shot_confusion_fig, 'yellowstone_holdout_shot_confusion.pdf', 'ContentType', 'vector');

%% Holdout ROI confusion matrices
holdout_roi_confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 8.5, 5]);
t = tiledlayout(holdout_roi_confusion_fig, 3,2);
t.Padding = 'none';
t.TileSpacing = 'compact';

for i = 1:numel(model_fields)
    nexttile
    c1 = confusionchart(results.(model_fields{i}).roi.confusion, {'no fish', 'fish'});
    c1.ColumnSummary = 'column-normalized';
    c1.RowSummary = 'row-normalized';
    c1.FontSize = 11;
    sortClasses(c1, {'no fish', 'fish'})
    title(model_names{i})
end

exportgraphics(holdout_roi_confusion_fig, 'yellowstone_holdout_roi_confusion.pdf', 'ContentType', 'vector');

%% First day cross validation shot confusion matrices
cv_shot_confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 8.5, 5]);
t = tiledlayout(cv_shot_confusion_fig, 3,2);
t.Padding = 'none';
t.TileSpacing = 'compact';

for i = 1:numel(model_fields)
    nexttile
    c1 = confusionchart(cv_results_first_day.(model_fields{i}).shot.confusion, {'no fish', 'fish'});
    c1.ColumnSummary = 'column-normalized';
    c1.RowSummary = 'row-normalized';
    c1.FontSize = 11;
    sortClasses(c1, {'no fish', 'fish'})
    title(model_names{i})
end

exportgraphics(cv_shot_confusion_fig, 'yellowstone_first_day_cv_shot_confusion.pdf', 'ContentType', 'vector');

%% First day cross validation ROI confusion matrices
cv_roi_confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 8.5, 5]);
t = tiledlayout(cv_roi_confusion_fig, 3,2);
t.Padding = 'none';
t.TileSpacing = 'compact';

for i = 1:numel(model_fields)
    nexttile
    c1 = confusionchart(cv_results_first_day.(model_fields{i}).roi.confusion, {'no fish', 'fish'});
    c1.ColumnSummary = 'column-normalized';
    c1.RowSummary = 'row-normalized';
    c1.FontSize = 11;
    sortClasses(c1, {'no fish', 'fish'})
    title(model_names{i})
end

exportgraphics(cv_roi_confusion_fig, 'yellowstone_first_day_cv_roi_confusion.pdf', 'ContentType', 'vector');

%% First day holdout shot confusion matrices
holdout_shot_confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 8.5, 5]);
t = tiledlayout(holdout_shot_confusion_fig, 3,2);
t.Padding = 'none';
t.TileSpacing = 'compact';

for i = 1:numel(model_fields)
    nexttile
    c1 = confusionchart(results_first_day.(model_fields{i}).shot.confusion, {'no fish', 'fish'});
    c1.ColumnSummary = 'column-normalized';
    c1.RowSummary = 'row-normalized';
    c1.FontSize = 11;
    sortClasses(c1, {'no fish', 'fish'})
    title(model_names{i})
end

exportgraphics(holdout_shot_confusion_fig, 'yellowstone_first_day_holdout_shot_confusion.pdf', 'ContentType', 'vector');

%% First day holdout ROI confusion matrices
holdout_roi_confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 8.5, 5]);
t = tiledlayout(holdout_roi_confusion_fig, 3,2);
t.Padding = 'none';
t.TileSpacing = 'compact';

for i = 1:numel(model_fields)
    nexttile
    c1 = confusionchart(results_first_day.(model_fields{i}).roi.confusion, {'no fish', 'fish'});
    c1.ColumnSummary = 'column-normalized';
    c1.RowSummary = 'row-normalized';
    c1.FontSize = 11;
    sortClasses(c1, {'no fish', 'fish'})
    title(model_names{i})
end

exportgraphics(holdout_roi_confusion_fig, 'yellowstone_first_day_holdout_roi_confusion.pdf', 'ContentType', 'vector');

%% ROI label comparison
WINDOW_SIZE = 1000;
OVERLAP = 100;

% 2016 roi true positive example
roi_index = 123;
shot_start = (roi_index - 1) * WINDOW_SIZE - (roi_index - 1) * OVERLAP;
shot_stop = shot_start + WINDOW_SIZE;

distance = data2016.location.distance(shot_start : shot_stop);
distance = distance - distance(1);
true_labels = results2016.Shot.Labels(shot_start : shot_stop);
predicted_labels = results2016.Shot.PredictedLabels(shot_start : shot_stop);
data = data2016.xpol_processed(:,shot_start : shot_stop);

roi_true_positive_2016 = label_comparison_fig(true_labels, predicted_labels, ...
    abs(data), DEPTH_INCREMENT, distance);
roi_true_positive_2016.Units = 'inches';
roi_true_positive_2016.Position = [1 1 4.5 4];
roi_true_positive_2016.Children(3).Title.String = "(a)";
roi_true_positive_2016.Children(3).Title.HorizontalAlignment = 'left';


% 2015 roi false positive example
roi_index = 64;
shot_start = (roi_index - 1) * WINDOW_SIZE - (roi_index - 1) * OVERLAP;
shot_stop = shot_start + WINDOW_SIZE;
distance = data2015.location.distance(shot_start : shot_stop);
distance = distance - distance(1);
true_labels = results2015.Shot.Labels(shot_start : shot_stop);
predicted_labels = results2015.Shot.PredictedLabels(shot_start : shot_stop);
data = data2015.xpol_processed(:,shot_start : shot_stop);

roi_false_positive_2015 = label_comparison_fig(true_labels, predicted_labels, ...
    abs(data), DEPTH_INCREMENT, distance);
roi_false_positive_2015.Units = 'inches';
roi_false_positive_2015.Position = [1 1 4.5 4];
roi_false_positive_2015.Children(3).Title.String = "(b)";
roi_false_positive_2015.Children(3).Title.HorizontalAlignment = 'left';

% 2015 roi false negative example
roi_index = 62;
%roi_index = 68;
shot_start = (roi_index - 1) * WINDOW_SIZE - (roi_index - 1) * OVERLAP;
shot_stop = shot_start + WINDOW_SIZE;
distance = data2015.location.distance(shot_start : shot_stop);
distance = distance - distance(1);
true_labels = results2015.Shot.Labels(shot_start : shot_stop);
predicted_labels = results2015.Shot.PredictedLabels(shot_start : shot_stop);
data = data2015.xpol_processed(:,shot_start : shot_stop);

roi_false_negative_2015 = label_comparison_fig(true_labels, predicted_labels, ...
    abs(data), DEPTH_INCREMENT, distance);
roi_false_negative_2015.Units = 'inches';
roi_false_negative_2015.Position = [1 1 4.5 4];
roi_false_negative_2015.Children(3).Title.String = "(c)";
roi_false_negative_2015.Children(3).Title.HorizontalAlignment = 'left';

% 2015 roi true positive example
roi_index = 63;
% roi_index = 97;
shot_start = (roi_index - 1) * WINDOW_SIZE - (roi_index - 1) * OVERLAP;
shot_stop = shot_start + WINDOW_SIZE;
distance = data2015.location.distance(shot_start : shot_stop);
distance = distance - distance(1);
true_labels = results2015.Shot.Labels(shot_start : shot_stop);
predicted_labels = results2015.Shot.PredictedLabels(shot_start : shot_stop);
data = data2015.xpol_processed(:,shot_start : shot_stop);

roi_true_positive_2015 = label_comparison_fig(true_labels, predicted_labels, ...
    abs(data), DEPTH_INCREMENT, distance);
roi_true_positive_2015.Units = 'inches';
roi_true_positive_2015.Position = [1 1 4.5 4];
roi_true_positive_2015.Children(3).Title.String = "(d)";
roi_true_positive_2015.Children(3).Title.HorizontalAlignment = 'left';

% NOTE: I use illustrator to combine these into subfigures, as doing it
% % programmatically was not looking promising
exportgraphics(roi_true_positive_2016, 'figs/yellowstone_roi_true_positive_2016.pdf', 'ContentType', 'vector');
exportgraphics(roi_true_positive_2015, 'figs/yellowstone_roi_true_positive_2015.pdf', 'ContentType', 'vector');
exportgraphics(roi_false_positive_2015, 'figs/yellowstone_roi_false_positive_2015.pdf', 'ContentType', 'vector');
exportgraphics(roi_false_negative_2015, 'figs/yellowstone_roi_false_negative_2015.pdf', 'ContentType', 'vector');
