%% Create Classifier

data = load('C:\Users\bradl\Box Sync\AFRL_Data\Data\GulfOfMexico\GoM Processed Classifier\CLASSIFICATION_DATA_09-24.mat');

%%

xpol_data = data.classification_data;
labels = xpol_data(251:254,:);
xpol_data(251:254,:)=[];
dec_val = zeros(1,length(labels));

for idx = 1:length(labels)
    vect = labels(:, idx)';
    str_vect = num2str(vect);
    str_vect(isspace(str_vect)) = '';
    dec_val(1,idx) = bin2dec(str_vect);
end

%%
xpol_data(isnan(xpol_data))=0;
classifier_data = vertcat(xpol_data, dec_val);

%%
classifier_data_t = classifier_data';

%%

% save trainedModel1 trainedModel