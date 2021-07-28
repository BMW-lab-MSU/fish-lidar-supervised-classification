%%
box_dir = '../../../data/fish-lidar/Yellowstone';


load([box_dir filesep 'testing' filesep 'first_day_roi_testing_data.mat']);
results = load([box_dir filesep 'testing' filesep 'results_first_day.mat']);

%%
SPEED_OF_LIGHT = 299792458 / 1.3; % water has an index of refraction ~1.3
SAMPLE_RATE = 800e6;
DEPTH_INCREMENT = SPEED_OF_LIGHT / SAMPLE_RATE / 2;

%%

% Find the false positive ROIs
false_positive_indicator = find(results.nnet.roi.pred_indicator - testing_roi_indicator);

false_positive_rois = testing_roi_data(false_positive_indicator);
false_positive_roi_labels = results.nnet.roi.pred_labels(false_positive_indicator);

% Transpose the regions so shots are in columns, not rows
false_positive_rois = cellfun(@(roi) roi', false_positive_rois, 'UniformOutput', false);

%%

tp_indicator = find(results.nnet.roi.pred_indicator == 1 & testing_roi_indicator == 1);

tp_rois = testing_roi_data(tp_indicator);
tp_roi_labels = results.nnet.roi.pred_labels(tp_indicator);

% Transpose the regions so shots are in columns, not rows
tp_rois = cellfun(@(roi) roi', tp_rois, 'UniformOutput', false);

%%


roi_tp1 = label_comparison_fig(testing_roi_labels{118}, tp_roi_labels{4}, ...
    tp_rois{3}, DEPTH_INCREMENT);
roi_tp1.Units = 'inches';
roi_tp1.Position = [1 1 4.5 4];





exportgraphics(roi_tp1, 'yellowstone_roi_tp.pdf', 'ContentType', 'vector');

