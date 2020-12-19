function [xpol_processed, copol_processed] = preprocess(xpol_raw, copol_raw, surface_pad, column_height)
% PREPROCESS preprocess xpol and copol data
%
% The preprocessing comprises 1) finding the surface of the water
% in the copol data, 2) surface correction, and 3) dimensionality reduction.
%
% Inputs:
%   xpol_raw        - raw xpol data
%   copol_raw       - raw copol data
%   surface_pad     - number of rows above the surface to include in data
%   column_height   - number of rows to use in the final data
%
% Outputs:
%   xpol_processed  - preprocessed xpol data
%   copol_processed - preprocessed copol data

%% Surface correction
% The height of the water does not start at the same row in each LIDAR
% shot. This could potentially cause problems with shift-variant
% classifiers, so we want the height of the water to always start at 
% the same row in every LIDAR shot. 
surface_index = find_water_surface(copol_raw, 'NSkipSamples', 0, 'NSmoothingSamples', 10);
xpol_processed = correct_surface(xpol_raw, surface_index, surface_pad);
copol_processed = correct_surface(copol_raw, surface_index, surface_pad);

%% Dimensionality reduction
xpol_processed = xpol_processed(1:column_height,:);
copol_processed = copol_processed(1:column_height,:);
end