function [model, metrics, pred_labels] = train_base(fitcfun, hyperparams, undersampling_ratio, data, labels)

MINORITY_LABEL = 0;

% undersample the majority class
idx_remove = random_undersample(labels, MINORITY_LABEL, ...
    'UndersamplingRatio', undersampling_ratio, 'Reproducible', true);

data(idx_remove, :) = [];
labels(idx_remove) = [];

% train the model
model = fitcfun(data, labels, hyperparams);

% predict labels on the training data
pred_labels = logical(predict(model, data));

% compute performance metrics
confmat = confusionmat(labels, pred_labels);
[accuracy, precision, recall, f3] = analyze_confusion(confmat);
metrics.confusion = confmat;
metrics.accuracy = accuracy;
metrics.precision = precision;
metrics.recall = recall;
metrics.f3 = f3;