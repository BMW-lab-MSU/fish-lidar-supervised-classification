addpath('../common');

data_dir = '../../box/Data/GulfOfMexico/processed data';

day1 = load([data_dir filesep 'processed_data_09-24.mat'], 'labels', 'xpol_raw', 'metadata');
day2 = load([data_dir filesep 'processed_data_09-25.mat'], 'labels', 'xpol_raw', 'metadata');

mkdir('figs');

%%
cmap = flipud(colormap('gray'));
set(0, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 12)

%%
SPEED_OF_LIGHT = 299792458 / 1.3; % water has an index of refraction ~1.3
SAMPLE_RATE = 1e9;
DEPTH_INCREMENT = SPEED_OF_LIGHT / SAMPLE_RATE / 2;

%%
close all

fig = figure('Units', 'inches', 'Position', [2, 2, 8, 5]);
t = tiledlayout(2,1);
t.TileSpacing = 'compact';
t.Padding = 'compact';
t.XLabel.String = 'Distance [m]';
t.YLabel.String = 'Depth [m]';
t.XLabel.FontSize = 12;
t.YLabel.FontSize = 12;


col_start =340900;
col_stop = 341200;
row_start =550;
row_stop = 725;

% compute distance for x-axis, starting arbitrarily at 0; distance is assumed
% to be linearly-spaced from col_start to col_stop
arclen = distance(day2.metadata.latitude(col_start), day2.metadata.longitude(col_start), ...
    day2.metadata.latitude(col_stop), day2.metadata.longitude(col_stop));
total_distance = deg2km(arclen) * 1e3; % [m]
d = linspace(0, total_distance, col_stop - col_start + 1);

nexttile

imagesc(d, DEPTH_INCREMENT * (0:row_stop-row_start-1), day2.xpol_raw(row_start:row_stop, col_start:col_stop));
colormap(cmap);
hold on

% scatter(d(find(day2.labels(4,col_start:col_stop))), ones(1, length(find(day2.labels(4, col_start:col_stop)))))
% scatter(d(find(day2.labels(2,col_start:col_stop))), ones(1, length(find(day2.labels(2, col_start:col_stop)))))
% scatter(d(find(day2.labels(1,col_start:col_stop))), ones(1, length(find(day2.labels(1, col_start:col_stop)))))
% scatter(d(find(day2.labels(3,col_start:col_stop))), ones(1, length(find(day2.labels(3, col_start:col_stop)))))


% jellyfish
annotation('ellipse', [0.108 0.625 0.05 0.22], 'LineStyle', '-', 'Color', '#67A3C1', ...
    'LineWidth', 3)
annotation('ellipse', [0.31 0.7 0.05 0.2], 'LineStyle', '-', 'Color', '#67A3C1', ...
    'LineWidth', 3)

% fish schools
annotation('ellipse', [0.422 0.7 0.03, 0.18], 'LineStyle', ':', 'Color', '#a3c166', ...
    'LineWidth', 3)
annotation('ellipse', [0.472 0.72 0.07 0.18], 'LineStyle', ':', 'Color', '#a3c166', ...
    'LineWidth', 3)
annotation('ellipse', [0.757 0.68 0.03 0.18], 'LineStyle', ':', 'Color', '#a3c166', ...
    'LineWidth', 3)

title('(a)', 'FontSize', 12)
set(gca, 'TitleHorizontalAlignment', 'left')

%%
col_start = 500600;
col_stop = 500900;
row_start = 420;
row_stop = 600;

% compute distance for x-axis, starting arbitrarily at 0; distance is assumed
% to be linearly-spaced from col_start to col_stop
arclen = distance(day1.metadata.latitude(col_start), day1.metadata.longitude(col_start), ...
    day1.metadata.latitude(col_stop), day1.metadata.longitude(col_stop));
total_distance = deg2km(arclen) * 1e3; % [m]
dist = linspace(0, total_distance, col_stop - col_start + 1);
depth = DEPTH_INCREMENT * (0:row_stop-row_start-1);


nexttile

imagesc(dist, depth, day1.xpol_raw(row_start:row_stop, col_start:col_stop));
colormap(cmap)
hold on

% single fish hits
scatter(d(find(day1.labels(1,col_start:col_stop))), depth(end-2)*ones(1, length(find(day1.labels(1, col_start:col_stop)))), ... 
    'Marker', '^', 'MarkerEdgeColor', '#67A3C1', 'MarkerFaceColor', '#67A3C1', 'SizeData', 50)

title('(b)', 'FontSize', 12)
set(gca, 'TitleHorizontalAlignment', 'left')



%%
exportgraphics(fig, 'figs/Gulf_of_Mexico_data_example.pdf', 'ContentType', 'vector');
