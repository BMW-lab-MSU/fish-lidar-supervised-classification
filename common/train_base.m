function model = train_base(fitcfun, hyperparams, undersampling_ratio, data, labels, roi_indicator)

MINORITY_LABEL = 0;

% undersample the majority class
idx_remove = random_undersample(roi_indicator, MINORITY_LABEL, ...
    'UndersamplingRatio', undersampling_ratio, 'Reproducible', true);

data(idx_remove) = [];
labels(idx_remove) = [];

% train the model
model = fitcfun(cell2mat(data), cell2mat(labels), hyperparams);