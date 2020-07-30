function [output] = get_results(data_path, model, model_title)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%%
test_data = load(data_path);
disp('-- Data Loaded --');
test_xpol_data = test_data.classification_data;
test_labels = test_xpol_data(251,:);
test_xpol_data(251:254,:)=[];
test_single_labels = test_labels(1,:);
test_xpol_data(isnan(test_xpol_data))=0;

%%
yfit = model.predictFcn(test_xpol_data');

%%
num_correct = 0;
for idx = 1:length(test_single_labels)
    if test_single_labels(1,idx) == yfit(idx, 1) && yfit(idx, 1) == 1
        num_correct = num_correct + 1;
    end
end
%%
conf_mat = confusion(yfit', test_single_labels);

key_set = ["Day", "Total Data Points", "Confusion Matrix"];
value_set = [data_path, length(test_single_labels), num_correct, conf_mat];
map = containers.Map(key_set, value_set);

path_parts = split(data_path, '_');

file_name = strcat('results/',model_title,'_',path_parts(3));
save(file_name, 'map');
disp('Data Recorded');

output = 1;
end

