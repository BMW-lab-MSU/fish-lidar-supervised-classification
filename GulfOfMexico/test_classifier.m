%% Select testing variables

% Pick the classifier
boxdir = 'C:\Users\bradl\Box Sync\AFRL_Data\Data\GulfOfMexico\GoM Processed Classifier/';
modeldir = [boxdir '/Classifiers_Trained_On_09-24_Data/'];
modelfile = 'trainedModel_FineTree.mat';

% Load the classifier
modelstruct = load([modeldir modelfile]);
modelcell = struct2cell(modelstruct);
model = modelcell{2};

% Pick the days to analyze
path1 = [boxdir 'CLASSIFICATION_DATA_09-25.mat'];
path2 = [boxdir 'CLASSIFICATION_DATA_09-26.mat'];
path3 = [boxdir 'CLASSIFICATION_DATA_09-29.mat'];
path4 = [boxdir 'CLASSIFICATION_DATA_09-30.mat'];
path5 = [boxdir 'CLASSIFICATION_DATA_10-01.mat'];
path6 = [boxdir 'CLASSIFICATION_DATA_10-02.mat'];
path7 = [boxdir 'CLASSIFICATION_DATA_10-03.mat'];
path8 = [boxdir 'CLASSIFICATION_DATA_10-04.mat'];
path9 = [boxdir 'CLASSIFICATION_DATA_10-05.mat'];
path10 = [boxdir 'CLASSIFICATION_DATA_10-07.mat'];

% Put it all together!
datapath_list = {path1, path2, path3, path4, path5, path6, path7, path8, path9, path10};

%% Define variables
num_days = length(datapath_list);
conf_all = zeros(2,2,num_days);
accuracy = zeros(1,num_days);
precision = zeros(1,num_days);
recall = zeros(1,num_days);

%% Run the classifier on each day!
for idx = 1:num_days
    datapath = datapath_list(idx);
    datapath = string(datapath);
    datapath_char = convertStringsToChars(datapath);
    disp(['Running classifier on ...' datapath_char(end-29:end)]);
    [conf_all(:,:,idx),~] = predict_labels(datapath, model);
    [accuracy(idx), precision(idx), recall(idx)] = analyze_confusion(conf_all(:,:,idx));
end

%% Display & Save Results
conf_all
acc_prec_rec = [accuracy; precision; recall]
save([modeldir 'results_' modelfile],'conf_all','accuracy','precision','recall');