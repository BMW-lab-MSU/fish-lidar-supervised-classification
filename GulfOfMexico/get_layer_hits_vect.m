function [hits_matrix] = get_layer_hits_vect(layer_files_to_find, layer_shots_values, PNG_file, layer_hits_row_number, hits_matrix)
%GET_LAYER_HITS_VECT Returns a give hits vector with the layer_hits_row_number row
%                              marked 1 on single hits.
%   layer_files_to_find:      matrix of shot values (col:1,2) and full file paths
%                              (col:3) given by the csv. [~,1:3]
%   layer_shots_values:       matrix of the starting (idx1=1) and ending (idx2=2) column location for a given image
%                              where the hit occured.
%   layer_hits_row_number:    row number in hits_matrix.
%   PNG_file:                  PNG pulled from .mat data
%   hits_matrix:                 [4 x ~] with the school_hits_row_number row labeled.

shot_index_1 = 1;
shot_index_2 = 2;
file_name_extension_index = 5;
message_content = 'Layer hits labeled at ~~~ ';
layer_hit_value = 1;

for idx = 1:height(layer_files_to_find)
    file = string(layer_files_to_find(idx, 1).file);
    [filepath,name,ext] = fileparts(file);                                 % Have to check if [name, ext] will work.
    file_pieces = strsplit(name, '\');
    file_to_find = file_pieces(file_name_extension_index) + ext;
    
    shot1 = layer_shots_values(idx, shot_index_1);
    shot2 = layer_shots_values(idx, shot_index_2);
    [is_inPNG, idy] = ismember(file_to_find, PNG_file', 'rows');
    if is_inPNG ~= 0
        hit_column_start = idy + table2array(shot1);
        hit_column_end = idy + table2array(shot2);
        hits_matrix(layer_hits_row_number, hit_column_start:hit_column_end) = layer_hit_value;
        fprintf(message_content);
        disp("Start:" + hit_column_start);
        disp("End:" + hit_column_end)
    end
end

