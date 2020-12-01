%% setup
box_dir = 'C:\Users\bugsbunny\Box\AFRL_Data\Data\Yellowstone';
data_filename = 'yellowstone_20150923.processed.h5';
data_path = [box_dir filesep data_filename];

% number of rows above the surface of the water to start the image
SURFACE_PAD = 0;

% number of columns to use in dimensionality reduction
REDUCED_COLUMN_HEIGHT = 60;

% load in the data
xpol_data = h5read(data_path, '/crosspol/radiance');             
distance = h5read(data_path, '/location/distance');
    
%% data processing
surface_index = find_water_surface(xpol_data);
xpol_surface_corrected = normalize_surface_height(xpol_data, surface_index, SURFACE_PAD);
xpol_depth_adjustment = xpol_surface_corrected(1:REDUCED_COLUMN_HEIGHT, :);    

%% figure creation
close all
cmap = flipud(colormap('gray')); % grayscale colormap with white at bottom

start = 24.75e3;
stop = 25.4e3;

mkdir('figs')

% original shots
imshow(xpol_data(:, start:stop), 'DisplayRange', [0 10], 'Colormap', cmap)
ylim([600, 1700])
exportgraphics(gca, 'figs/original_shots.pdf', 'ContentType', 'vector');

% surface detected
figure
imshow(xpol_data(:, start:stop), 'DisplayRange', [0 10], 'Colormap', cmap)
hold on
plot(surface_index(start:stop), 'LineStyle', '--', 'Color', '#a3c166', 'LineWidth', 1)
hold off
ylim([600, 1700])
exportgraphics(gca, 'figs/surface_detection.pdf', 'ContentType', 'vector');


% surface corrected
figure
imshow(xpol_surface_corrected(:, start:stop), 'DisplayRange', [0 10], 'Colormap', cmap)
ylim([0, 1100])
exportgraphics(gca, 'figs/surface_correction.pdf', 'ContentType', 'vector');


% depth adjustment
figure
imshow(xpol_depth_adjustment(:, start:stop), 'DisplayRange', [0 10], 'Colormap', cmap)
exportgraphics(gca, 'figs/depth_adjustment.pdf', 'ContentType', 'vector');



