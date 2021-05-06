%% Create data
majority_class = [rand(4e6, 150)*20 + randi(5, 4e6, 150)];
minority_class = [rand(10e3, 150)*10 + randi(3, 10e3, 150)*-2];

data = [majority_class; minority_class];
labels = [false(4e6, 1); true(10e3, 1)];

%% Profile ADASYN
profile on;
[new_features, new_labels] = ADASYN(data, labels, 0.25, [], [], false);
profile off