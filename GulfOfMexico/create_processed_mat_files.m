boxDir = '/mnt/data/trevor/research/afrl/box/Data/GulfOfMexico';
originalDataDir = [boxDir filesep 'original data'];
labelDir = [boxDir filesep 'labels'];
processedDataDir = [boxDir filesep 'processed data'];


dataFilenames = {'DATA_FOR_09-24.mat', 'DATA_FOR_09-25.mat', 'DATA_FOR_09-26.mat', 'DATA_FOR_09-29.mat', 'DATA_FOR_09-30.mat', 'DATA_FOR_10-01.mat', 'DATA_FOR_10-02.mat', 'DATA_FOR_10-03.mat', 'DATA_FOR_10-04.mat', 'DATA_FOR_10-05.mat', 'DATA_FOR_10-06.mat', 'DATA_FOR_10-07.mat'}; 

saveFilenames = {'processed_data_09-24.mat', 'processed_data_09-25.mat', 'processed_data_09-26.mat', 'processed_data_09-29.mat', 'processed_data_09-30.mat', 'processed_data_10-01.mat', 'processed_data_10-02.mat', 'processed_data_10-03.mat', 'processed_data_10-04.mat', 'processed_data_10-05.mat', 'processed_data_10-06.mat', 'processed_data_10-07.mat'};


% number of rows above the surface of the water to start the image
SURFACE_PAD = 0;

% number of columns to use in dimensionality reduction
% 150 is kinda arbitrary based upon looking at how the lidar reflectance
% trails off with increasing depth; talking to Jim about the lidar's penetration
% depth and expected depths of targets would give us a more justified number
REDUCED_COLUMN_HEIGHT = 150;


for i = 1:length(dataFilenames)
    % load in the data
    load([originalDataDir filesep dataFilenames{i}])
    
    disp('preprocessing...')
    % multiply cathode current by associated gain values
    xpol_raw = icath_x .* x_gain;
    copol_raw = icath_co .* co_gain;

    [xpol_processed, copol_processed] = preprocess(xpol_raw, copol_raw, SURFACE_PAD, REDUCED_COLUMN_HEIGHT);
    
    disp('creating labels...')
    labels = create_labels(originalDataDir, labelDir, dataFilenames{i});
    
    data.xpol_raw = xpol_raw;
    data.copol_raw = copol_raw;
    data.xpol_processed = xpol_processed;
    data.copol_processed = copol_processed;
    data.labels = labels;
    data.metadata = struct('latitude', lat, 'longitude', long, 'temperature', temp, 'tilt', tilt, 'time', time);

    save([processedDataDir filesep saveFilenames{i}], 'xpol_processed', 'labels');
end
    