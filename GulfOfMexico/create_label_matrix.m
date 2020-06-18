%% Author: Jackson Belford
%
% create_label_matrix creates a 4x155000 (approx.) long matrix

%% Init

data_dir = 'resources/data';
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

% Full paths
data_matrix_path = ([data_dir filesep data_file]);
jellies_matrix_path =  ([jellies_label_dir filesep jellies_label_file_name]);
schools_matrix_path = ([schools_label_dir filesep schools_label_file_name]);
layers_matrix_path = ([layers_label_dir filesep layers_label_file_name]);
singles_matrix_path = ([singles_label_dir filesep singles_label_file_name]);

%% Load one data .mat file

if isfolder(data_dir)
    mat_data = load(data_matrix_path);
else
    [data_file, data_path] = uigetfile('*.mat', 'Load a data .mat file');
    mat_data = load([data_path filesep data_file]);
end

%% Load data from labels .csv files (file_to_find)

if isfolder(label_dir)
    disp("Schools ----------------------")
    opts = detectImportOptions(schools_matrix_path);
    opts.SelectedVariableNames={'shot1','shot2','file'};
    schools_matrix_label_data = readtable(schools_matrix_path, opts);
    disp("Layers ----------------------")
    %opts = detectImportOptions(layers_matrix_path)                        % Error in csv file.
    %opts.SelectedVariableNames={'shot1','shot2','file'};
    %layers_matrix_label_data = readtable(layers_matrix_path, opts);
    disp("Jellies ----------------------")
    %opts = detectImportOptions(jellies_matrix_path)
    %opts.SelectedVariableNames={'shot1','shot2','file'};
    %jellies_matrix_label_data = readtable(jellies_matrix_path, opts);
    disp("Singles ----------------------")
    opts = detectImportOptions(singles_matrix_path)
    opts.SelectedVariableNames={'shot','file'};
    singles_matrix_label_data = readtable(singles_matrix_path, opts);
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

%% Load file_to_find and png_file for ismember function.

PNG_file = array2table(mat_data.PNG_file);
singles_files_to_find = singles_matrix_label_data(:,2);
singles_shot_values = singles_matrix_label_data(:,1);

for idx = 1:height(singles_files_to_find)
    file_to_find = singles_files_to_find(idx, 1)
    rows = singles_shot_values(idx, 1)
    [q, idy] = ismember(file_to_find, PNG_file, 'rows');
    if q ~= 0
        print(idy)
    end
end
