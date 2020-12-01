%% Setup
data_dir = 'C:\Users\bugsbunny\Box\AFRL_Data\Data\Yellowstone';
load([data_dir filesep 'processed_data_2016.mat'])

% create a grayscale colormap with white at the bottom
cmap = flipud(colormap('gray'));

%% Create figures

% section of the data to show
col_start = 110250;
col_stop = 110500;
row_start =1400;
row_stop = 1540;

close all

fig_fish_example_raw = figure;

% x-axis arbitrarily starts at 0 to show relative distance instead of
% absolute flight distance
imagesc(location.distance(col_start:col_stop) - location.distance(col_start), ...
    metadata.depth_increment*(row_start:row_stop), ...
    xpol_raw(row_start:row_stop, col_start:col_stop), [0, 50])
colormap(cmap);
xlabel('Distance [m]')
ylabel('Distance from Airplane [m]')
hold on
set(gca, 'FontSize', 12)

% fish
annotation('ellipse', [0.61 0.64 0.05 0.2], 'LineStyle', '-', 'Color', '#67A3C1', ...
    'LineWidth', 3)
% water surface
annotation('arrow', [0.2, 0.25], [0.9, 0.75], 'LineWidth', 2, 'Color', '#a3c166')
% underwater shelf
annotation('ellipse', [0.34 0.2 0.1 0.45], 'LineStyle', '--', 'LineWidth', 3, ...
    'Color', '#c18566')


% same image as above, but with processed data instead of raw data
fig_fish_example_processed = figure;

imagesc(location.distance(col_start:col_stop) - location.distance(col_start), ...
    metadata.depth_increment*(0:size(xpol_processed, 1) - 1), ...
    xpol_processed(:, col_start:col_stop), [0, 50]);
colormap(cmap);
xlabel('Distance [m]')
ylabel('Depth [m]')
hold on
set(gca, 'FontSize', 12)

% fish
annotation('ellipse', [0.612 0.52 0.05 0.3], 'LineStyle', '-', 'Color', '#67A3C1', ...
    'LineWidth', 3)
% water surface
annotation('arrow', [0.2, 0.3], [0.7, 0.85], 'LineWidth', 2, 'Color', '#a3c166')


%% Save figures
mkdir('figs')
exportgraphics(fig_fish_example_raw, 'figs/yellowstone_fish_example_raw.pdf', 'ContentType', 'vector');
exportgraphics(fig_fish_example_processed, 'figs/yellowstone_fish_example_processed.pdf', 'ContentType', 'vector');