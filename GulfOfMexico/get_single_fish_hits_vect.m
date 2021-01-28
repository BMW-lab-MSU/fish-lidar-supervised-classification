function [hits_matrix] = get_single_fish_hits_vect(single_files_to_find, single_shot_values, PNG_file, single_hits_row_number, hits_matrix)
%GET_SINGLE_FISHHITS_VECT      Returns a give hits vector with the single_hits_row_number row
%                              marked 1 on single hits.
%   single_files_to_find:      matrix of full file paths given by the csv.
%   single_shot_values:        matrix of the column location for a given image
%                              where the hit occured.
%   single_hits_row_number:    row number in hits_matrix.
%   PNG_file:                  PNG pulled from .mat data
%   hits_matrix:               [4 x ~] with the single_hits_row_number row labeled.

file_name_extension_index = 4;
message_content = 'Single hit labeled at ~~~ ';
single_hit_value = 1;

for idx = 1:height(single_files_to_find)
    file = single_files_to_find(idx, 1).file;
    file_pieces = strsplit(file{:}, '\');
    file_to_find = file_pieces(end);

    shot = single_shot_values(idx, 1);
    [q, idy] = ismember(file_to_find, PNG_file);
    if q ~= 0
        hit_column = idy + table2array(shot);
        hits_matrix(single_hits_row_number, hit_column)=single_hit_value;
        %fprintf(message_content);
        %disp(hit_column);
    end
end

end

