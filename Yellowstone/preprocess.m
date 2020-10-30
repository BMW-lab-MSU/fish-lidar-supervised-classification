function preprocessed_data = preprocess(data, surface_pad, column_height)
%% Data preprocessing
%% Normalize surface index
% The height of the water does not start at the same row in each LIDAR
% shot. This could potentially cause problems with shift-variant
% classifiers, so we want the height of the water to always start at 
% the same row in every LIDAR shot. 
surface_index = find_water_surface(data);
preprocessed_data = normalize_surface_height(data, surface_index, surface_pad);

%% Dimensionality reduction
% Reduce column height to region of interest. The resulting image height
% needs to be the same as what the classifier was trained against, which 
% in this case is 60. 
preprocessed_data = preprocessed_data(1:column_height,:);
end
