%% Setup
addpath('../common');

data_dir = '/Users/joeyaist/Box/AFRL_Data/Data/GulfOfMexico';

% load data
day8 = load([data_dir filesep 'processed data' filesep 'processed_data_10-03.mat'], 'xpol_processed', 'metadata');
% data2015 = load([data_dir filesep 'processed data' filesep 'processed_data_2015.mat'], 'xpol_processed', 'location');

% load results
load([data_dir filesep 'classification results' filesep 'results']);

SPEED_OF_LIGHT = 299792458 / 1.3; % water has an index of refraction ~1.3
SAMPLE_RATE = 1e9;
DEPTH_INCREMENT = SPEED_OF_LIGHT / SAMPLE_RATE / 2;

%% Confusion matrices
confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 7, 2.5]);
t = tiledlayout(confusion_fig, 1,2);

nexttile
c1 = confusionchart(results('average').Shot.Confusion, {'no fish', 'fish'});
c1.ColumnSummary = 'column-normalized';
c1.FontSize = 12;
%% c1.DiagonalColor = '#a3c166';
c1.DiagonalColor = '#67A3C1';
c1.OffDiagonalColor = '#c18566';
sortClasses(c1, {'no fish', 'fish'})
title('Shot')

nexttile
c2 = confusionchart(results('average').Roi.Confusion, {'no fish', 'fish'});
c2.ColumnSummary = 'column-normalized';
c2.FontSize = 12;
%% c2.DiagonalColor = '#a3c166';
c2.OffDiagonalColor = '#c18566';
c2.DiagonalColor = '#67A3C1';
sortClasses(c2, {'no fish', 'fish'})
title('ROI')

%% NOTE: I use illustrator or inkscape to change the top-left font color to
%% white, like MALTAB does if I don't set the diagonal colors
exportgraphics(confusion_fig, 'figs/gom_confusion.pdf', 'ContentType', 'vector');


%% ROI label comparison
WINDOW_SIZE = 1000;
OVERLAP = 100;

% true positive example
roi_index = 528;
shot_start = (roi_index - 1) * (WINDOW_SIZE - OVERLAP);
shot_stop = shot_start + WINDOW_SIZE - 1;

arclen = distance(day8.metadata.latitude(shot_start), day8.metadata.longitude(shot_start), ...
    day8.metadata.latitude(shot_stop), day8.metadata.longitude(shot_stop));
total_dist = deg2km(arclen) * 1e3; %[m]
dist = linspace(0, total_dist, shot_stop - shot_start + 1);

roi_true_positive_day8 = label_comparison_fig(results('10-03').Shot.Labels(shot_start:shot_stop), ... 
    results('10-03').Shot.PredictedLabels(shot_start:shot_stop), ...
    abs(day8.xpol_processed(1:50, shot_start:shot_stop)), DEPTH_INCREMENT, dist);

roi_true_positive_day8.Children(3).CLim = [0 0.03];
roi_true_positive_day8.Units = 'inches';
roi_true_positive_day8.Position = [1 1 4.5 4];
roi_true_positive_day8.Children(3).Title.String = "(a)";


% false negative example
roi_index = 362;
shot_start = (roi_index - 1) * (WINDOW_SIZE - OVERLAP);
shot_stop = shot_start + WINDOW_SIZE - 1;

arclen = distance(day8.metadata.latitude(shot_start), day8.metadata.longitude(shot_start), ...
    day8.metadata.latitude(shot_stop), day8.metadata.longitude(shot_stop));
total_dist = deg2km(arclen) * 1e3; %[m]
dist = linspace(0, total_dist, shot_stop - shot_start + 1);

roi_false_negative_day8 = label_comparison_fig(results('10-03').Shot.Labels(shot_start:shot_stop), ... 
    results('10-03').Shot.PredictedLabels(shot_start:shot_stop), ...
    abs(day8.xpol_processed(1:50, shot_start:shot_stop)), DEPTH_INCREMENT, dist);

roi_false_negative_day8.Children(2).CLim = [0 2];
roi_false_negative_day8.Units = 'inches';
roi_false_negative_day8.Position = [1 1 4.5 4];
roi_false_negative_day8.Children(3).Title.String = "(b)";

exportgraphics(roi_true_positive_day8, 'figs/gom_roi_true_positive_day8.pdf', 'ContentType', 'vector');
exportgraphics(roi_false_negative_day8, 'figs/gom_roi_false_negative_day8.pdf', 'ContentType', 'vector');
