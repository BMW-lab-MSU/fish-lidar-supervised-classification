box_dir = '/mnt/data/trevor/research/afrl/box/Data/GulfOfMexico/processed data';
training_data_filename = 'training_data_09-24_undersampled75_no_plankton';

load([box_dir filesep training_data_filename])

classification_data = [data.xpol_processed; data.labels].';

classificationLearner
