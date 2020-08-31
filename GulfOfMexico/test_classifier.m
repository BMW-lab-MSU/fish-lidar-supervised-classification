
path1 = 'CLASSIFICATION_DATA_09-25.mat';
path2 = 'CLASSIFICATION_DATA_09-26.mat';
path3 = 'CLASSIFICATION_DATA_09-29.mat';
path4 = 'CLASSIFICATION_DATA_09-30.mat';
path5 = 'CLASSIFICATION_DATA_10-01.mat';
path6 = 'CLASSIFICATION_DATA_10-02.mat';
path7 = 'CLASSIFICATION_DATA_10-03.mat';
path8 = 'CLASSIFICATION_DATA_10-04.mat';
path9 = 'CLASSIFICATION_DATA_10-05.mat';
path10 = 'CLASSIFICATION_DATA_10-07.mat';

model_mat = load('importantTrainedModel.mat');
model = model_mat.trainedModel;

path_dict = {path1, path2, path3, path4, path5, path6, path7, path8, path9, path10};

%%
for idx = 1:length(path_dict)
    data_path = path_dict(idx);
    data_path = string(data_path);
    result = get_results(data_path, model, 'Fine_Trees_Basic');
    if result == 1
        disp('Successfully tested day ' + string(path_dict(idx)) + ' on ' + 'Fine_Trees_Basic');
    end
end
%%
%for idy = 1:length(path_dict)
%    data_path = path_dict(idy);
%    data_path = string(data_path);
%    result = get_results(data_path, model2, 'Fine_Trees_SevFold');
%    if result == 1
%        disp('Successfully tested day ' + string(path_dict(idx)) + ' on ' + 'Fine_Trees_SevFold');
%    end
%end