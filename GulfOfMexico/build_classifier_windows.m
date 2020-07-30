%% Create Classifier

data = load('CLASSIFICATION_DATA_09-24.mat');

%%

xpol_data = data.classification_data;
labels = xpol_data(251:254,:);
xpol_data(251:254,:)=[];
hex_val = zeros(1,length(labels));

for idx = 1:length(labels)
    vect = labels(:, idx)';
    hex_val(idx) = str2double(binaryVectorToHex(vect));
end

%%
xpol_data(isnan(xpol_data))=0;
classifier_data = vertcat(xpol_data, hex_val);

%%
classifier_data_t = classifier_data';

%%
save trees_GoM_model.mat trainedModel
