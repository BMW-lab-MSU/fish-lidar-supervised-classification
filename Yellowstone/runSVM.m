%% This file builds and labels the dataset for the Matlab classification suite
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% IMPORTANT: Read the README file BEFORE running
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%% Setup
% declare dataset filenames and paths here if desired

% data_dir can be a relative or absolute path; an empty string means you will
% have to navigate to your data directory in the file chooser dialogs
data_dir = '../../../Box/AFRL_Data/Data';
% data_dir = '';
hits_dir = data_dir;

data_filename = '';
hitsFileName = '';

% TODO: error handling if DATA_DIR isn't a directory

% Constants:
planeToSurf = 160;

%% Load in the classifier mat file

% TODO: where to put this mat file? does it belong with the data or with
% the code??? it's currently with the data.
if isdir(data_dir)
    load([data_dir, '/CLASSIFIER_2_QuadraticSVM']);
else
    [classifier_file, classifier_path] = uigetfile('*.mat', 'Load a classifier mat file');
    load([classifier_path filesep classifier_file]);
end

%% Load dataset

% if no dataset filename is given, let the user select a file
if isempty(data_filename)
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
%h5disp(filename);   % uncomment to see dataset names
xpol_from_plane = h5read(full_filepath, '/crosspol/radiance');                   % Initialize data vectors
surf_idx = h5read(full_filepath, '/info/surface_index');
depth_increment = h5read(full_filepath, '/info/depth_increment');
distance = h5read(full_filepath, '/location/distance');
latlong = h5read(full_filepath, '/location/latlong');

IMAGE_DEPTH = min(size(xpol_from_plane));
 
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
full_filepath = [data_dir filesep hitsFileName];
hitsMatrix = readmatrix(full_filepath);                                     % Initialize hits vectors

%% Set the distances from the csv file
fish_distances = hitsMatrix(:, 1);                                            % Initializing vectors of preselected fish hit data
fish_latitudes = hitsMatrix(:, 2);                                            % (All rows, second column)
fish_longitudes = hitsMatrix(:, 3);
school_sizes = hitsMatrix(:, 7);

%% Plot the path and the fish locations
separation = 250;                                                          % Alters the sampling frequency of the mapping
scatter(latlong(2,1:separation:size(latlong,2)),latlong(1,1:separation:size(latlong,2)),'m.'); axis square;
hold on; scatter(fish_longitudes,fish_latitudes,'ro','LineWidth',3);
hold on; scatter(-110.5555,44.4563,100,'d','filled'); hold off;
legend({'Flight Path','Fish Hits'});
xlabel('Longitude'); ylabel('Latitude');
axis([-110.6 -110.2 44.25 44.6]);

%% Creating a "positive label" vector --- Author: Jackson Belford
%  The value for average column width per fish was calculated by taking the
%  average of (the column width eyeballed / number of fish indicated by
%  csv)

% TODO: automate this? 
avgWidthPerFish = 4.57;
N = length(school_sizes);
labelLength = zeros(N, 1);
columnNumber = zeros(N, 1);

for idx = 1:N

    tempLength = ceil(school_sizes(idx) * avgWidthPerFish);
    
    if tempLength >= 55
        tempLength = ceil(tempLength/4);                                   % To better agree with Kyles work, large values assume
    end                                                                    % a tight school instead of a massive school
    
    labelLength(idx) = tempLength;
    
end

hits_vector = zeros(1, length(distance));

for idy = 1:N
    
    columnNumber(idy) = max(find(abs(distance-fish_distances(idy)) < 1.5)); % Produces a vector with ones centered around the column number
                                                                           % that corrisponds to the CSV.
    hits_vector((columnNumber(idy)-ceil(labelLength(idy)/2)):(columnNumber(idy) + ceil(labelLength(idy)/2))) = 1;
    
end

%% Normalize surface index
depth_vector = zeros(1, length(distance));
xpol_norm = zeros(planeToSurf, length(distance));

for i = 1:length(distance)                                                 % I need to personally review this chunk to understand :/
    depth_vector(i) = planeToSurf;
    if surf_idx(i) + planeToSurf - 10 > IMAGE_DEPTH
        depth_vector(i) = IMAGE_DEPTH - surf_idx(i) + 10; 
    end
end
 xpol_norm = normalize_surface_vect(xpol_from_plane, surf_idx, depth_vector, planeToSurf);
 
%% Flooring and filtering of radiance data
 for i = 1:140
     for j = 1:length(distance)
         if xpol_norm(i,j) < 2
           xpol_norm(i,j) = 0;
        end
    end
 end

%  for i = 1:length(distance)
%     threshold = sum(xpol_norm(20:140, i));
%     if threshold < 130
%        full_flight(i) = -1;
%     else
%        full_flight(i) = threshold;
%     end
%  end
% 
% k = full_flight == -1;
% xpol_norm(:,k) = [];

%% Windowing
% Reduce column height to region of interest
start = 21;
stop = 80;
x = xpol_norm(start:stop,:);
y = hits_vector;
% Clip max intensities
 MAX_INTENSITY = 10;
 x(x>MAX_INTENSITY) = MAX_INTENSITY;

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
%figure(96); imagesc([repmat(5 + 3*yhat(:,27195:54390),10,1);repmat(5 + 3*y(:,27195:54390),10,1); xpol_norm(:,27195:54390)], [0 10]); colorbar; title('Second Quarter of Full Flight');
%figure(97); imagesc([repmat(5 + 3*yhat(:,54390:81585),10,1);repmat(5 + 3*y(:,54390:81585),10,1); xpol_norm(:,54390:81585)], [0 10]); colorbar; title('Third Quarter of Full Flight');
%figure(98); imagesc([repmat(5 + 3*yhat(:,81585:108778),10,1);repmat(5 + 3*y(:,81585:108778),10,1); xpol_norm(:,81585:108778)], [0 30]); colorbar; title('Fourth Quarter of Full Flight');
