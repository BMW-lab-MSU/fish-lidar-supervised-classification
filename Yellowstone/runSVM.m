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

% this can be a relative or absolute path
data_dir = 'Data';
hits_dir = 'Data';

data_filename = '';
hitsFileName = '';

% TODO: error handling if DATA_DIR isn't a directory

% load in the classifier mat file
% TODO: where to put this mat file? does it belong with the data or with
% the code??? it's currently with that data. hard coding this for now...
load 'Data/CLASSIFIER_2_QuadraticSVM.mat';

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
 
%% Load ground truth fish hits

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

% TODO: this is really gross :^0 let's modify the csv files to include these
% estimates so our code can be more generic
% hitsMatrix(:, 6) = [16, 22, 14, 60, 30, 12, 8];
% TO-DONE on one fish_hits file, but leaving in here right now because we don't have commit
% messages :(

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

%% Loop through

DEPTH = 160;
        
N = length(fish_distances);                                                % Creates a variable equal to the number of known fish hits

for idx = 1:N
  
    cur_distance = fish_distances(idx);                                    % Define the current values according to indexed fish hit
    cur_latitude = fish_latitudes(idx);
    cur_longitude = fish_longitudes(idx);
    
    % Find the matrix column corresponding to that distance
    dif = cur_distance-distance;                                           % This bit of code takes the current distance and relates
    col(idx) = find(abs(dif)==min(abs(dif)));                              % it to the distance recorded. The lowest value of the dif
    col2(idx) = find_latlong(cur_latitude,cur_longitude,latlong);          % vector corrisponds to the correct sample column
    
    % Plot the cross-polarization data
    xdata = distance(col(idx)-500:col(idx)+500);
    xdata_col = col(idx)-500:col(idx)+500;
    ydata = 1:DEPTH;
    
    xpol_data = xpol_from_plane(:,col(idx)-500:col(idx)+500);
    xpol_surface_data = normalize_surface(xpol_data,surf_idx(col(idx)-500:col(idx)+500),DEPTH);
%    figure();
%    imagesc(xdata,ydata,xpol_surface_data,[0 10]);
%    title(['Distance = ' num2str(cur_distance)]);
    
    xpol_surf = xpol_surface_data(1:140,:);                                % This code must floor values near the surface
                                                                           % to create better contrast
    for i = 1:140
        for j = 1:length(xpol_surf)
            if xpol_surf(i,j) < 2
               xpol_surf(i,j) = 0;
            end
        end
    end
end 

%% Creating a "positive label" vector --- Author: Jackson Belford
%  The value for average column width per fish was calculated by taking the
%  average of (the column width eyeballed / number of fish indicated by
%  csv)

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
xpol_norm = zeros(160, length(distance));

for i = 1:length(distance)                                                 % I need to personally review this chunk to understand :/
    depth_vector(i) = 160;
    if surf_idx(i) + 160 - 10 > 2048
        depth_vector(i) = 2048 - surf_idx(i) + 10; 
    end
end
 xpol_norm = normalize_surface_vect(xpol_from_plane, surf_idx, depth_vector);
 
%% Flooring and filtering of radiance data
 full_flight = zeros(1,length(distance));
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

figure();
subplot(211); stem(y); title('Actual Labels');
subplot(212); stem(yhat); title('Predicted Labels');

labelmat = [y;y;y;y;y;zeros(5,length(y));yhat;yhat;yhat;yhat;yhat];
%figure(); subplot(311); imagesc(labelmat); xlim([640 670]);
%xlabel({'Top Row = Human-Labeled Hits,','Bottom Row = Machine Learning Predicted Hits'});
figure(); imagesc(x,[0 10]); xlim([640 670]); ylim([1 30]);
xlabel('LIDAR Image Data');

c = confusionmat(y,yhat);
figure(); confusionchart(c,{'No Fish','Fish'})

%figure(95); imagesc([repmat(5 + 3*yhat_cheating(:,1:27195),10,1); repmat(5 + 3*hits_vector(:,1:27195),10,1); xpol_norm(:,1:27195)], [0 10]); colorbar; title('First Quarter of Full Flight');
%figure(96); imagesc([repmat(5 + 3*yhat_cheating(:,27195:54390),10,1);repmat(5 + 3*hits_vector(:,27195:54390),10,1); xpol_norm(:,27195:54390)], [0 10]); colorbar; title('Second Quarter of Full Flight');
%figure(97); imagesc([repmat(5 + 3*yhat_cheating(:,54390:81585),10,1);repmat(5 + 3*hits_vector(:,54390:81585),10,1); xpol_norm(:,54390:81585)], [0 10]); colorbar; title('Third Quarter of Full Flight');
%figure(98); imagesc([repmat(5 + 3*yhat_cheating(:,81585:108778),10,1);repmat(5 + 3*hits_vector(:,81585:108778),10,1); xpol_norm(:,81585:108778)], [0 30]); colorbar; title('Fourth Quarter of Full Flight');
