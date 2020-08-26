function [conf,labels_pred] = predict_labels(datapath,model)

    tic;    % Keep track of time

    %% Load the data
    display('Loading the data...');
    data = load(datapath);

    %% Formatting
    display('Processing the data...');

    % Extract the data and labels
    xpol_data = data.classification_data;
    labels = xpol_data(251,:);
    xpol_data(251:254,:)=[];

    % Eliminate the NaN entries
    xpol_data(isnan(xpol_data))=0;

    % Transpose data to fit with classifier expectation
    xpol_data = xpol_data';
    labels = labels';

    %% Run the predictor
    display('Making predictions...');
    labels_pred = model.predictFcn(xpol_data);
    
    %% Determine the confusion matrix for the data
    conf = confusionmat(labels,labels_pred);
    
    display('Done!');
    %toc
    
    %% Return
    % Return labels_pred, a vector that indicates which columns of the data
    % are predicted to be fish hits (1) or not (0) and conf, the confusion
    % matrix for the predictor.
    
end