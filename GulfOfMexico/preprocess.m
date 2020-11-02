function [xpol_processed, copol_processed] = preprocess(xpol_raw, copol_raw, surface_pad, column_height)
%% Normalize surface index
% The height of the water does not start at the same row in each LIDAR
% shot. This could potentially cause problems with shift-variant
% classifiers, so we want the height of the water to always start at 
% the same row in every LIDAR shot. 
surface_index = find_water_surface(copol_raw);
xpol_processed = normalize_surface_height(xpol_raw, surface_index, surface_pad);
copol_processed = normalize_surface_height(copol_raw, surface_index, surface_pad);

%% Dimensionality reduction
xpol_processed = xpol_processed(1:column_height,:);
copol_processed = copol_processed(1:column_height,:);
end
