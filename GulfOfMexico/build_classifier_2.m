%% Create Classifier
<<<<<<< HEAD
data = load('CLASSIFICATION_DATA_09-24.mat');
=======

filepath = 'C:\Users\bradl\Box Sync\AFRL_Data\Data\GulfOfMexico\GoM Processed Classifier/';
data = load([filepath 'CLASSIFICATION_DATA_09-24.mat']);    % First Day = 09-24
>>>>>>> 8d4f94449da72ebd4714de44c29e81fbc022f8f9

%%

xpol_data = data.classification_data; % This may be a different end point
labels = xpol_data(251,:);
xpol_data(251:254,:)=[];

%%
xpol_data(isnan(xpol_data))=0;
classifier_data = vertcat(xpol_data, labels);

%%
classifier_data_t = classifier_data';

%% OPTIONAL
% Only use a subset of the data to speed up the training process.
% Make sure to keep all of the fish hits, but ignore 90% of the non fish
% hits during training.
idx_no_fish = find(classifier_data_t(:,251)==0);
rand_idx = randperm(length(idx_no_fish));
num_to_discard = round(0.9*length(idx_no_fish));
idx_to_discard = idx_no_fish(rand_idx(1:num_to_discard));
classifier_data_t(idx_to_discard,:) = [];