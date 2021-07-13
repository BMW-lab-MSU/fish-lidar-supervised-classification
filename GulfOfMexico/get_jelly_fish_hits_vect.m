function [hits_matrix] = get_jelly_fish_hits_vect(jelly_files_to_find, jelly_shot_values, PNG_file, jelly_hits_row_number, hits_matrix)
%GET_JELLY_FISH_HITS_VECT Returns a give hits vector with the jelly_hits_row_number row
%                              marked 1 on single hits.
%   layer_files_to_find:      matrix of shot values (col:1,2) and full file paths
%                              (col:3) given by the csv. [~,1:3]
%   layer_shots_values:       matrix of the starting (idx1=1) and ending (idx2=2) column location for a given image
%                              where the hit occured.
%   layer_hits_row_number:    row number in hits_matrix.
%   PNG_file:                  PNG pulled from .mat data
%   hits_matrix:                 [4 x ~] with the school_hits_row_number row labeled.

% SPDX-License-Identifier: BSD-3-Clause

shot_index_1 = 1;
shot_index_2 = 2;
file_name_extension_index = 5;
message_content = 'Jelly hits labeled at ~~~ ';
jelly_hit_value = 1;

for idx = 1:height(jelly_files_to_find)
    file = jelly_files_to_find(idx, 1).file;
    file_pieces = strsplit(file{:}, '\');
    file_to_find = file_pieces(end);
    
    shot1 = jelly_shot_values(idx, shot_index_1);
    shot2 = jelly_shot_values(idx, shot_index_2);
    [is_inPNG, idy] = ismember(file_to_find, PNG_file);
    if is_inPNG ~= 0
        hit_column_start = idy + table2array(shot1);
        hit_column_end = idy + table2array(shot2);
        hits_matrix(jelly_hits_row_number, hit_column_start:hit_column_end) = jelly_hit_value;
        %fprintf(message_content);
        %disp("Start:" + hit_column_start);
        %disp("End:" + hit_column_end)
    end
end


end

