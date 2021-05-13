%% Setup
clear
addpath('../common')

box_dir = 'D:\Box Sync\AFRL_Data\Data\Yellowstone';

%% Find false positive regions in the 80/20 split testing data
load([box_dir filesep 'testing' filesep 'roi_testing_data.mat']);
results = load([box_dir filesep 'testing' filesep 'results.mat']);

% Find the model that performed best
maxf3 = 0;
best_model = '';
for model = fields(results)' % transpose allows us to do a "foreach" loop
    if results.(model{:}).roi.f3 >= maxf3
        disp(model{:})
        maxf3 = results.(model{:}).roi.f3
        best_model = model{:};
    end
end

% Find the false positive ROIs
false_positive_indicator = find(results.(best_model).roi.pred_indicator - testing_roi_indicator);

false_positive_rois = testing_data(false_positive_indicator);
false_positive_roi_labels = results.(best_model).roi.pred_labels(false_positive_indicator);

% Transpose the regions so shots are in columns, not rows
false_positive_rois = cellfun(@(roi) roi', false_positive_rois, 'UniformOutput', false);

% Save regions as images
mkdir('false_positive_rois');
for roi = 1:numel(false_positive_rois)
    fig = figure('visible', 'off');
    imagesc(false_positive_rois{roi});
    hold on
    
    pred_fish = find(false_positive_roi_labels{roi});
    scatter(pred_fish, 60*ones(1, numel(pred_fish)), 100, '*', 'k')
    
    exportgraphics(fig, ['false_positive_rois/Yellowstone false positive region '...
        num2str(false_positive_indicator(roi)) '.png'], 'Resolution', 300)
end


%% Find false positive regions in the "first day" testing data
clearvars -except box_dir
load([box_dir filesep 'testing' filesep 'first_day_roi_testing_data.mat']);
results = load([box_dir filesep 'testing' filesep 'results_first_day.mat']);

% Find the model that performed best
maxf3 = 0;
best_model = '';
for model = fields(results)' % transpose allows us to do a "foreach" loop
    if results.(model{:}).roi.f3 >= maxf3
        disp(model{:})
        maxf3 = results.(model{:}).roi.f3
        best_model = model{:};
    end
end

% Find the false positive ROIs
false_positive_indicator = find(results.(best_model).roi.pred_indicator - testing_roi_indicator);

false_positive_rois = testing_roi_data(false_positive_indicator);
false_positive_roi_labels = results.(best_model).roi.pred_labels(false_positive_indicator);

% Transpose the regions so shots are in columns, not rows
false_positive_rois = cellfun(@(roi) roi', false_positive_rois, 'UniformOutput', false);

% Save regions as images
mkdir('false_positive_rois');
for roi = 1:numel(false_positive_rois)
    fig = figure('visible', 'off');
    imagesc(false_positive_rois{roi});
    hold on
    
    pred_fish = find(false_positive_roi_labels{roi});
    scatter(pred_fish, 60*ones(1, numel(pred_fish)), 100, '*', 'k')
    
    exportgraphics(fig, ['false_positive_rois/Yellowstone first day false positive region '...
        num2str(false_positive_indicator(roi)) '.png'], 'Resolution', 300)
end

