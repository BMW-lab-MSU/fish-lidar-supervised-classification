function surface_index = find_water_surface(raw_data)
% find_water_surface Find where the water surface starts
%
% The water surface is assumed to be the location of maximum
% return LIDAR return energy. 
% 
% Inputs:
%   raw_data = raw lidar data without any surface normalization
% 
% Outputs:
%   surface_index = the indices where the water surface starts in each 
%                   column of the lidar image

% XXX: The original paper on fish detection in Yellowstone lake
% didn't define the water surface index as the maximum return energy;
% it was something similar, but not quite the same. I'm pretty sure the maximum 
% return is not necessarily the surface of the water -- it might be slightly 
% below the surface.

% for matrix inputs, max returns returns the maximum for each column 
% in the matrix; this is exactly what we want because each column
% is a lidar shot. 
[~, surface_index] = max(raw_data);