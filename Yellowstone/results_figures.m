%% Setup
data_dir = 'C:\Users\bugsbunny\Box\AFRL_Data\Data\Yellowstone';

% load data
data2016 = load([data_dir filesep 'processed_data_2016.mat'], 'xpol_processed', 'location');
data2015 = load([data_dir filesep 'processed_data_2015.mat'], 'xpol_processed', 'location');

% load results
load([data_dir filesep 'results']);

SPEED_OF_LIGHT = 299792458 / 1.3; % water has an index of refraction ~1.3
SAMPLE_RATE = 800e6;
DEPTH_INCREMENT = SPEED_OF_LIGHT / SAMPLE_RATE / 2;

%% Region of interest confusion matrices
confusion_fig = figure('Units', 'inches', 'Position', [2, 2, 7, 2.5]);
t = tiledlayout(confusion_fig, 1,2);

nexttile
c1 = confusionchart(results2016.Roi.Confusion, {'no fish', 'fish'});
c1.FontSize = 12;
% c1.DiagonalColor = '#a3c166';
c1.DiagonalColor = '#67A3C1';
c1.OffDiagonalColor = '#c18566';
sortClasses(c1, {'no fish', 'fish'})
title('(a)')

nexttile
c2 = confusionchart(results2015.Roi.Confusion, {'no fish', 'fish'});
c2.FontSize = 12;
% c2.DiagonalColor = '#a3c166';
c2.OffDiagonalColor = '#c18566';
c2.DiagonalColor = '#67A3C1';
sortClasses(c2, {'no fish', 'fish'})
title('(b)')

% NOTE: I use illustrator or inkscape to left-align the titles in post 
% because confusion charts don't support title alignment
% exportgraphics(confusion_fig, 'figs/yellowstone_roi_confusion.pdf', 'ContentType', 'vector');


%% Label comparison
WINDOW_SIZE = 1000;
OVERLAP = 100;

% 2016 roi hit example
roi_index = 123;
shot_start = (roi_index - 1) * WINDOW_SIZE - (roi_index - 1) * OVERLAP;
shot_stop = shot_start + WINDOW_SIZE;

distance = data2016.location.distance(shot_start : shot_stop);
distance = distance - distance(1);
true_labels = results2016.Shot.Labels(shot_start : shot_stop);
predicted_labels = results2016.Shot.PredictedLabels(shot_start : shot_stop);
data = data2016.xpol_processed(:,shot_start : shot_stop);

label_comparison_2016_fig = label_comparison_fig(true_labels, predicted_labels, ...
    abs(data), DEPTH_INCREMENT, distance);
label_comparison_2016_fig.Units = 'inches';
label_comparison_2016_fig.Position = [1 1 4.5 4];
label_comparison_2016_fig.CurrentAxes.Title.String = "(a)";

% 2015 roi miss example
roi_index = 64;
shot_start = (roi_index - 1) * WINDOW_SIZE - (roi_index - 1) * OVERLAP;
shot_stop = shot_start + WINDOW_SIZE;
distance = data2015.location.distance(shot_start : shot_stop);
distance = distance - distance(1);
true_labels = results2015.Shot.Labels(shot_start : shot_stop);
predicted_labels = results2015.Shot.PredictedLabels(shot_start : shot_stop);
data = data2015.xpol_processed(:,shot_start : shot_stop);

label_comparison_2015_fig = label_comparison_fig(true_labels, predicted_labels, ...
    abs(data), DEPTH_INCREMENT, distance);
label_comparison_2015_fig.Units = 'inches';
label_comparison_2015_fig.Position = [1 1 4.5 4];

% NOTE: I use illustrator to combine these into subfigures, as doing it
% programmatically was not looking promising
exportgraphics(label_comparison_2016_fig, 'figs/yellowstone_roi_hit_2016.pdf', 'ContentType', 'vector');
exportgraphics(label_comparison_2015_fig, 'figs/yellowstone_roi_miss_2015.pdf', 'ContentType', 'vector');
