%% This file builds and labels the dataset for the Matlab classification suite
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% IMPORTANT: Read the README file BEFORE running
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%% Setup

% data_dir/classifier_dir/hits_dir can be a relative or absolute path; an empty string means you will
% have to navigate to your data directory in the file chooser dialogs
% data_dir = 'resources/data';
% classifier_dir = 'resources/classifiers/';
% hits_dir = 'resources/labels/';
data_dir = '/home/trevor/research/AFRL/Box/Data/Yellowstone';
classifier_dir = '/home/trevor/research/AFRL/Box/Data/Yellowstone';
hits_dir = '/home/trevor/research/AFRL/Box/Data/Yellowstone/';

data_filename = 'yellowstone_wfov_20160928.processed.h5';                  % declare dataset filenames and paths here if desired
hits_filename = 'fish_hits_2016_with_school_size_estimates.csv';

% TODO: error handling if DATA_DIR isn't a directory

% Constants (TODO: Automate these constants):
PLANE_TO_SURFACE = 160;
SURFACE_PAD = 10;
MAX_INTENSITY = 11;
MIN_INTENSITY = 2;

show_plots = true;

%% Load in the classifier mat file

% TODO: where to put this mat file? does it belong with the data or with
% the code??? it's currently with the data.
if isfolder(classifier_dir)
    load([classifier_dir, '/CLASSIFIER_2_QuadraticSVM']);
else
    [classifier_file, classifier_path] = uigetfile('*.mat', 'Load a classifier mat file');
    load([classifier_path filesep classifier_file]);
end

%% Load dataset
                                        
if isempty(data_filename)                                                  % if no dataset filename is given, let the user select a file
    disp('Select a dataset')
    if isfolder(data_dir)
        % TODO: do we expect other file types besdies h5? if so, we can
        % change the filetype filter
        [data_filename, data_dir] = uigetfile([data_dir, '/*.h5'], 'Select a dataset');
    else
        [data_filename, data_dir] = uigetfile('*.h5');

    end
end

                                                                           % load the dataset
full_filepath = [data_dir filesep data_filename];
%h5disp(filename);                                                         % uncomment to see dataset categories
xpol_from_plane = h5read(full_filepath, '/crosspol/radiance');             % Initialize data vectors
surf_idx = h5read(full_filepath, '/info/surface_index');
distance = h5read(full_filepath, '/location/distance');
latlong = h5read(full_filepath, '/location/latlong');

% Get the image dimensions; this assumes the image has more columns than rows
IMAGE_HEIGHT = min(size(xpol_from_plane));
IMAGE_WIDTH = max(size(xpol_from_plane));
 
%% Load Human Labeled fish hits
                                                                           % if no ground truth fish hits filename is given, let the user select a file
if isempty(hits_filename)
    disp('Select a ground truth fish hits file')
    if isfolder(hits_dir)
        [hits_filename, hits_dir] = uigetfile([hits_dir, '/*.csv'], 'Select a ground truth csv file');
    else
        [hits_filename, hits_dir] = uigetfile('*.csv');
    end
end

                                                                           % load in the ground truth fish hits
full_filepath = [hits_dir filesep hits_filename];
hits_matrix = readmatrix(full_filepath);                                    % Initialize hits values

%% Set the distances from the csv file
fish_distances = hits_matrix(:, 1);                                            % Initializing vectors of preselected fish hit data
fish_latitudes = hits_matrix(:, 2);                                            % (All rows, second column)
fish_longitudes = hits_matrix(:, 3);
school_sizes = hits_matrix(:, 7);

%% Creating a "positive label" vector --- Author: Jackson Belford
%  The value for average column width per fish was calculated by taking the
%  average of (the column width eyeballed / number of fish indicated by
%  csv)

% TODO: automate this? 
AVG_WIDTH_PER_FISH = 4.57;
human_labels = create_positive_label_vect(AVG_WIDTH_PER_FISH, school_sizes, distance, fish_distances);

%% Plot the path and the fish locations
% Simply a visual graphing process
if show_plots
    separation = 250;                                                          % Alters the sampling frequency of the mapping
    scatter(latlong(2,1:separation:size(latlong,2)),latlong(1,1:separation:size(latlong,2)),'m.'); axis square;
    hold on; scatter(fish_longitudes,fish_latitudes,'ro','LineWidth',3);
    hold on; scatter(-110.5555,44.4563,100,'d','filled'); hold off;
    legend({'Flight Path','Fish Hits'});
    xlabel('Longitude'); ylabel('Latitude');
    axis([-110.6 -110.2 44.25 44.6]);
end


%% Data preprocessing
%% Normalize surface index
depth_vector = zeros(1, IMAGE_WIDTH);

% set surface depth vectors
for i = 1:IMAGE_WIDTH                                                 % I need to personally review this chunk to understand :/
    depth_vector(i) = PLANE_TO_SURFACE;
    if surf_idx(i) + PLANE_TO_SURFACE - SURFACE_PAD > IMAGE_HEIGHT
        depth_vector(i) = IMAGE_HEIGHT - surf_idx(i) + SURFACE_PAD; 
    end
end
xpol_norm = normalize_surface_vect(xpol_from_plane, surf_idx, depth_vector, PLANE_TO_SURFACE);
 
%% Flooring and filtering of radiance data
xpol_norm(xpol_norm < MIN_INTENSITY) = 0;

% Clip max intensities
xpol_norm(xpol_norm > MAX_INTENSITY) = MAX_INTENSITY;


%% Windowing
% Reduce column height to region of interest
start = 10;
stop = 69;
x = xpol_norm(start:stop,:);

%% Do the classification

machine_labels_cheating = QuadraticSVM.predictFcn(x')';

% machine_labels = machine_labels_cross_validated;
machine_labels = machine_labels_cheating;

%% Specific label graphing (Before Area Application)

if show_plots
    figure();
    subplot(211); stem(human_labels); title('Actual Labels');
    subplot(212); stem(machine_labels); title('Predicted Labels');

    figure(); imagesc(x,[0 10]); xlim([0 100000]); ylim([1 60]);
    xlabel('LIDAR Image Data');
end

c = confusionmat(human_labels, machine_labels);
if show_plots
    figure(); confusionchart(c,{'No Fish','Fish'})
end

%% Machine labeled fish blocks
% Create contiguous areas centered around where fish were automatically detected
window = 2500;
index = window;
while index < length(machine_labels)
    if machine_labels(index) == 1
            machine_labels((index-window/2):(index+window/2)) = 1;
            index = index + window;
    else
            index = index + 1;
    end
end

%% Human Labeled area block
% Create contiguous areas centered around where fish were manually detected
% Setting individual labels to blocks of windowed size
index = window;
while index < length(human_labels)
    if human_labels(index) == 1
            human_labels((index-window/2):(index+window/2)) = 1;
            index = index + window;
    else
            index = index + 1;
    end
end

%% Graphical Analysis
if show_plots
    human_labels_first_half = human_labels(1:ceil(length(human_labels)/2));
    human_labels_second_half = human_labels(ceil(length(human_labels)/2):length(human_labels));
    machine_labels_first_half = machine_labels(1:ceil(length(machine_labels)/2));
    machine_labels_second_half = machine_labels(ceil(length(machine_labels)/2):length(machine_labels));

    label_comparison_first_half = [
        human_labels_first_half;
        zeros(1,length(human_labels_first_half));
        machine_labels_first_half
        ];

    label_comparison_second_half = [
        human_labels_second_half;
        zeros(1,length(human_labels_second_half));
        machine_labels_second_half
        ];

    figure(); imagesc(label_comparison_first_half); xlim([0 95000]);
    ax = gca();
    ax.YTick = [];
    title('First Half of predictions and labels');
    xlabel({'Top Row = Human-Labeled Hits,','Bottom Row = Machine Learning Predicted Hits'});
    
    figure(); imagesc(label_comparison_second_half); xlim([0 95000]);
    ax = gca();
    ax.YTick = [];
    title('Second Half of predictions and labels');
    xlabel({'Top Row = Human-Labeled Hits,','Bottom Row = Machine Learning Predicted Hits'});

    figure(95);
    imagesc([repmat(5 + 3*machine_labels(:,1:27195),10,1); repmat(5 + 3*human_labels(:,1:27195),10,1); xpol_norm(:,1:27195)], [0 10]);
    colorbar;
    title('First Quarter of Full Flight');

    figure(96);
    imagesc([repmat(5 + 3*machine_labels(:,27195:54390),10,1);repmat(5 + 3*human_labels(:,27195:54390),10,1); xpol_norm(:,27195:54390)], [0 10]);
    colorbar;
    title('Second Quarter of Full Flight');

    figure(97);
    imagesc([repmat(5 + 3*machine_labels(:,54390:81585),10,1);repmat(5 + 3*human_labels(:,54390:81585),10,1); xpol_norm(:,54390:81585)], [0 10]);
    colorbar;
    title('Third Quarter of Full Flight');

    figure(98);
    imagesc([repmat(5 + 3*machine_labels(:,81585:108778),10,1);repmat(5 + 3*human_labels(:,81585:108778),10,1); xpol_norm(:,81585:108778)], [0 30]);
    colorbar;
    title('Fourth Quarter of Full Flight');
end