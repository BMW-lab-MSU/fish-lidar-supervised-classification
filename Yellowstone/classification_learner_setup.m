 %% Classification Toolbox

close all; clear all; clc;
%% 
load CLASSIFICATION_DATA_2;

% Reduce column height to region of interest
start = 21;
stop = 80;
x = x(start:stop,:);

% Clip max intensities
% MAX_INTENSITY = 10;
% x(x>MAX_INTENSITY) = MAX_INTENSITY;

% Change cost for misclassifying fish (It is worse to miss a fish.)
cost = [0 1; 20 0];

data_for_classification_learner = [x;y]';

%% Now run the classification learner toolbox!

[QuadraticSVM, accuracy, yhat_cross_validated] = trainClassifier_QuadraticSVM(data_for_classification_learner);
yhat_cross_validated = yhat_cross_validated';

% load CLASSIFIER_2_QuadraticSVM;

% This is how you would classify new data
% Each column of x starts at the surface and goes 60 pixels deep.
yhat_cheating = QuadraticSVM.predictFcn(x')';

  yhat = yhat_cross_validated;
% yhat = yhat_cheating;

figure();
subplot(211); stem(y); title('Actual Labels');
subplot(212); stem(yhat); title('Predicted Labels');

labelmat = [y;y;y;y;y;zeros(5,length(y));yhat;yhat;yhat;yhat;yhat];
figure(); subplot(211); imagesc(labelmat,[0 2]); %xlim([640 670]);
xlabel({'Top Row = Human-Labeled Hits,','Bottom Row = Machine Learning Predicted Hits'});
subplot(212); imagesc(x,[0 10]); %xlim([640 670]); ylim([1 30]);
colormap((jet))
xlabel('LIDAR Image Data');

c = confusionmat(y,yhat);
figure(); confusionchart(c,{'No Fish','Fish'})
% figure();
% gscatter(QuadraticSVM.ClassificationSVM.X(:,1),QuadraticSVM.ClassificationSVM.X(:,2),y);
% hold on;
% plot(QuadraticSVM.ClassificationSVM.SupportVectors(:,1),QuadraticSVM.ClassificationSVM.SupportVectors(:,2),'ko','MarkerSize',10);
% hold off;