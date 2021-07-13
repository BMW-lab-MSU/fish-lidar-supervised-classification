function surface_index = find_water_surface(raw_data, options)
% find_water_surface Find where the water surface starts
%
%   surface = find_water_surface(raw_data) returns the row where the water
%   starts in each lidar shot. The surface is defined as the closest
%   point before the max that is 1% of the max. 
%
%   surface = find_water_surface(raw_data, 'Algorithm', alg) uses alg
%   to find the water surface. Available algorithms are
%       - 'max'         : the surface is defined as the max in each lidar shot
%       - 'before max'  : the surface is defined as the closest point
%                         before the max that is 1% of the max
%
%
%   surface = find_water_surface(raw_data,..., 'PercentOfMax', pct) defines
%   the surface as the before the max that is pct of the max; this is only 
%   applicable when algorithm is 'before max'.
%
%   surface = find_water_surface(raw_data,..., 'NSmoothingSamples', n) uses
%   an n-tap moving average filter to smooth the surface
%
%   surface = find_water_surface(raw_data,..., 'NSkipSamples', n) skips the
%   first n samples when finding the water surface. This helps deal with any
%   strong reflections that may have happened significantly above the water. 
%   The default value is n = 512

% SPDX-License-Identifier: BSD-3-Clause
    
arguments
    raw_data (:,:) double
    options.Algorithm (1,:) char ...
        {mustBeMember(options.Algorithm, {'before max', 'max'})} = 'before max'
    options.NSmoothingSamples (1,1) double {mustBeInteger, mustBePositive} = 1
    options.NSkipSamples (1,1) double {mustBeInteger, mustBeNonnegative} = 512
    options.PercentOfMax (1,1) double {mustBeInRange(options.PercentOfMax, 0, 1)} = 0.25;
end

% we are assuming that the lidar shots are oriented as columns
num_lidar_shots = size(raw_data, 2);

surface_index = zeros(num_lidar_shots, 1);

% for matrix inputs, max returns returns the maximum for each column 
% in the matrix; this is exactly what we want because each column
% is a lidar shot. 
[max_values, max_indices] = max(raw_data(options.NSkipSamples + 1:end, :));

% skipping NSkipSamples changes the indices return by max; correct the indices
% by adding NSkipSamples
max_indices = max_indices + options.NSkipSamples;

switch options.Algorithm
case 'before max'
    for shot = 1:num_lidar_shots
        max_val = max_values(shot);
        max_idx = max_indices(shot);
        
        % sometimes there isn't a sample that satifies the "percent of max"
        % criteria, so we need to catch that and assign a sane value
        try
            surface_tmp = find(...
                raw_data(options.NSkipSamples + 1:max_idx, shot) <= ...
                options.PercentOfMax * max_val, 1, 'last');
            
            surface_index(shot) = surface_tmp + options.NSkipSamples;
        catch
            if shot > 1
                surface_index(shot) = surface_index(shot - 1);
            else
                surface_index(shot) = 1 + options.NSkipSamples;
            end
        end
    end
case 'max'
    surface_index = max_indices;
end

if options.NSmoothingSamples ~= 1
    % smooth data with a trailing moving average filter
    surface_index = movmean(surface_index, [options.NSmoothingSamples - 1, 0]);
    
    % the surface index needs to be an integer
    surface_index = round(surface_index);
end
    