% 30
%results = load('results_trainedModel_FineTree.mat');
%image_data = load('Data/CLASSIFICATION_DATA_09-30.mat');

% Select a set of labels and predicted labels
labels = results.labels(1,1);
predicted_labels = results.predicted_labels(1,1);
image_plot_data = image_data.labeled_xpol_data();

image_plot_data(isnan(image_plot_data))=0;

% Creating a 10xlabel_length matrix 1-5 being predicted and 5-10 labeled
labels_array = cell2mat(labels)';
predicted_labels_array = cell2mat(predicted_labels)';

labels = vertcat(labels_array, labels_array, labels_array, labels_array, labels_array);
predicted_labels = vertcat(predicted_labels_array, predicted_labels_array, predicted_labels_array, predicted_labels_array, predicted_labels_array);

% Create image data to be windowed
plot_data = vertcat(predicted_labels, labels);
plot_data2 = vertcat(plot_data, image_plot_data(:, 1:220781));
% Select first real label centered and show predicted
for ax = 1:length(predicted_labels_array)
    if predicted_labels_array(ax) ~= 0
        for bx = 1:50
           predicted_labels_array(ax+bx) = predicted_labels_array(ax);
        end
    end
end

% Fig 4, 9, 11, and 13

plot_window = 1000;

image_number = 0;

for index = 1:length(labels_array)
   if labels_array(index) ~= 0 && image_number < 20
       figure()
       subplot(2, 1, 1);
       % Plot predicted labels
       image(plot_data2(1:10,index-plot_window:index+plot_window),'CDataMapping', 'scaled'); colorbar; title('Machine Predicted Over Human Predicted');
       subplot(2, 1, 2);
       % Plot image
       image(plot_data2(10:200,index-plot_window:index+plot_window), 'CDataMapping', 'scaled'); colorbar; title('Image');
       image_number = image_number + 1;
   end
end