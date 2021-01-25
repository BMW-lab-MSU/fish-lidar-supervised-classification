%% script_extract_data_from_day

close all; clear all; clc;
tic;

DAY = '10-07';

% Find all .png files in the day's folder
filelist = ls([DAY '/*.png']);

% Count the number of files
numfiles = size(filelist,1);

%% Analyze all files
for i = 1:numfiles
    clc; display(['Extracting information from image ' num2str(i) ' of ' num2str(numfiles) ' (for day ' DAY ').']);
    cur_file = [DAY '/' filelist(i,:)];
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
date = char(zeros(5,num_shots));
PNG_file = char(zeros(17,num_shots));
PNG_column = zeros(1,num_shots);

cur_idx = 1;
for i = 1:numfiles
    clc; display(['Concatenating Information from image ' num2str(i) ' of ' num2str(numfiles) ' (for day ' DAY ').']);
    
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
    date(:,cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).date;
    PNG_file(:,cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).PNG_file;
    PNG_column(cur_idx:cur_idx + cur_num_shots - 1) = all_data(i).PNG_column;
    
    cur_idx = cur_idx + cur_num_shots;
end

%% Save the data!

save([DAY '/DATA_FOR_' DAY '.mat'],'time','lat','lon','co_gain','x_gain','tilt','temp','icath_co','icath_x','date','PNG_file','PNG_column','-v7.3');
toc

%% Save the Data -- H5

% H5 files are too big. Just use .mat instead.

% h5create(['DATA_FOR_' DAY '.h5'],'/time',size(time));
% h5create(['DATA_FOR_' DAY '.h5'],'/lat',size(lat));
% h5create(['DATA_FOR_' DAY '.h5'],'/lon',size(lon));
% h5create(['DATA_FOR_' DAY '.h5'],'/co_gain',size(co_gain));
% h5create(['DATA_FOR_' DAY '.h5'],'/x_gain',size(x_gain));
% h5create(['DATA_FOR_' DAY '.h5'],'/tilt',size(tilt));
% h5create(['DATA_FOR_' DAY '.h5'],'/temp',size(temp));
% h5create(['DATA_FOR_' DAY '.h5'],'/icath_co',size(icath_co));
% h5create(['DATA_FOR_' DAY '.h5'],'/icath_x',size(icath_x));
% 
% h5write(['DATA_FOR_' DAY '.h5'],'/time',time);
% h5write(['DATA_FOR_' DAY '.h5'],'/lat',lat);
% h5write(['DATA_FOR_' DAY '.h5'],'/lon',lon);
% h5write(['DATA_FOR_' DAY '.h5'],'/co_gain',co_gain);
% h5write(['DATA_FOR_' DAY '.h5'],'/x_gain',x_gain);
% h5write(['DATA_FOR_' DAY '.h5'],'/tilt',tilt);
% h5write(['DATA_FOR_' DAY '.h5'],'/temp',temp);
% h5write(['DATA_FOR_' DAY '.h5'],'/icath_co',icath_co);
% h5write(['DATA_FOR_' DAY '.h5'],'/icath_x',icath_x);