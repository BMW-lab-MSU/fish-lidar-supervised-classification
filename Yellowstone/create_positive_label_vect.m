function [hits_vector] = create_positive_label_vect(avgWidthPerFish, school_sizes, distance, fish_distances)
% Authors: Jackson Belford
% Usage:    avgWidthPerFish is a value estimated to be the number of fish hits in a column 
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
end

