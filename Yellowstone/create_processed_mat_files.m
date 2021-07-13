% SPDX-License-Identifier: BSD-3-Clause
%% Preprocess Yellowstone data and create mat files
addpath('../common');

box_dir = '/mnt/data/trevor/research/afrl/box/Data/Yellowstone';

data_filenames = {'yellowstone_wfov_20160928.processed.h5', 'yellowstone_20150923.processed.h5'};
labels_filenames = {'fish_hits_2016_with_school_size_estimates.csv', 'fish_hits_2015_with_school_size_estimates.csv'};
save_filenames = {'processed_data_2016' ,'processed_data_2015'};

% number of samples to skip when finding water surface
skip_samples = [512, 600];

% number of rows above the surface of the water to start the image
SURFACE_PAD = 0;

% number of columns to use in dimensionality reduction
REDUCED_COLUMN_HEIGHT = 60;


for i = 1:length(data_filenames)
    data_path = [box_dir filesep data_filenames{i}];
    labels_path = [box_dir filesep labels_filenames{i}];
    
    % load in the data
    disp(['loading ' data_filenames{i} '...'])
    xpol_raw = h5read(data_path, '/crosspol/radiance');             
    copol_raw = h5read(data_path, '/copol/radiance');             
    distance = h5read(data_path, '/location/distance');
    metadata.depth_increment = h5read(data_path, '/info/depth_increment');
    metadata.depth_increment = metadata.depth_increment(1);
    metadata.prf = h5read(data_path, '/info/prf');
    metadata.prf = metadata.prf(1);
    metadata.tilt = h5read(data_path, '/info/tilt');
    metadata.tilt = metadata.tilt(1);
    metadata.trigger_altitude = h5read(data_path, '/info/trigger_altitude');
    location.altitude = h5read(data_path, '/location/altitude');
    location.bearing = h5read(data_path, '/location/bearing');
    location.distance = h5read(data_path, '/location/distance');
    location.latlong = h5read(data_path, '/location/latlong');
    location.range_increment = h5read(data_path, '/location/range_increment');
    location.speed = h5read(data_path, '/location/speed');
    timestamps = h5read(data_path, '/timestamps');


    
    disp('preprocessing...')
    [xpol_processed, copol_processed] = preprocess(xpol_raw, copol_raw, SURFACE_PAD, REDUCED_COLUMN_HEIGHT, skip_samples(i));
    
    disp('creating labels...')
    labels = create_labels(labels_path, distance);

    data.xpol_raw = xpol_raw;
    data.copol_raw = copol_raw;
    data.xpol_processed = xpol_processed;
    data.copol_processed = copol_processed;
    data.labels = labels;
    data.metadata = metadata;
    data.location = location;
    data.timestamps = timestamps;
    
    save([box_dir filesep save_filenames{i}], '-struct', 'data', '-v7.3');
end
