%% setup
addpath('../../common')

box_dir = '../../../data/fish-lidar/Yellowstone';
data_filename = 'processed_data_2015.mat';
data_path = [box_dir filesep 'processed' filesep data_filename];

% number of rows above the surface of the water to start the image
SURFACE_PAD = 0;

% number of columns to use in dimensionality reduction
REDUCED_COLUMN_HEIGHT = 60;

% load in the data
load(data_path, 'xpol_raw', 'copol_raw', 'location');
distance = location.distance;
    
%% data processing
surface_index = find_water_surface(copol_raw, 'NSkipSamples', 600, 'NSmoothingSamples', 10);
xpol_surface_corrected = correct_surface(xpol_raw, surface_index, SURFACE_PAD);
xpol_depth_adjustment = xpol_surface_corrected(1:REDUCED_COLUMN_HEIGHT, :);    

%% figure creation
close all
cmap = flipud(colormap(brewermap(10000,'*PuBu'))); % Blue on purple colormap with white at bottom

start = 24.75e3;
stop = 25.4e3;

% original shots
imshow(xpol_raw(:, start:stop), 'DisplayRange', [0 10], 'Colormap', cmap)
ylim([600, 1700])
exportgraphics(gca, 'original_shots.pdf', 'ContentType', 'vector');

% surface detected
figure
imshow(xpol_raw(:, start:stop), 'DisplayRange', [0 10], 'Colormap', cmap)
hold on
plot(surface_index(start:stop), 'LineStyle', '--', 'Color', '#DC3100', 'LineWidth', 2.5)
hold off
ylim([600, 1700])
exportgraphics(gca, 'surface_detection.pdf', 'ContentType', 'vector');


% surface corrected
figure
imshow(xpol_surface_corrected(:, start:stop), 'DisplayRange', [0 10], 'Colormap', cmap)
ylim([0, 1100])
exportgraphics(gca, 'surface_correction.pdf', 'ContentType', 'vector');


% depth adjustment
figure
imshow(xpol_depth_adjustment(:, start:stop), 'DisplayRange', [0 10], 'Colormap', cmap)
exportgraphics(gca, 'depth_adjustment.pdf', 'ContentType', 'vector');



