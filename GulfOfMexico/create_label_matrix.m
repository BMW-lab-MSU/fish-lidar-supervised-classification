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
data_file_name11 = 'DATA_FOR_10-06.mat';
data_file_name12 = 'DATA_FOR_10-07.mat';

%% Create labels for Day 1

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 1 ~~~~~~~~~~~~~~~');
day1_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name1);
disp('~~~~~~~~~~~~~~~ Day 1 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 2

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 2 ~~~~~~~~~~~~~~~');
day2_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name2);
disp('~~~~~~~~~~~~~~~ Day 2 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 3

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 3 ~~~~~~~~~~~~~~~');
day3_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name3);
disp('~~~~~~~~~~~~~~~ Day 3 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 4

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 4 ~~~~~~~~~~~~~~~');
day4_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name4);
disp('~~~~~~~~~~~~~~~ Day 4 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 5

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 5 ~~~~~~~~~~~~~~~');
day5_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name5);
disp('~~~~~~~~~~~~~~~ Day 5 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 6

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 6 ~~~~~~~~~~~~~~~');
day6_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name6);
disp('~~~~~~~~~~~~~~~ Day 6 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 7

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 7 ~~~~~~~~~~~~~~~');
day7_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name7);
disp('~~~~~~~~~~~~~~~ Day 7 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 8

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 8 ~~~~~~~~~~~~~~~');
day8_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name8);
disp('~~~~~~~~~~~~~~~ Day 8 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 9

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 9 ~~~~~~~~~~~~~~~');
day9_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name9);
disp('~~~~~~~~~~~~~~~ Day 9 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 10

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 10 ~~~~~~~~~~~~~~~');
day10_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name10);
disp('~~~~~~~~~~~~~~~ Day 10 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 11

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 11 ~~~~~~~~~~~~~~~');
day11_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name11);
disp('~~~~~~~~~~~~~~~ Day 11 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Create labels for Day 12

disp('~~~~~~~~~~~~~~~ Creating label matrix for Day 12 ~~~~~~~~~~~~~~~');
day12_labels_matrix = get_label_matrix(data_dir, jellies_label_dir, layers_label_dir, schools_label_dir, singles_label_dir, data_file_name12);
disp('~~~~~~~~~~~~~~~ Day 12 Label Matrix Created ~~~~~~~~~~~~~~~');

%% Congradulations!

disp('Congrats! You ran this entire program, which I am going to assume was not fast!');