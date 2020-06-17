%% Author: Jackson Belford
%
% create_label_matrix creates a 4x155000 (approx.) long matrix

%% Init

data_dir = 'resources/data/';
label_dir = 'resources/GoM results/';

jellies_label_dir = append(label_dir,'jellies/');
layers_label_dir = append(label_dir,'layers/');
schools_label_dir = append(label_dir,'Schools/');
singles_label_dir = append(label_dir,'Single/');

% For testing purposes
data_file_name = 'DATA_FOR_09-24.mat';
jellies_label_file_name = 'jellies 09-24.csv';
layers_label_file_name = 'layers 09-24.csv';
schools_label_file_name = 'final schools 09-24.csv';
singles_label_file_name = 'final single 09-24.csv';

%% Load one data .mat file

if isfolder(data_dir)
    load([data_dir, data_file_name]);
else
    [data_file, data_path] = uigetfile('*.mat', 'Load a data .mat file');
    load([data_path filesep data_file]);
end

%% Load labels for one .mat file

if isfolder(label_dir)
    readtable([jellies_label_dir, jellies_label_file_name]);
    readtable([layers_label_dir, layers_label_file_name]);
    readtable([schools_label_dir, schools_label_file_name]);
    readtable([singles_label_dir, singles_label_file_name]);
else
    [jellies_file, jellies_path] = uigetfile('*.csv', 'Load a jellies .csv file');
    load([jellies_path filesep jellies_file]);
    [layers_file, layers_path] = uigetfile('*.csv', 'Load a layers .csv file');
    load([layers_path filesep layers_file]);
    [singles_file, singles_path] = uigetfile('*.csv', 'Load a singles .csv file');
    load([singles_path filesep singles_file]);
    [schools_file, schools_path] = uigetfile('*.csv', 'Load a schools .csv file');
    load([schools_path filesep schools_file]);
end

%% Getting first hit from csv file

schools_matrix_path = ([schools_label_dir filesep schools_label_file_name]);
opts = detectImportOptions(schools_matrix_path);
opts.SelectedVariableNames={'shot1','shot2','file'};
schools_matrix_label_data = readtable(schools_matrix_path, opts)