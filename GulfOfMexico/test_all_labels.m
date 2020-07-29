%%
test_data = load('CLASSIFICATION_DATA_10-07');

%%

xpol_data = test_data.classification_data;
label = xpol_data(251:254, :);
xpol_data(251:254, :) = [];
incorrect = 0;
total = length(label);
dec_val = zeros(1, length(label));

for idx = 1:length(labels)
    vect = labels(:, idx)';
    str_vect = num2str(vect);
    str_vect(isspace(str_vect)) = '';
    dec_val(1,idx) = bin2dec(str_vect);
end

predicted_labels = trainedModel3.predictFcn(xpol_data');

for idx = 1:length(predicted_labels)
    if predicted_labels(idx) ~= dec_val(idx)
        incorrect = incorrect + 1;
    end
end

percentAccuracy = (total-incorrect)/total;
%%
m = matfile('results_mat_group.mat','Writable',true);
result = ['10-07: ' num2str(percentAccuracy) ' Misses: ' num2str(incorrect) '/n '];

m.results = [m.results,result];