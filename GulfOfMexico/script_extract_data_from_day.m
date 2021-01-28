%% script_extract_data_from_day
close all; clear all; clc;
tic;

data_dir = '/home/trevor/research/afrl/Fish lidar & machine learning/GM11'
save_dir = '/home/trevor/research/afrl/box/Data/GulfOfMexico/original data'

DAYS = {'09-24', '09-25', '09-26', '09-29', '09-30', '10-01', '10-02', '10-03', '10-04', '10-05', '10-06', '10-07'};

for DAY = DAYS

    % Find all .png files in the day's folder
    filelist = dir([data_dir filesep DAY{:} filesep '*.png']);

    % Count the number of files
    numfiles = size(filelist,1);

    %% Analyze all files
    for i = 1:numfiles
        clc; display(['Extracting information from image ' num2str(i) ' of ' num2str(numfiles) ' (for day ' DAY{:} ').']);
        cur_file = [filelist(i).folder filesep filelist(i).name];
        all_data(i) = extract_data_from_png(cur_file);
    end

    %% Concatenate the data

    % Pre-allocate the data; dynamic concatenation takes too long
    num_shots = 0;
    for i = 1:numfiles
        num_shots = num_shots + length(all_data(i).time);
    end

    % Vectors; each entry corresponds to a single shot
    time = zeros(1,num_shots);
    lat = zeros(1,num_shots);
    lon = zeros(1,num_shots);
    co_gain = zeros(1,num_shots);
    x_gain = zeros(1,num_shots);
    tilt = zeros(1,num_shots);
    temp = zeros(1,num_shots);

    % Matrices; each column corresponds to a single shot
    icath_co = zeros(1000,num_shots);
    icath_x = zeros(1000,num_shots);

    % Keep track of the original spot of each shot in the PNG image
    date = cell(1,num_shots);
    PNG_file = cell(1,num_shots);
    PNG_column = zeros(1,num_shots);

    cur_idx = 1;
    for i = 1:numfiles
        clc; display(['Concatenating Information from image ' num2str(i) ' of ' num2str(numfiles) ' (for day ' DAY{:} ').']);
        
        cur_num_shots = length(all_data(i).time);
        
        time(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).time;
        lat(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).lat;
        lon(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).lon;
        co_gain(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).co_gain;
        x_gain(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).x_gain;
        tilt(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).tilt;
        temp(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).temp;
        icath_co(:,cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).icath_co;
        icath_x(:,cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).icath_x;
        date(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).date;
        PNG_file(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).PNG_file;
        PNG_column(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).PNG_column;
        
        cur_idx = cur_idx + cur_num_shots;
    end

    %% Save the data!

    save([save_dir filesep 'DATA_FOR_' DAY{:} '.mat'],'time','lat','lon','co_gain','x_gain','tilt','temp','icath_co','icath_x','date','PNG_file','PNG_column','-v7.3');
    toc
end
