% SPDX-License-Identifier: BSD-3-Clause

box_dir = '../../data/fish-lidar/Data/GulfOfMexico/runtimes';
model_names = {'svm', 'lda', 'nnet', 'tree', 'rusboost'};

for model = model_names
    load([box_dir filesep model{:} '_streaming_simulation'])
    
    % The first function call is always slow because MATLAB is
    % interpretted: https://stackoverflow.com/a/19500758
    % So I'm removing the first iteration
    prediction = prediction_runtime(2:end);
    preprocessing = preprocessing_runtime(2:end);
    total = prediction + preprocessing;
    
    model_runtimes.mean_prediction = mean(prediction);
    model_runtimes.mean_preprocessing = mean(preprocessing);
    model_runtimes.mean_total = mean(total);

    model_runtimes.max_prediction = max(prediction);
    model_runtimes.max_preprocessing = max(preprocessing);
    model_runtimes.max_total = max(total);
    
    model_runtimes.std_prediction = std(prediction);
    model_runtimes.std_preprocessing = std(preprocessing);
    model_runtimes.std_total = std(total);
    
    runtime_struct.(model{:}) = model_runtimes;
end

runtime_table = struct2table(struct2array(runtime_struct));

% convert seconds to milliseconds
runtime_table.Variables = runtime_table.Variables * 1000;

% round to 2 decimal places
runtime_table.Variables = round(runtime_table.Variables, 2);

runtime_table = [model_names' runtime_table];
runtime_table.Properties.VariableNames{1} = 'model';

writetable(runtime_table, [box_dir filesep 'runtimes.csv']);