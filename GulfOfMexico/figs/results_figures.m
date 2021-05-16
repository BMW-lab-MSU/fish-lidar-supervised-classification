%% Setup
addpath('../../common');

data_dir = '/Users/trevvvy/research/afrl/data/fish-lidar/GulfOfMexico';

% load data
day8 = load([data_dir filesep 'processed data' filesep 'processed_data_10-03.mat'], 'xpol_processed', 'metadata');
% data2015 = load([data_dir filesep 'processed data' filesep 'processed_data_2015.mat'], 'xpol_processed', 'location');

% load results
results = load([data_dir filesep 'testing' filesep 'results']);
results_first_day = load([data_dir filesep 'testing' filesep 'results_first_day']);
cv_results = load([data_dir filesep 'training' filesep 'cv_results']);
cv_results_first_day = load([data_dir filesep 'training' filesep 'cv_results_first_day']);

model_fields = {'svm', 'lda', 'nnet', 'tree', 'rusboost'};
model_names = {'SVM', 'LDA', 'Neural net', 'Tree', 'RUSBoost'};

SPEED_OF_LIGHT = 299792458 / 1.3; % water has an index of refraction ~1.3
SAMPLE_RATE = 1e9;
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

exportgraphics(cv_shot_confusion_fig, 'gom_cv_shot_confusion.pdf', 'ContentType', 'vector');

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

exportgraphics(cv_roi_confusion_fig, 'gom_cv_roi_confusion.pdf', 'ContentType', 'vector');

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

exportgraphics(holdout_shot_confusion_fig, 'gom_holdout_shot_confusion.pdf', 'ContentType', 'vector');

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

exportgraphics(holdout_roi_confusion_fig, 'gom_holdout_roi_confusion.pdf', 'ContentType', 'vector');

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

exportgraphics(cv_shot_confusion_fig, 'gom_first_day_cv_shot_confusion.pdf', 'ContentType', 'vector');

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

exportgraphics(cv_roi_confusion_fig, 'gom_first_day_cv_roi_confusion.pdf', 'ContentType', 'vector');

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

exportgraphics(holdout_shot_confusion_fig, 'gom_first_day_holdout_shot_confusion.pdf', 'ContentType', 'vector');

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

exportgraphics(holdout_roi_confusion_fig, 'gom_first_day_holdout_roi_confusion.pdf', 'ContentType', 'vector');