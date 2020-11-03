function [labels] = create_labels(data_dir, label_dir, data_file_name, PNG_file)

data_no_ext = strsplit(data_file_name, '.');
file_parts = strsplit(string(data_no_ext(1)), '_');
date = char(file_parts(3));

jellies_label_file_name = ['jellies ' date '.csv'];
layers_label_file_name = ['layers ' date '.csv'];
schools_label_file_name = ['final schools ' date '.csv'];
singles_label_file_name = ['final single ' date '.csv'];

% Full Paths
data_matrix_path = [data_dir filesep data_file_name];
jellies_matrix_path =  [label_dir filesep jellies_label_file_name];
schools_matrix_path = [label_dir filesep schools_label_file_name];
layers_matrix_path = [label_dir filesep layers_label_file_name];
singles_matrix_path = [label_dir filesep singles_label_file_name];
disp("Initial data loaded and program is beginning to run.");


%% Load data from labels .csv files (file_to_find)

disp("Schools ---------------------- Loading")
try
    opts = detectImportOptions(schools_matrix_path);
    opts.SelectedVariableNames={'shot1','shot2','file'};
    schools_matrix_label_data = readtable(schools_matrix_path, opts);
catch
    schools_matrix_label_data = zeros(1, length(PNG_file));
end
disp("Schools ---------------------- Loaded")
disp("Layers ---------------------- Loading")                         
try
    opts = detectImportOptions(layers_matrix_path);                       
    opts.SelectedVariableNames={'shot1','shot2','file'};
    layers_matrix_label_data = readtable(layers_matrix_path, opts);
catch
    layers_matrix_label_data = zeros(1, length(PNG_file));
end
disp("Layers ---------------------- Loaded")
disp("Jellies ---------------------- Loading")                                 % Handled for 0 jellies.
try
    opts = detectImportOptions(jellies_matrix_path);
    opts.SelectedVariableNames={'shot1','shot2','file'};
    jellies_matrix_label_data = readtable(jellies_matrix_path, opts);
catch
    jellies_matrix_label_data = zeros(1,length(PNG_file));
end
disp("Jellies ---------------------- Loaded")
disp("Singles ---------------------- Loading")
try
    opts = detectImportOptions(singles_matrix_path);
    opts.SelectedVariableNames={'shot','file'};
    singles_matrix_label_data = readtable(singles_matrix_path, opts);
catch
    singles_matrix_label_data = zeros(1, length(PNG_file));
end
disp("Singles ---------------------- Loaded")

%% Load file_to_find for ismember function.                                              

singles_files_to_find = singles_matrix_label_data(:,2);
singles_shot_values = singles_matrix_label_data(:,1);

schools_files_to_find = schools_matrix_label_data(:, 3);
schools_shot_values = schools_matrix_label_data(:,1:2);

jelly_files_to_find = jellies_matrix_label_data(:, 3);
jelly_shot_values = jellies_matrix_label_data(:,1:2);

layer_files_to_find = layers_matrix_label_data(:, 3);
layer_shot_values = layers_matrix_label_data(:, 1:2);

labels = zeros(4, length(PNG_file));
single_index = 1;
school_index = 2;
jelly_index = 3;
layer_index = 4;

%% Parsing for single fish hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ SINGLE FISH HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
labels = get_single_fish_hits_vect(singles_files_to_find, singles_shot_values, PNG_file, single_index, labels);

%% Parsing for school fish hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ SCHOOL FISH HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
labels = get_school_fish_hits_vect(schools_files_to_find, schools_shot_values, PNG_file, school_index, labels);

%% Parsing for jelly fish hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ JELLY FISH HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
[row, ~] = size(jellies_matrix_label_data);
if row > 1
    labels = get_jelly_fish_hits_vect(jelly_files_to_find, jelly_shot_values, PNG_file, jelly_index, labels);
else
    disp('No jellyfish labels found!');
    labels(3,:) = 0;
end

%% Parsing for layer hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ LAYER HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
labels = get_layer_hits_vect(layer_files_to_find, layer_shot_values, PNG_file, layer_index, labels);


end

