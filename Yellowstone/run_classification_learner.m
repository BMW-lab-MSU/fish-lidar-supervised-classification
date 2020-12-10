box_dir = '/mnt/data/trevor/research/afrl/box/Data/Yellowstone';
training_data_filename = 'training_data_2015';

load([box_dir filesep training_data_filename])

classification_data = [data.xpol_processed; data.labels].';

classificationLearner
