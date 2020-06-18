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

%% Load one data .mat file and loads PNG file

if isfolder(data_dir)
    disp(data_file_name + " ---------------------- Loading")
    mat_data = load(data_matrix_path);
    disp(data_file_name + " ---------------------- Loaded")
else
    [data_file, data_path] = uigetfile('*.mat', 'Load a data .mat file');
    mat_data = load([data_path filesep data_file]);
end

PNG_file = mat_data.PNG_file;

%% Load data from labels .csv files (file_to_find)

if isfolder(label_dir)
    disp("Schools ---------------------- Loading")
    opts = detectImportOptions(schools_matrix_path);
    opts.SelectedVariableNames={'shot1','shot2','file'};
    schools_matrix_label_data = readtable(schools_matrix_path, opts);
    disp("Schools ---------------------- Loaded")
    disp("Layers ---------------------- Loading")                         
    opts = detectImportOptions(layers_matrix_path);                       
    opts.SelectedVariableNames={'shot1','shot2','file'};
    layers_matrix_label_data = readtable(layers_matrix_path, opts);
    disp("Layers ---------------------- Loaded")
    disp("Jellies ---------------------- Loading")                                 % Handled for 0 jellies.
    opts = detectImportOptions(jellies_matrix_path);
    try
        opts.SelectedVariableNames={'shot1','shot2','file'};
        jellies_matrix_label_data = readtable(jellies_matrix_path, opts);
    catch
        jellies_matrix_label_data = zeros(1,length(PNG_file));
    end
        
    disp("Jellies ---------------------- Loaded")
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

%% Load file_to_find for ismember function.                                              

singles_files_to_find = singles_matrix_label_data(:,2);
singles_shot_values = singles_matrix_label_data(:,1);

schools_files_to_find = schools_matrix_label_data(:, 3);
schools_shot_values = schools_matrix_label_data(:,1:2);

jelly_files_to_find = jellies_matrix_label_data(:, 3);
jelly_shot_values = jellies_matrix_label_data(:,1:2);

layer_files_to_find = layers_matrix_label_data(:, 3);
layer_shot_values = layers_matrix_label_data(:, 1:2);

hits_matrix = zeros(4, length(PNG_file));
single_index = 1;
school_index = 2;
jelly_index = 3;
layer_index = 4;

%% Parsing for single fish hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ SINGLE FISH HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
hits_matrix = get_single_fish_hits_vect(singles_files_to_find, singles_shot_values, PNG_file, single_index, hits_matrix);

%% Parsing for school fish hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ SCHOOL FISH HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
hits_matrix = get_school_fish_hits_vect(schools_files_to_find, schools_shot_values, PNG_file, school_index, hits_matrix);

%% Parsing for jelly fish hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ JELLY FISH HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
[row, col] = size(jellies_matrix_label_data);
if row > 1
    hits_matrix = get_jelly_fish_hits_vect(jelly_files_to_find, jelly_shot_values, PNG_file, jelly_index, hits_matrix);
else
    disp('No jellyfish labels found!');
    hits_matrix(3,:) = 0;
end

%% Parsing for layer hits

disp("~~~~~~~~~~~~~~~~~~~~~~~~~~ LAYER HITS ~~~~~~~~~~~~~~~~~~~~~~~~~~");
hits_matrix = get_layer_hits_vect(layer_files_to_find, layer_shot_values, PNG_file, layer_index, hits_matrix);

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

jelly_hits = 0;
for idx = 1:length(hits_matrix(jelly_index,:))
    if hits_matrix(jelly_index, idx) == 1
        jelly_hits = jelly_hits + 1;
    end
end
disp("Total Jelly Hits: " + jelly_hits);

layer_hits = 0;
for idx = 1:length(hits_matrix(layer_index,:))
    if hits_matrix(layer_index, idx) == 1
        layer_hits = layer_hits + 1;
    end
end
disp("Total Layer Hits: " + layer_hits);

%% Graphical Analysis

    % Visual of School Labels
    data_to_display = hits_matrix(school_index, 12000:13000);
    figure();
    subplot(311);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 12000:13000 School Hits (5)');
    
    data_to_display = hits_matrix(school_index, 172000:173000);
    subplot(312);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 172000:173000 School Hits (7)');
    
    data_to_display = hits_matrix(school_index, 731000:732000);
    subplot(313);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 731000:732000 School Hits (2)');
    
    % Visual of Single Labels
    data_to_display = hits_matrix(single_index, 12000:13000);
    figure();
    subplot(311);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 12000:13000 Single Hits (1)');
    
    data_to_display = hits_matrix(single_index, 172000:173000);
    subplot(312);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 172000:173000 Single Hits (6)');
    
    data_to_display = hits_matrix(single_index, 731000:732000);
    subplot(313);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 731000:732000 Single Hits (0)');
    
    % Visual of Jelly Labels
    data_to_display = hits_matrix(jelly_index, 12000:13000);
    figure();
    subplot(311);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 12000:13000 Jelly Hits (0)');
    
    data_to_display = hits_matrix(jelly_index, 172000:173000);
    subplot(312);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 172000:173000 Jelly Hits (0)');
    
    data_to_display = hits_matrix(jelly_index, 731000:732000);
    subplot(313);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 731000:732000 Jelly Hits (0)');
    
    % Visual of Layer Labels
    data_to_display = hits_matrix(layer_index, 10000:100000);
    figure();
    subplot(311);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 12000:13000 Layer Hits (15)');
    
    data_to_display = hits_matrix(layer_index, 570000:590000);
    subplot(312);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 570000:590000 Layer Hits (8)');
    
    data_to_display = hits_matrix(layer_index, 730000:740000);
    subplot(313);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 730000:740000 Layer Hits (8)');