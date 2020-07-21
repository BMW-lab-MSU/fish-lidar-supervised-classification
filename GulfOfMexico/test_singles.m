%%
test_data = load('CLASSIFICATION_DATA_10-07');

%%

xpol_data = test_data.classification_data;
label = xpol_data(251, :);
xpol_data(251:254, :) = [];
incorrect = 0;
total = length(label);

predicted_labels = trainedModel3.predictFcn(xpol_data');

for idx = 1:length(predicted_labels)
    if predicted_labels(idx) ~= label(idx)
        incorrect = incorrect + 1;
    end
end

percentAccuracy = (total-incorrect)/total;

%%
m = matfile('results_mat.mat','Writable',true);
result = ['10-07: ' num2str(percentAccuracy) ' Misses: ' num2str(incorrect) '/n '];

m.results = [m.results,result];