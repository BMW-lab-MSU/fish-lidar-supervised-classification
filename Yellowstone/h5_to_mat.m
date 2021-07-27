% SPDX-License-Identifier: BSD-3-Clause
%% Convert h5 files into mat files for ease of use when simulating real-time processing.
addpath('../common');

box_dir = '../../data/fish-lidar/Yellowstone';

data_filenames = {'yellowstone_wfov_20160928.processed.h5', 'yellowstone_20150923.processed.h5'};
save_filenames = {'yellowstone_wfov_20160928.mat' ,'yellowstone_20150923.mat'};

for i = 1:length(data_filenames)
    data_path = [box_dir filesep data_filenames{i}];

    % load in the data
    disp(['loading ' data_filenames{i} '...'])
    
    % convert data to singles for memory-efficiency
    % the transpose is necessary because dsp.MatFileReader reads along the first dimension,
    % our data is arranged such that the instances are the second dimension
    xpol_raw = single(h5read(data_path, '/crosspol/radiance'))';
    copol_raw = single(h5read(data_path, '/copol/radiance'))';

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

    data.xpol_raw = xpol_raw;
    data.copol_raw = copol_raw;
    data.metadata = metadata;
    data.location = location;
    data.timestamps = timestamps;

    save([box_dir filesep save_filenames{i}], '-struct', 'data', '-v7.3');
end