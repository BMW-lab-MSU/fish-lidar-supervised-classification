%% Author: Jackson Belford
%
% create_label_matrix creates a 4x747000 (approx.) long matrix
% WARNING: This takes forever to run, set it and do something else.

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

% Full paths
data_matrix_path = ([data_dir filesep data_file_name]);
jellies_matrix_path =  ([jellies_label_dir filesep jellies_label_file_name]);
schools_matrix_path = ([schools_label_dir filesep schools_label_file_name]);
layers_matrix_path = ([layers_label_dir filesep layers_label_file_name]);
singles_matrix_path = ([singles_label_dir filesep singles_label_file_name]);

disp("Initial data loaded and program is beginning to run.");

%% Load one data .mat file

if isfolder(data_dir)
    disp(data_file_name + " ---------------------- Loading")
    mat_data = load(data_matrix_path);
    disp(data_file_name + " ---------------------- Loaded")
else
    [data_file, data_path] = uigetfile('*.mat', 'Load a data .mat file');
    mat_data = load([data_path filesep data_file]);
end

%% Load data from labels .csv files (file_to_find)

if isfolder(label_dir)
    disp("Schools ---------------------- Loading")
    opts = detectImportOptions(schools_matrix_path);
    opts.SelectedVariableNames={'shot1','shot2','file'};
    schools_matrix_label_data = readtable(schools_matrix_path, opts);
    disp("Schools ---------------------- Loaded")
    %disp("Layers ---------------------- Loading")                                  % Layers dont work yet
    %opts = detectImportOptions(layers_matrix_path);                        % Error in csv file.
    %opts.SelectedVariableNames={'shot1','shot2','file'};
    %layers_matrix_label_data = readtable(layers_matrix_path, opts);
    %disp("Layers ---------------------- Loaded")
    %disp("Jellies ---------------------- Loading")                                 % Jellies dont work yet
    %opts = detectImportOptions(jellies_matrix_path);
    %opts.SelectedVariableNames={'shot1','shot2','file'};
    %jellies_matrix_label_data = readtable(jellies_matrix_path, opts);
    %disp("Jellies ---------------------- Loaded")
    disp("Singles ---------------------- Loading")
    opts = detectImportOptions(singles_matrix_path);
    opts.SelectedVariableNames={'shot','file'};
    singles_matrix_label_data = readtable(singles_matrix_path, opts);
    disp("Singles ---------------------- Loaded")
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

PNG_file = mat_data.PNG_file;                                              

singles_files_to_find = singles_matrix_label_data(:,2);
singles_shot_values = singles_matrix_label_data(:,1);

schools_files_to_find = schools_matrix_label_data(:, 3);
schools_shot_values = schools_matrix_label_data(:,1:2);

hits_matrix = zeros(4, length(PNG_file));
single_index = 1;
school_index = 2;

%% Parsing for single fish hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ SINGLE FISH HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
hits_matrix = get_single_fish_hits_vect(singles_files_to_find, singles_shot_values, PNG_file, single_index, hits_matrix);

%% Parsing for school fish hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ SCHOOL FISH HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
hits_matrix = get_school_fish_hits_vect(schools_files_to_find, schools_shot_values, PNG_file, school_index, hits_matrix);

%% testing number of hits and comparing to label lengths.

single_hits = 0;
for idx = 1:length(hits_matrix(single_index,:))
    if hits_matrix(single_index, idx) == 1
        single_hits = single_hits + 1;
    end
end
disp("Total Single Hits: " + single_hits);

school_hits = 0;
for idx = 1:length(hits_matrix(school_index,:))
    if hits_matrix(school_index, idx) == 1
        school_hits = school_hits + 1;
    end
end
disp("Total School Hits: " + school_hits);

%% Graphical Analysis

