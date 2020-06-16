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
data_dir = 'resources/data';
classifier_dir = 'resources/classifiers/';
hits_dir = 'resources/labels/';

data_filename = 'yellowstone_wfov_20160928.processed.h5';                  % declare dataset filenames and paths here if desired
hitsFileName = 'fish_hits_2016_with_school_size_estimates.csv';

% TODO: error handling if DATA_DIR isn't a directory

% Constants (TODO: Automate these constants):
PLANE_TO_SURFACE = 160;
SURFACE_PAD = 10;
MAX_INTENSITY = 11;

%% Load in the classifier mat file

% TODO: where to put this mat file? does it belong with the data or with
% the code??? it's currently with the data.
if isdir(classifier_dir)
    load([classifier_dir, '/CLASSIFIER_2_QuadraticSVM']);
else
    [classifier_file, classifier_path] = uigetfile('*.mat', 'Load a classifier mat file');
    load([classifier_path filesep classifier_file]);
end

%% Load dataset
                                        
if isempty(data_filename)                                                  % if no dataset filename is given, let the user select a file
    disp('Select a dataset')
    if isdir(data_dir)
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
depth_increment = h5read(full_filepath, '/info/depth_increment');
distance = h5read(full_filepath, '/location/distance');
latlong = h5read(full_filepath, '/location/latlong');

% Get the image dimensions; this assumes the image has more columns than rows
IMAGE_HEIGHT = min(size(xpol_from_plane));
IMAGE_WIDTH = max(size(xpol_from_plane));
 
%% Load Human Labeled fish hits

                                                                           % if no ground truth fish hits filename is given, let the user select a file
if isempty(hitsFileName)
    disp('Select a ground truth fish hits file')
    if isdir(data_dir)
        [hitsFileName, data_dir] = uigetfile([data_dir, '/*.csv'], 'Select a ground truth csv file');
    else
        [hitsFileName, data_dir] = uigetfile('*.csv');
    end
end

                                                                           % load in the ground truth fish hits
full_filepath = [hits_dir filesep hitsFileName];
hitsMatrix = readmatrix(full_filepath);                                    % Initialize hits values

%% Set the distances from the csv file
fish_distances = hitsMatrix(:, 1);                                            % Initializing vectors of preselected fish hit data
fish_latitudes = hitsMatrix(:, 2);                                            % (All rows, second column)
fish_longitudes = hitsMatrix(:, 3);
school_sizes = hitsMatrix(:, 7);

%% Creating a "positive label" vector --- Author: Jackson Belford
%  The value for average column width per fish was calculated by taking the
%  average of (the column width eyeballed / number of fish indicated by
%  csv)

% TODO: automate this? 
avgWidthPerFish = 4.57;
hits_vector = create_positive_label_vect(avgWidthPerFish, school_sizes, distance, fish_distances);

%% Plot the path and the fish locations
% Simply a visual graphing process
separation = 250;                                                          % Alters the sampling frequency of the mapping
scatter(latlong(2,1:separation:size(latlong,2)),latlong(1,1:separation:size(latlong,2)),'m.'); axis square;
hold on; scatter(fish_longitudes,fish_latitudes,'ro','LineWidth',3);
hold on; scatter(-110.5555,44.4563,100,'d','filled'); hold off;
legend({'Flight Path','Fish Hits'});
xlabel('Longitude'); ylabel('Latitude');
axis([-110.6 -110.2 44.25 44.6]);


%% Data preprocessing
%% Normalize surface index
depth_vector = zeros(1, IMAGE_WIDTH);
xpol_norm = zeros(PLANE_TO_SURFACE, IMAGE_WIDTH);

% set surface depth vectors
for i = 1:IMAGE_WIDTH                                                 % I need to personally review this chunk to understand :/
    depth_vector(i) = PLANE_TO_SURFACE;
    if surf_idx(i) + PLANE_TO_SURFACE - SURFACE_PAD > IMAGE_HEIGHT
        depth_vector(i) = IMAGE_HEIGHT - surf_idx(i) + SURFACE_PAD; 
    end
end
xpol_norm = normalize_surface_vect(xpol_from_plane, surf_idx, depth_vector, PLANE_TO_SURFACE);
 
%% Flooring and filtering of radiance data
for j = 1:IMAGE_WIDTH
    if xpol_norm(:,j) < 2
        xpol_norm(:,j) = 0;
    end
end


%% Windowing
% Reduce column height to region of interest
start = 10;
stop = 69;
x = xpol_norm(start:stop,:);
y = hits_vector;
% Clip max intensities
 x(x>MAX_INTENSITY) = MAX_INTENSITY;

%% Do the classification
% Change cost for misclassifying fish (It is worse to miss a fish.)
cost = [0 1; 20 0];

data_for_classification_learner = [x;y]';

%% Now run the classification learner toolbox!

yhat_cheating = QuadraticSVM.predictFcn(x')';

% yhat = yhat_cross_validated;
 yhat = yhat_cheating;

%% Specific label graphing (Before Area Application)
figure();
subplot(211); stem(y); title('Actual Labels');
subplot(212); stem(yhat); title('Predicted Labels');

figure(); imagesc(x,[0 10]); xlim([0 100000]); ylim([1 60]);
xlabel('LIDAR Image Data');

c = confusionmat(y,yhat);
figure(); confusionchart(c,{'No Fish','Fish'})

%% machine labeled area block

N = length(yhat);
window = 2500;
index = window;
trigger = 0;
while trigger == 0
   if index < length(yhat)
        if yhat(index) == 1
             yhat((index-window/2):(index+window/2)) = 1;
             index = index + window;
        else
             index = index + 1;
        end
    else
        trigger = 1;
            
    end
    
end

%% Human Labeled area block
% Setting individual labels to blocks of windowed size

N = length(y);
index = window;
trigger = 0;
while trigger == 0
   if index < length(y)
        if y(index) == 1
             y((index-window/2):(index+window/2)) = 1;
             index = index + window;
        else
             index = index + 1;
        end
    else
        trigger = 1;
            
    end
    
end

%% Graphical Analysis


yHalf1 = y(1:ceil(length(y)/2));
yHalf2 = y(ceil(length(y)/2):length(y));
yhatHalf1 = yhat(1:ceil(length(yhat)/2));
yhatHalf2 = yhat(ceil(length(yhat)/2):length(yhat));

labelmat1 = [yHalf1;yHalf1;yHalf1;yHalf1;yHalf1;zeros(6,length(yHalf1));yhatHalf1;yhatHalf1;yhatHalf1;yhatHalf1;yhatHalf1];
labelmat2 = [yHalf2;yHalf2;yHalf2;yHalf2;yHalf2;zeros(6,length(yHalf2));yhatHalf2;yhatHalf2;yhatHalf2;yhatHalf2;yhatHalf2];

figure(); subplot(311); imagesc(labelmat1); xlim([0 95000]);
title('First Half of predictions and labels');
xlabel({'Top Row = Human-Labeled Hits,','Bottom Row = Machine Learning Predicted Hits'});
figure(); subplot(311); imagesc(labelmat2); xlim([0 95000]);
title('Second Half of predictions and labels');
xlabel({'Top Row = Human-Labeled Hits,','Bottom Row = Machine Learning Predicted Hits'});

%figure(95); imagesc([repmat(5 + 3*yhat(:,1:27195),10,1); repmat(5 + 3*y(:,1:27195),10,1); xpol_norm(:,1:27195)], [0 10]); colorbar; title('First Quarter of Full Flight');
figure(96); imagesc([repmat(5 + 3*yhat(:,27195:54390),10,1);repmat(5 + 3*y(:,27195:54390),10,1); xpol_norm(:,27195:54390)], [0 10]); colorbar; title('Second Quarter of Full Flight');
figure(97); imagesc([repmat(5 + 3*yhat(:,54390:81585),10,1);repmat(5 + 3*y(:,54390:81585),10,1); xpol_norm(:,54390:81585)], [0 10]); colorbar; title('Third Quarter of Full Flight');
%figure(98); imagesc([repmat(5 + 3*yhat(:,81585:108778),10,1);repmat(5 + 3*y(:,81585:108778),10,1); xpol_norm(:,81585:108778)], [0 30]); colorbar; title('Fourth Quarter of Full Flight');
