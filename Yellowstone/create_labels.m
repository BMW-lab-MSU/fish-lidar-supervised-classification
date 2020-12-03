function labels_human = create_labels(label_file, distance)
% CREATE_LABELS creates ground truth labels for the Yellowstone data
%
% Inputs:
%   label_file - the full path to the ground truth csv file
%   distance   - flight distance from h5 data file
%
% Outputs:
%   labels_human - ground truth labels

% Authors: Jackson Belford, Trevor Vannoy

%% Load labels file
hits_matrix = readmatrix(label_file);

%% Set the distances from the csv file
fish_distances = hits_matrix(:, 1);                                            
fish_latitudes = hits_matrix(:, 2);                                            
fish_longitudes = hits_matrix(:, 3);
school_sizes = hits_matrix(:, 7);

%% Creating a "positive label" vector --- Author: Jackson Belford
%  The value for average column width per fish was calculated by taking the
%  average of (the column width eyeballed / number of fish indicated by
%  csv)

AVG_WIDTH_PER_FISH = 4.57;
MAX_SCHOOL_WIDTH = 55;

% The flight distances reported in the dataset and in the human labeled fish
% hits do not match exactly, so we need a distance threshold what it means for
% two distances to be the "same"
DISTANCE_DIFFERENCE_THRESHOLD = 1.5;

N = length(school_sizes);
label_length = zeros(N, 1);
column_number = zeros(N, 1);

% Set the length of the labels based upon the fish school size
for idx = 1:N

    temp_length = ceil(school_sizes(idx) * AVG_WIDTH_PER_FISH);
    
    if temp_length >= MAX_SCHOOL_WIDTH
        temp_length = ceil(temp_length/4);                                   % To better agree with Kyles work, large values assume
    end                                                                    % a tight school instead of a massive school
    
    label_length(idx) = temp_length;
    
end

labels_human = zeros(1, length(distance));
for idy = 1:N
    
    column_number(idy) = find(abs(distance-fish_distances(idy)) < DISTANCE_DIFFERENCE_THRESHOLD, 1, 'last'); % Produces a vector with ones centered around the column number
                                                                           % that corrisponds to the CSV.
    labels_human((column_number(idy)-ceil(label_length(idy)/2)):(column_number(idy) + ceil(label_length(idy)/2))) = 1;
    
end
end