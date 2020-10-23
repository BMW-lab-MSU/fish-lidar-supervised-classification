
box_dir = '/mnt/data/trevor/research/afrl/box/Data/Yellowstone';

data_filenames = {'yellowstone_wfov_20160928.processed.h5', 'yellowstone_20150923.processed.h5'};
labels_filenames = {'fish_hits_2016_with_school_size_estimates.csv', 'fish_hits_2015_with_school_size_estimates.csv'};
save_filenames = {'preprocessed_data_2016' ,'preprocessed_data_2015'};

% number of rows above the surface of the water to start the image
SURFACE_PAD = 0;

% number of columns to use in dimensionality reduction
REDUCED_COLUMN_HEIGHT = 60;


for i = 1:length(data_filenames)
    data_path = [box_dir filesep data_filenames{i}];
    labels_path = [box_dir filesep labels_filenames{i}];
    
    % load in the data
    disp(['loading ' data_filenames{i} '...'])
    xpol_data = h5read(data_path, '/crosspol/radiance');             
    surf_idx = h5read(data_path, '/info/surface_index');
    distance = h5read(data_path, '/location/distance');
    
    disp('preprocessing...')
    xpol_processed = preprocess(xpol_data, surf_idx, SURFACE_PAD, REDUCED_COLUMN_HEIGHT);
    
    disp('creating labels...')
    labels = create_labels(labels_path, distance);
    
    save([box_dir filesep save_filenames{i}], 'xpol_processed', 'labels');
end
    
    


 




