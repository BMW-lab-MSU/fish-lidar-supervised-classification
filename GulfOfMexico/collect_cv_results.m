%% Setup
addpath('../common');

box_dir = '/Users/trevvvy/research/afrl/data/fish-lidar/GulfOfMexico';

model_names = {'svm', 'lda', 'nnet', 'tree', 'rusboost'};

%% Collect first day results
for model = model_names
    tmp = load([box_dir filesep 'training' filesep ...
        'hyperparameter_tuning_first_day_roi_' model{:}]);
    
    results.(model{:}).params = tmp.best_params;
    results.(model{:}).shot.cv_results = ...
        tmp.results.UserDataTrace{tmp.results.IndexOfMinimumTrace(end)};
    results.(model{:}).shot.confusion = ...
        sum(results.(model{:}).shot.cv_results.confusion, 3);
    
    [a,p,r,f3] = analyze_confusion(results.(model{:}).shot.confusion);
    results.(model{:}).shot.accuracy = a;
    results.(model{:}).shot.precision = p;
    results.(model{:}).shot.recall = r;
    results.(model{:}).shot.f3 = f3;

    tmp = load([box_dir filesep 'training' filesep ...
        'roi_label_tuning_first_day_' model{:}]);
    
    results.(model{:}).roi.n_labels = tmp.result.n_labels;
    results.(model{:}).roi.confusion = tmp.result.confusion(:,:,tmp.result.min_idx);

    [a,p,r,f3] = analyze_confusion(results.(model{:}).roi.confusion);
    results.(model{:}).roi.accuracy = a;
    results.(model{:}).roi.precision = p;
    results.(model{:}).roi.recall = r;
    results.(model{:}).roi.f3 = f3;
end

save([box_dir filesep 'training' filesep 'cv_results_first_day'], 'results');


%% Collect 80/20 results
for model = model_names
    tmp = load([box_dir filesep 'training' filesep ...
        'hyperparameter_tuning_roi_' model{:}]);
    
    results.(model{:}).params = tmp.best_params;
    results.(model{:}).shot.cv_results = ...
        tmp.results.UserDataTrace{tmp.results.IndexOfMinimumTrace(end)};
    results.(model{:}).shot.confusion = ...
        sum(results.(model{:}).shot.cv_results.confusion, 3);
    
    [a,p,r,f3] = analyze_confusion(results.(model{:}).shot.confusion);
    results.(model{:}).shot.accuracy = a;
    results.(model{:}).shot.precision = p;
    results.(model{:}).shot.recall = r;
    results.(model{:}).shot.f3 = f3;

    tmp = load([box_dir filesep 'training' filesep ...
        'roi_label_tuning_' model{:}]);
    
    results.(model{:}).roi.n_labels = tmp.result.n_labels;
    results.(model{:}).roi.confusion = tmp.result.confusion(:,:,tmp.result.min_idx);

    [a,p,r,f3] = analyze_confusion(results.(model{:}).roi.confusion);
    results.(model{:}).roi.accuracy = a;
    results.(model{:}).roi.precision = p;
    results.(model{:}).roi.recall = r;
    results.(model{:}).roi.f3 = f3;
end

save([box_dir filesep 'training' filesep 'cv_results'], 'results');