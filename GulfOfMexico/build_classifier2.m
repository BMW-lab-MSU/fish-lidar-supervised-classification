%% Create Classifier

data2 = load('CLASSIFICATION_DATA_09-24.mat');

%%

xpol_data2 = data2.classification_data;
label2 = xpol_data2(251,:);
xpol_data2(251:254,:) = [];


%%
xpol_data2(isnan(xpol_data2))=0;
classifier_data2 = vertcat(xpol_data2, label2);

%%
classifier_data2_t = classifier_data2';

%%
save trainedModelSingle trainedModel2