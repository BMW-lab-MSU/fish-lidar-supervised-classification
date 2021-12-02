% SPDX-License-Identifier: BSD-3-Clause
clear
clc
addpath('../common')
box_dir = '../../data/fish-lidar/GulfOfMexico';


%% Constants
ROI_SIZE = 1000;
N_SMOOTHING_SAMPLES = 10;
N_COLUMNS = 150;
% CLASSIFIERS = {'lda', 'nnet', 'tree', 'svm', 'rusboost'};
CLASSIFIERS = {'lda', 'nnet', 'tree', 'svm'};

FILES = {'streaming_data_09-30.mat'};

%% Run the simulation
for file = FILES
    matobj = matfile([box_dir filesep 'streaming data' ...
        filesep file{:}]);
    N_INSTANCES = size(matobj, 'icath_x', 1);
    clear matobj

    DATE = regexp(file{:}, '\d\d-\d\d', 'match');

    for classifier = CLASSIFIERS
        disp(['simulating ' classifier{:}  ' on ' DATE{:} '...'])

        % Release persistent variables from moving_avg function
        clear moving_avg

        % Load the classifier
        load([box_dir filesep 'training' filesep 'models' filesep ...
            classifier{:} '_first_day']);
        load([box_dir filesep 'training' filesep 'roi_label_tuning_first_day_' ...
            classifier{:}]);
        n_labels = result.n_labels;
        clear result

        % Create system objects to stream in the data
        xpol_reader = dsp.MatFileReader([box_dir ...
            filesep 'streaming data' filesep file{:}], 'icath_x');
        copol_reader = dsp.MatFileReader([box_dir ...
            filesep 'streaming data' filesep file{:}], 'icath_co');
        xpol_gain_reader = dsp.MatFileReader([box_dir ...
            filesep 'streaming data' filesep file{:}], 'x_gain');
        copol_gain_reader = dsp.MatFileReader([box_dir ...
            filesep 'streaming data' filesep file{:}], 'co_gain');

        % Preallocate data structures
        labels = false(N_INSTANCES,1);
        ROI_labels = false(ceil(N_INSTANCES / ROI_SIZE), 1);
        data_loadtime = zeros(N_INSTANCES,1);
        preprocessing_runtime = zeros(N_INSTANCES,1);
        prediction_runtime = zeros(N_INSTANCES,1);
        total_runtime = zeros(N_INSTANCES,1);

        profile on

        % Stream in the data
        instance_num = 0;
        ROI_num = 0;
        while ~xpol_reader.isDone

            t_loop_start = tic;
            instance_num = instance_num + 1;

            % Read in new samples
            xpol_raw = xpol_reader()';
            copol_raw = copol_reader()';
            xpol_gain = xpol_gain_reader()';
            copol_gain = copol_gain_reader()';

            data_loadtime(instance_num) = toc(t_loop_start);

            t_preprocessing_start = tic;

            % Multiply by gains to convert from current
            xpol_raw = xpol_raw * xpol_gain;
            copol_raw = copol_raw * copol_gain;

            % Find the surface
            surface_idx_tmp = find_water_surface(copol_raw, 'NSkipSamples', 0);

            % Smooth the surface
            surface_idx_smooth = round(moving_avg(surface_idx_tmp, N_SMOOTHING_SAMPLES));

            % Correct the surface
            xpol_processed = correct_surface(xpol_raw, surface_idx_smooth, 0);
            xpol_processed = xpol_processed(1:N_COLUMNS);

            preprocessing_runtime(instance_num) = toc(t_preprocessing_start);

            t_prediction_start = tic;

            % Predict label
            labels(instance_num) = predict(model, xpol_processed');

            % If we have collected a full region, predicted the ROI label
            if mod(instance_num, ROI_SIZE) == 0
                ROI_num = ROI_num + 1;

                ROI_labels(ROI_num) = ...
                    sum(labels(instance_num - 1000 + 1:instance_num)) >= n_labels;
            end

            prediction_runtime(instance_num) = toc(t_prediction_start);

            total_runtime(instance_num) = toc(t_loop_start);
        end
        disp('saving results...')

        profile off

        mean_preprocessing_runtime = mean(preprocessing_runtime);
        max_preprocessing_runtime = max(preprocessing_runtime);
        std_preprocessing_runtime = std(preprocessing_runtime);
        mean_data_loadtime = mean(data_loadtime);
        max_data_loadtime = max(data_loadtime);
        std_data_loadtime = std(data_loadtime);
        mean_prediction_runtime = mean(prediction_runtime);
        max_prediction_runtime = max(prediction_runtime);
        std_prediction_runtime = std(prediction_runtime);
        mean_runtime = mean(total_runtime);
        max_runtime = max(total_runtime);
        std_runtime = std(total_runtime);

        mkdir([box_dir filesep 'runtimes'])

        save([box_dir filesep 'runtimes' filesep classifier{:} ...
            '_streaming_simulation.mat'], 'mean_preprocessing_runtime', ...
            'max_preprocessing_runtime', 'std_preprocessing_runtime', ...
            'mean_data_loadtime', 'max_data_loadtime', 'std_data_loadtime', ...
            'mean_prediction_runtime', 'max_prediction_runtime', ...
            'std_prediction_runtime', 'mean_runtime', 'max_runtime', ...
            'std_runtime', 'total_runtime', 'prediction_runtime', ...
            'data_loadtime', 'preprocessing_runtime');

        % Save profile results
        profsave(profile('info'), [box_dir filesep 'runtimes' filesep ...
            classifier{:} '_streaming_simulation_' DATE{:}]);
    end
end