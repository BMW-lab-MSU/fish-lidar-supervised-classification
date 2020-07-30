%% Create Classifier

data = load('CLASSIFICATION_DATA_09-24.mat');

%%

xpol_data = data.classification_data;
labels = xpol_data(251,:);
xpol_data(251:254,:)=[];

%%
xpol_data(isnan(xpol_data))=0;
classifier_data = vertcat(xpol_data, labels);

%%
classifier_data_t = classifier_data';