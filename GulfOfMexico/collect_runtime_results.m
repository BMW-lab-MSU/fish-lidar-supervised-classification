% SPDX-License-Identifier: BSD-3-Clause

box_dir = '../../data/fish-lidar/Data/GulfOfMexico/runtimes';
model_names = {'svm', 'lda', 'nnet', 'tree', 'rusboost'};

for model = model_names
    load([box_dir filesep model{:} '_streaming_simulation'])
    
    total = prediction_runtime + preprocessing_runtime;
    
    model_runtimes.mean_prediction = mean_prediction_runtime;
    model_runtimes.mean_preprocessing = mean_preprocessing_runtime;
    model_runtimes.mean_total = mean(total);

    model_runtimes.max_prediction = max_prediction_runtime;
    model_runtimes.max_preprocessing = max_preprocessing_runtime;
    model_runtimes.max_total = max(total);
    
    model_runtimes.std_prediction = std_prediction_runtime;
    model_runtimes.std_preprocessing = std_preprocessing_runtime;
    model_runtimes.std_total = std(total);
    
    runtime_struct.(model{:}) = model_runtimes;
end

runtime_table = struct2table(struct2array(runtime_struct));

% convert seconds to milliseconds
runtime_table.Variables = runtime_table.Variables * 1000;

runtime_table = [model_names' runtime_table];
runtime_table.Properties.VariableNames{1} = 'model';

writetable(runtime_table, [box_dir filesep 'runtimes.csv']);
    