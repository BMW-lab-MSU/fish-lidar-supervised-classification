%% Setup
data_dir = 'C:\Users\bugsbunny\Box\AFRL_Data\Data\GulfOfMexico';

% load data
% data2016 = load([data_dir filesep 'processed data' filesep 'processed_data_2016.mat'], 'xpol_processed', 'location');
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
c1.FontSize = 12;
% c1.DiagonalColor = '#a3c166';
c1.DiagonalColor = '#67A3C1';
c1.OffDiagonalColor = '#c18566';
sortClasses(c1, {'no fish', 'fish'})
title('Shot')

nexttile
c2 = confusionchart(results('average').Roi.Confusion, {'no fish', 'fish'});
c2.FontSize = 12;
% c2.DiagonalColor = '#a3c166';
c2.OffDiagonalColor = '#c18566';
c2.DiagonalColor = '#67A3C1';
sortClasses(c2, {'no fish', 'fish'})
title('ROI')

% NOTE: I use illustrator or inkscape to change the top-left font color to
% white, like MALTAB does if I don't set the diagonal colors
exportgraphics(confusion_fig, 'figs/gom_confusion.pdf', 'ContentType', 'vector');


%% ROI label comparison
WINDOW_SIZE = 1000;
OVERLAP = 100;

