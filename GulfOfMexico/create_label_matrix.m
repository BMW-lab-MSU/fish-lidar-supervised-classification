%% Author: Jackson Belford
%
% create_label_matrix creates a 4x747000 (approx.) long matrix for every
%           .mat object in /resources/data/*.mat .
% WARNING: This takes forever to run, set it and do something else.

%% Init

data_dir = 'resources/data/';
label_dir = 'resources/GoM results/';

jellies_label_dir = append(label_dir,'jellies/');
layers_label_dir = append(label_dir,'layers/');
schools_label_dir = append(label_dir,'Schools/');
singles_label_dir = append(label_dir,'Single/');

% Data sets to create labels for
data_file_name1 = 'DATA_FOR_09-24.mat';
data_file_name2 = 'DATA_FOR_09-25.mat';
data_file_name3 = 'DATA_FOR_09-26.mat';
data_file_name4 = 'DATA_FOR_09-29.mat';
data_file_name5 = 'DATA_FOR_09-30.mat';
data_file_name6 = 'DATA_FOR_10-01.mat';
data_file_name7 = 'DATA_FOR_10-02.mat';
data_file_name8 = 'DATA_FOR_10-03.mat';
data_file_name9 = 'DATA_FOR_10-04.mat';
data_file_name10 = 'DATA_FOR_10-05.mat';
%data_file_name11 = 'DATA_FOR_10-06.mat';                                   % Commented out b/c lack of label files in Schools and Layers
data_file_name12 = 'DATA_FOR_10-07.mat';

% For Graphical Analysis
single_index = 1;
school_index = 2;
jelly_index = 3;
layer_index = 4;

%% Create labels for Day 1

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 1 ~~~~~~~~~~~~~~~');
day1_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name1);
disp('~~~~~~~~~~~~~~~ Day 1 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 2

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 2 ~~~~~~~~~~~~~~~');
day2_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name2);
disp('~~~~~~~~~~~~~~~ Day 2 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 3

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 3 ~~~~~~~~~~~~~~~');
day3_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name3);
disp('~~~~~~~~~~~~~~~ Day 3 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 4

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 4 ~~~~~~~~~~~~~~~');
day4_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name4);
disp('~~~~~~~~~~~~~~~ Day 4 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 5

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 5 ~~~~~~~~~~~~~~~');
day5_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name5);
disp('~~~~~~~~~~~~~~~ Day 5 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 6

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 6 ~~~~~~~~~~~~~~~');
day6_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name6);
disp('~~~~~~~~~~~~~~~ Day 6 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 7

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 7 ~~~~~~~~~~~~~~~');
day7_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name7);
disp('~~~~~~~~~~~~~~~ Day 7 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 8

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 8 ~~~~~~~~~~~~~~~');
day8_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name8);
disp('~~~~~~~~~~~~~~~ Day 8 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 9

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 9 ~~~~~~~~~~~~~~~');
day9_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name9);
disp('~~~~~~~~~~~~~~~ Day 9 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 10

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 10 ~~~~~~~~~~~~~~~');
day10_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name10);
disp('~~~~~~~~~~~~~~~ Day 10 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 11

%disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 11 ~~~~~~~~~~~~~~~');
%day11_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name11);
%disp('~~~~~~~~~~~~~~~ Day 11 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 12

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 12 ~~~~~~~~~~~~~~~');
day12_labels_matrix = get_label_matrix(data_dir, label_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name12);
disp('~~~~~~~~~~~~~~~ Day 12 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Graphical Analysis

    % Visual of School Labels
    data_to_display = day1_labels_matrix(school_index, 12000:13000);
    figure();
    subplot(311);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 12000:13000 School Hits (5)');
    
    data_to_display = day1_labels_matrix(school_index, 172000:173000);
    subplot(312);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 172000:173000 School Hits (7)');
    
    data_to_display = day1_labels_matrix(school_index, 731000:732000);
    subplot(313);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 731000:732000 School Hits (2)');
    
    % Visual of Single Labels
    data_to_display = day1_labels_matrix(single_index, 12000:13000);
    figure();
    subplot(311);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 12000:13000 Single Hits (1)');
    
    data_to_display = day1_labels_matrix(single_index, 172000:173000);
    subplot(312);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 172000:173000 Single Hits (6)');
    
    data_to_display = day1_labels_matrix(single_index, 731000:732000);
    subplot(313);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 731000:732000 Single Hits (0)');
    
    % Visual of Jelly Labels
    data_to_display = day1_labels_matrix(jelly_index, 12000:13000);
    figure();
    subplot(311);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 12000:13000 Jelly Hits (0)');
    
    data_to_display = day1_labels_matrix(jelly_index, 172000:173000);
    subplot(312);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 172000:173000 Jelly Hits (0)');
    
    data_to_display = day1_labels_matrix(jelly_index, 731000:732000);
    subplot(313);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 731000:732000 Jelly Hits (0)');
    
    % Visual of Layer Labels
    data_to_display = day1_labels_matrix(layer_index, 10000:100000);
    figure();
    subplot(311);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 12000:13000 Layer Hits (15)');
    
    data_to_display = day1_labels_matrix(layer_index, 570000:590000);
    subplot(312);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 570000:590000 Layer Hits (8)');
    
    data_to_display = day1_labels_matrix(layer_index, 730000:740000);
    subplot(313);
    image(data_to_display,'CDataMapping', 'scaled'); colorbar; title('Example 730000:740000 Layer Hits (8)');
    
%% Congradulations!

disp('Congrats! You ran this entire program, which I am going to assume was not fast!');

%% Running Tests --- Run Section

[row, col] = size(day1_labels_matrix);
overlaps = zeros(1, col);
for idx = 1:col
    overlaps(1, idx) = sum(day1_labels_matrix(:, idx));
end
figure();
bar(overlaps); title('Values of 1 are commonly layers of plankton.');

%% Graphics Testing

%data = load('resources/data/DATA_FOR_09-24.mat');

xpol_data = icath_x(:, 730000:740000);
copol_data = icath_co(:, 730000:740000);

for idx = 1:length(x_gain)
    
end

copol_data = copol_data .* co_gain;

dpol_dataxc = xpol_data ./ copol_data;

dpol_datacx = copol_data ./ xpol_data;

label_data = day1_labels_matrix(:, 730000:740000);

figure()
subplot(311);
image(xpol_data, 'CDataMapping', 'scaled'); colorbar; title('XPol Data Day 1: 10,000 --- 100,000');
subplot(312);
image(label_data, 'CDataMapping', 'scaled'); colorbar; title('Label Data Day 1: 10,000 --- 100,000');

figure()
subplot(311);
image(copol_data, 'CDataMapping', 'scaled'); colorbar; title('Co Data Day 1: 10,000 --- 100,000');
subplot(312);
image(label_data, 'CDataMapping', 'scaled'); colorbar; title('Label Data Day 1: 10,000 --- 100,000');


figure()
subplot(311);
image(dpol_dataxc, 'CDataMapping', 'scaled'); colorbar; title('DPol X/C Data Day 1: 10,000 --- 100,000');
subplot(312);
image(label_data, 'CDataMapping', 'scaled'); colorbar; title('Label Data Day 1: 10,000 --- 100,000');


figure()
subplot(311);
image(dpol_datacx, 'CDataMapping', 'scaled'); colorbar; title('DPol C/X Data Day 1: 10,000 --- 100,000');
subplot(312);
image(label_data, 'CDataMapping', 'scaled'); colorbar; title('Label Data Day 1: 10,000 --- 100,000');