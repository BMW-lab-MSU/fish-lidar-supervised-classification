% SPDX-License-Identifier: BSD-3-Clause
%% Preprocess Gulf of Mexico data and create mat files
addpath('../common/')

boxDir = '../../data/fish-lidar/GulfOfMexico';
originalDataDir = [boxDir filesep 'original data'];
labelDir = [boxDir filesep 'ground truth results'];
streamingDataDir = [boxDir filesep 'streaming data'];

dataFilenames = {'DATA_FOR_09-24.mat', 'DATA_FOR_09-25.mat', 'DATA_FOR_09-26.mat', 'DATA_FOR_09-29.mat', 'DATA_FOR_09-30.mat', 'DATA_FOR_10-01.mat', 'DATA_FOR_10-02.mat', 'DATA_FOR_10-03.mat', 'DATA_FOR_10-04.mat', 'DATA_FOR_10-05.mat', 'DATA_FOR_10-06.mat', 'DATA_FOR_10-07.mat'}; 

saveFilenames = {'streaming_data_09-24.mat', 'streaming_data_09-25.mat', 'streaming_data_09-26.mat', 'streaming_data_09-29.mat', 'streaming_data_09-30.mat', 'streaming_data_10-01.mat', 'streaming_data_10-02.mat', 'streaming_data_10-03.mat', 'streaming_data_10-04.mat', 'streaming_data_10-05.mat', 'streaming_data_10-06.mat', 'streaming_data_10-07.mat'};


for i = 1:length(dataFilenames)
    % load in the data
    disp(['loading data ' dataFilenames{i}])
    load([originalDataDir filesep dataFilenames{i}], 'icath_x', 'icath_co', ...
        'x_gain', 'co_gain');
    
    icath_x(isnan(icath_x)) = 0;
    icath_co(isnan(icath_co)) = 0;
    
    icath_x = single(icath_x)';
    icath_co = single(icath_co)';
    x_gain = single(x_gain)';
    co_gain = single(co_gain)';

    save([streamingDataDir filesep saveFilenames{i}], 'icath_x', 'icath_co' ,'x_gain', 'co_gain', '-v7.3');
end