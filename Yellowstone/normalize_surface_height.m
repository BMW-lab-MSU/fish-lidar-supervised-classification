function normalized_data = normalize_surface_height(data, surface_index, surface_pad)
% normalize_surface_height Make the surface height constant across an image
%
% normalized_data = normalize_surface_height(data, surface_index, surface_pad)
%
% This function shifts the incoming data such that the water's surface height
% is at a constant position for every column on the image. Putting the surface
% at a constant row should compensate for the shift-variant nature of some 
% classifiers.a
%
% Inputs:
%   data = the LIDAR image data to normalize
%   surface_index = the row where the surface starts in each column of data
%   surface_pad = how far above or below the surface to start the image
%
% Outputs:
%   normalized_data = LIDAR image data with the surface at a constant height

    normalized_data = zeros(size(data));

    for i = 1:length(data)
        % start the image a little bit above the actual surface of the water
        surface_start = surface_index(i) - surface_pad;

        normalized_data(1:end - surface_start + 1, i) = data(surface_start:end, i);
    end
end
