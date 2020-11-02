function surface_index = find_water_surface(raw_data, alg_type)
% find_water_surface Find where the water surface starts
%
% The water surface is assumed to be the location of maximum
% return LIDAR return energy. 
% 
% Inputs:
%   raw_data = raw lidar data without any surface normalization
%   alg_type = surface finding algorithm type: 'before_max' or 'max'
%               'before_max' defines the surface as the closest point
%               before the max that is 1% of the max; this definition is
%               from https://doi.org/10.1117/1.OE.56.3.031221
%               'max' defines the the surface as the max/peak of each lidar shot
% 
% Outputs:
%   surface_index = the indices where the water surface starts in each 
%                   column of the lidar image


if nargin < 2
    alg_type = 'before_max';
end

% we are assuming that the lidar shots are oriented as columns
num_lidar_shots = length(raw_data(1, :));

surface_index = zeros(1, num_lidar_shots);

% for matrix inputs, max returns returns the maximum for each column 
% in the matrix; this is exactly what we want because each column
% is a lidar shot. 
[max_values, max_indices] = max(raw_data);

switch alg_type
case 'before_max'
    for idx = 1:num_lidar_shots
        surface_temp = find(raw_data(1:max_indices(idx), idx) ...
            <= 0.01 * max_values(idx), 1, 'last');
    	if surface_temp
	    surface_index(idx) = surface_temp;
	else
	    surface_index(idx) = 1;
	end
    end
case 'max'
    surface_index = max_indices;
otherwise
    error(['alg_type ', alg_type, ' is not a recongnized algorithm type']);
end
