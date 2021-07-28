%% Setup
addpath('../../common');

data_dir = '../../../data/fish-lidar/Yellowstone';
load([data_dir filesep 'processed' filesep 'processed_data_2016.mat'])

SPEED_OF_LIGHT = 299792458 / 1.3; % water has an index of refraction ~1.3
SAMPLE_RATE = 800e6;
DEPTH_INCREMENT = SPEED_OF_LIGHT / SAMPLE_RATE / 2;

% create a grayscale colormap with white at the bottom
cmap = flipud(colormap(brewermap(10000,'*PuBu')));

%% Create figures

% section of the data to show
col_start = 110250;
col_stop = 110500;
row_start =1400;
row_stop = 1540;

close all

fig_fish_example_raw = figure('Units', 'inches', 'Position', [1 1 5 4]);

% index of refraction is different in air; since the image starts pretty close
% to the surface of the water, the first depth sample is computed using 
% the speed of light in vacuum/air, then the rest are computed assuming water
depth = [DEPTH_INCREMENT * 1.3 * row_start,...
    DEPTH_INCREMENT * 1.3 * row_start + DEPTH_INCREMENT * (1 : row_stop - row_start -1)];

% x-axis arbitrarily starts at 0 to show relative distance instead of
% absolute flight distance
imagesc(location.distance(col_start:col_stop) - location.distance(col_start), ...
    depth, ...
    xpol_raw(row_start:row_stop, col_start:col_stop), [0, 50])
colormap(cmap);
xlabel('Distance [m]')
ylabel('Distance from Airplane [m]')
hold on
set(gca, 'FontSize', 12)

% fish
annotation('ellipse', [0.61 0.64 0.05 0.2], 'LineStyle', '-', 'Color', '#DC3100', ...
    'LineWidth', 3)
% water surface
annotation('arrow', [0.2, 0.25], [0.9, 0.75], 'LineWidth', 2, 'Color', '#FFBF13')
% underwater shelf
annotation('ellipse', [0.34 0.2 0.1 0.45], 'LineStyle', '--', 'LineWidth', 3, ...
    'Color', '#FF9313')


% same image as above, but with processed data instead of raw data
fig_fish_example_processed = figure('Units', 'inches', 'Position', [1 1 5 4]);

imagesc(location.distance(col_start:col_stop) - location.distance(col_start), ...
    DEPTH_INCREMENT*(0:size(xpol_processed, 1) - 1), ...
    xpol_processed(:, col_start:col_stop), [0, 50]);
colormap(cmap);
xlabel('Distance [m]')
ylabel('Depth [m]')
hold on
set(gca, 'FontSize', 12)

% fish
annotation('ellipse', [0.612 0.52 0.05 0.3], 'LineStyle', '-', 'Color', '#DC3100', ...
    'LineWidth', 3)
% water surface
annotation('arrow', [0.2, 0.3], [0.7, 0.85], 'LineWidth', 2, 'Color', '#FFBF13')


%% Save figures
exportgraphics(fig_fish_example_raw, 'yellowstone_fish_example_raw.pdf', 'ContentType', 'vector');
exportgraphics(fig_fish_example_processed, 'yellowstone_fish_example_processed.pdf', 'ContentType', 'vector');
