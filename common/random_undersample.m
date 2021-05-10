function remove = random_undersample(labels, undersample_class, opts)
% random_undersample randomly undersample a given class label
%
%   random_undersample returns indices of majority class samples; these indices
%   can be used to remove the samples from the dataset. Indices are returned
%   because of memory-usage considerations. If the labels and data matrix were
%   modified in-place with this function, MATLAB would create copies of the
%   matrices, which would result in extra memory usage.
%
%   remove = random_undersample(labels, undersample_class) returns indices for
%   a random subset of 75% of the labels corresponding to the undersample_class
%   label.
%
%   remove = random_undersample(labels, undersample_class, ...
%   'UndersamplingRatio', ratio) undersamples the undersample_class by ratio,
%   which must be between 0 and 1.

arguments
    labels (1,:) 
    undersample_class (1,1)
    opts.UndersamplingRatio (1,1) double {mustBeInRange(opts.UndersamplingRatio, 0, 1)} = 0.75
    opts.Reproducible (1,1) logical = false
end

if opts.Reproducible
    rng(0, 'twister');
end

idx = find(labels == undersample_class);
remove = idx(randperm(numel(idx), ceil(opts.UndersamplingRatio * numel(idx))));