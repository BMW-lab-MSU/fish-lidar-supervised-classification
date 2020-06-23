function [hits_vector] = create_positive_label_vect(avg_width_per_fish, school_sizes, distance, fish_distances)
% Authors: Jackson Belford, Trevor Vannoy
% Usage:    avg_width_per_fish is a value estimated to be the number of fish hits in a column 
%                          on average. Generally around 4.25 for schooling
%                          fish.
%           school_sizes is the column of data containing the number of
%                          estimated fish hits per location.
%           distance is used to determine the vector length of the
%                          hits_vector.
%           fish_distances is the vector containing the column values of
%                          individual fish labels.
%
% Returns:  hits_vector, a vector of expanded fish labels. Labeling an area
%                        fish in a school style identification.

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

    temp_length = ceil(school_sizes(idx) * avg_width_per_fish);
    
    if temp_length >= MAX_SCHOOL_WIDTH
        temp_length = ceil(temp_length/4);                                   % To better agree with Kyles work, large values assume
    end                                                                    % a tight school instead of a massive school
    
    label_length(idx) = temp_length;
    
end

hits_vector = zeros(1, length(distance));
for idy = 1:N
    
    column_number(idy) = find(abs(distance-fish_distances(idy)) < DISTANCE_DIFFERENCE_THRESHOLD, 1, 'last'); % Produces a vector with ones centered around the column number
                                                                           % that corrisponds to the CSV.
    hits_vector((column_number(idy)-ceil(label_length(idy)/2)):(column_number(idy) + ceil(label_length(idy)/2))) = 1;
    
end
end

