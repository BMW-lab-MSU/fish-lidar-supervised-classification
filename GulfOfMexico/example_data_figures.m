data_dir = '../../Box/Data/GulfOfMexico/processed data';

day1 = load([data_dir filesep 'processed_data_09-24.mat'], 'labels', 'xpol_raw', 'metadata');
day2 = load([data_dir filesep 'processed_data_09-25.mat'], 'labels', 'xpol_raw', 'metadata');


%%
cmap = flipud(colormap('gray'));
set(0, 'DefaultAxesFontSize', 14, 'DefaultTextFontSize', 14)

%%
close all

fig = figure('Units', 'inches', 'Position', [1000, 1000, 8, 5]);
t = tiledlayout(2,1);
t.TileSpacing = 'compact';
t.Padding = 'compact';
t.XLabel.String = 'Distance [m]';
t.YLabel.String = 'Depth [m]';
t.XLabel.FontSize = 14;
t.YLabel.FontSize = 14;


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

imagesc(day2.xpol_raw(row_start:row_stop, col_start:col_stop), 'XData', d);
colormap(cmap);
hold on

% scatter(d(find(day2.labels(4,col_start:col_stop))), ones(1, length(find(day2.labels(4, col_start:col_stop)))))
% scatter(d(find(day2.labels(2,col_start:col_stop))), ones(1, length(find(day2.labels(2, col_start:col_stop)))))
% scatter(d(find(day2.labels(1,col_start:col_stop))), ones(1, length(find(day2.labels(1, col_start:col_stop)))))
% scatter(d(find(day2.labels(3,col_start:col_stop))), ones(1, length(find(day2.labels(3, col_start:col_stop)))))


% jellyfish
annotation('ellipse', [0.135 0.63 0.05 0.22], 'LineStyle', '-', 'Color', '#67A3C1', ...
    'LineWidth', 3)
annotation('ellipse', [0.33 0.7 0.05 0.2], 'LineStyle', '-', 'Color', '#67A3C1', ...
    'LineWidth', 3)

% fish schools
annotation('ellipse', [0.44 0.7 0.03, 0.18], 'LineStyle', ':', 'Color', '#a3c166', ...
    'LineWidth', 3)
annotation('ellipse', [0.49 0.72 0.07 0.18], 'LineStyle', ':', 'Color', '#a3c166', ...
    'LineWidth', 3)
annotation('ellipse', [0.765 0.68 0.03 0.18], 'LineStyle', ':', 'Color', '#a3c166', ...
    'LineWidth', 3)

title('(a)', 'FontSize', 14)
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
d = linspace(0, total_distance, col_stop - col_start + 1);


nexttile

imagesc(day1.xpol_raw(row_start:row_stop, col_start:col_stop), 'XData', d);
colormap(cmap)
hold on

% single fish hits
scatter(d(find(day1.labels(1,col_start:col_stop))), 177*ones(1, length(find(day1.labels(1, col_start:col_stop)))), ... 
    'Marker', '^', 'MarkerEdgeColor', '#67A3C1', 'MarkerFaceColor', '#67A3C1', 'SizeData', 50)

title('(b)', 'FontSize', 14)
set(gca, 'TitleHorizontalAlignment', 'left')



%%
exportgraphics(fig, 'figs/Gulf_of_Mexico_data_example.pdf', 'ContentType', 'vector');