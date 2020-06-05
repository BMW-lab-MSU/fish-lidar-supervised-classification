%% This file builds and labels the dataset for the Matlab classification suite
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% IMPORTANT: Read the README file BEFORE running
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------

filename = 'yellowstone_wfov_20160928.processed.h5';
%filename = 'yellowstone_20150923.processed.h5';

%hitsFileName = 'fish_hits_2015';                                           % Initialize hand recorded fish hits file
hitsFileName = 'fish_hits_2016';                                           % Compatible with .txt, .dat, .csv, .xls*, .xlt*, .ods
%h5disp(filename);   % uncomment to see dataset names

xpol_from_plane = h5read(filename,'/crosspol/radiance');                   % Initialize data vectors
surf_idx = h5read(filename,'/info/surface_index');
depth_increment = h5read(filename,'/info/depth_increment');
distance = h5read(filename,'/location/distance');
latlong = h5read(filename,'/location/latlong');

hitsMatrix = readmatrix(hitsFileName);                                     % Initialize hits vectors
hitsMatrix(:, 6) = [16, 22, 14, 60, 30, 12, 8];

%% Set the distances from the csv file -- 2015
fish_distances = hitsMatrix(:, 1);                                            % Initializing vectors of preselected fish hit data
fish_latitudes = hitsMatrix(:, 2);                                            % (All rows, second column)
fish_longitudes = hitsMatrix(:, 3);
%% Plot the path and the fish locations
separation = 250;                                                          % Alters the sampling frequency of the mapping
scatter(latlong(2,1:separation:size(latlong,2)),latlong(1,1:separation:size(latlong,2)),'m.'); axis square;
hold on; scatter(fish_longitudes,fish_latitudes,'ro','LineWidth',3);
hold on; scatter(-110.5555,44.4563,100,'d','filled'); hold off;
legend({'Flight Path','Fish Hits'});
xlabel('Longitude'); ylabel('Latitude');
axis([-110.6 -110.2 44.25 44.6]);
%% Loop through

DEPTH = 160;
        
N = length(fish_distances);                                                % Creates a variable equal to the number of known fish hits

for idx = 1:N
  
    cur_distance = fish_distances(idx);                                    % Define the current values according to indexed fish hit
    cur_latitude = fish_latitudes(idx);
    cur_longitude = fish_longitudes(idx);
    
    % Find the matrix column corresponding to that distance
    dif = cur_distance-distance;                                           % This bit of code takes the current distance and relates
    col(idx) = find(abs(dif)==min(abs(dif)));                              % it to the distance recorded. The lowest value of the dif
    col2(idx) = find_latlong(cur_latitude,cur_longitude,latlong);          % vector corrisponds to the correct sample column
    
    % Plot the cross-polarization data
    xdata = distance(col(idx)-500:col(idx)+500);
    xdata_col = col(idx)-500:col(idx)+500;
    ydata = 1:DEPTH;
    
    xpol_data = xpol_from_plane(:,col(idx)-500:col(idx)+500);
    xpol_surface_data = normalize_surface(xpol_data,surf_idx(col(idx)-500:col(idx)+500),DEPTH);
%    figure();
%    imagesc(xdata,ydata,xpol_surface_data,[0 10]);
%    title(['Distance = ' num2str(cur_distance)]);
    
    xpol_surf = xpol_surface_data(1:140,:);

    for i = 1:140
        for j = 1:length(xpol_surf)
            if xpol_surf(i,j) < 2
               xpol_surf(i,j) = 0;
            end
        end
    end
end 
%% Creating a "positive label" vector --- Author: Jackson Belford
%  The value for average column width per fish was calculated by taking the
%  average of (the column width eyeballed / number of fish indicated by
%  csv)

avgWidthPerFish = 4.57;
N = length(hitsMatrix(:, 6));
labelLength = zeros(N, 1);
columnNumber = zeros(N, 1);

for idx = 1:N

    tempLength = ceil(hitsMatrix(idx, 6) * avgWidthPerFish);
    
    if tempLength >= 55
        tempLength = ceil(tempLength/4);                                   % To better agree with Kyles work, large values assume
    end                                                                    % a tight school instead of a massive school
    
    labelLength(idx) = tempLength;
    
end

hits_vector = zeros(1, length(distance));

for idy = 1:N
    
    columnNumber(idy) = max(find(abs(distance-hitsMatrix(idy, 1)) < 1.5)); % Produces a vector with ones centered around the column number
                                                                           % that corrisponds to the CSV.
    hits_vector((columnNumber(idy)-ceil(labelLength(idy)/2)):(columnNumber(idy) + ceil(labelLength(idy)/2))) = 1;
    
end

%% Normalize surface index
depth_vector = zeros(1, length(distance));
xpol_norm = zeros(160, length(distance));

for i = 1:length(distance)                                                 % I need to personally review this chunk to understand :/
    depth_vector(i) = 160;
    if surf_idx(i) + 160 - 10 > 2048
        depth_vector(i) = 2048 - surf_idx(i) + 10; 
    end
end
 xpol_norm = normalize_surface_vect(xpol_from_plane, surf_idx, depth_vector);
%% Flooring and filtering of radiance data
 full_flight = zeros(1,length(distance));
 for i = 1:140                                                             % Any normalized xpol with a value less then the threshold (2)
     for j = 1:length(distance)                                            % is floored to 0
         if xpol_norm(i,j) < 2
           xpol_norm(i,j) = 0;
        end
    end
 end

%  for i = 1:length(distance)                                              % This filtering process proved unable to increase accuracy
%     threshold = sum(xpol_norm(20:140, i));
%     if threshold < 130
%        full_flight(i) = -1;
%     else
%        full_flight(i) = threshold;
%     end
%  end
% 
% k = full_flight == -1;
% xpol_norm(:,k) = [];
%% Windowing
start = 21;                                                                % Reduce column height to region of interest
stop = 80;
x = xpol_norm(start:stop,:);
y = hits_vector;

 MAX_INTENSITY = 10;                                                       % Clip max intensities
 x(x>MAX_INTENSITY) = MAX_INTENSITY;

cost = [0 5; 10 0];                                                        % Change cost for misclassifying fish (It is worse to miss a fish.)

data_for_classification_learner = [x;y]';

%% Now run the classification learner toolbox!

yhat_cheating = QuadraticSVM.predictFcn(x')';

% yhat = yhat_cross_validated;
 yhat = yhat_cheating;      

%% Specific label graphing (Before Area Application)

figure();
subplot(211); stem(y); title('Actual Labels');
subplot(212); stem(yhat); title('Predicted Labels');

figure(); imagesc(x,[0 10]); xlim([640 670]); ylim([1 30]);
xlabel('LIDAR Image Data');

c = confusionmat(y,yhat);
figure(); confusionchart(c,{'No Fish','Fish'})

%% Yhat area signifier

N = length(yhat);
window = 2500;
index = window;
trigger = 0;
while trigger == 0
   if index < length(yhat)
        if yhat(index) == 1
             yhat((index-window/2):(index+window/2)) = 1;
             index = index + window;
        else
             index = index + 1;
        end
    else
        trigger = 1;
            
    end
    
end

%% Human Labeled area signifier

N = length(y);
window = 2500;
index = window;
trigger = 0;
while trigger == 0
   if index < length(y)
        if y(index) == 1
             y((index-window/2):(index+window/2)) = 1;
             index = index + window;
        else
             index = index + 1;
        end
    else
        trigger = 1;
            
    end
    
end

%% Graphical Analysis


yHalf1 = y(1:ceil(length(y)/2));
yHalf2 = y(ceil(length(y)/2):length(y));
yhatHalf1 = yhat(1:ceil(length(yhat)/2));
yhatHalf2 = yhat(ceil(length(yhat)/2):length(yhat));

labelmat1 = [yHalf1;yHalf1;yHalf1;yHalf1;yHalf1;zeros(6,length(yHalf1));yhatHalf1;yhatHalf1;yhatHalf1;yhatHalf1;yhatHalf1];
labelmat2 = [yHalf2;yHalf2;yHalf2;yHalf2;yHalf2;zeros(6,length(yHalf2));yhatHalf2;yhatHalf2;yhatHalf2;yhatHalf2;yhatHalf2];

figure(); subplot(311); imagesc(labelmat1); xlim([0 100000]);
title('First Half of predictions and labels');
xlabel({'Top Row = Human-Labeled Hits,','Bottom Row = Machine Learning Predicted Hits'});
figure(); subplot(311); imagesc(labelmat2); xlim([0 100000]);
title('Second Half of predictions and labels');
xlabel({'Top Row = Human-Labeled Hits,','Bottom Row = Machine Learning Predicted Hits'});

%figure(95); imagesc([repmat(5 + 3*yhat(:,1:27195),10,1); repmat(5 + 3*y(:,1:27195),10,1); xpol_norm(:,1:27195)], [0 10]); colorbar; title('First Quarter of Full Flight');
%figure(96); imagesc([repmat(5 + 3*yhat(:,27195:54390),10,1);repmat(5 + 3*y(:,27195:54390),10,1); xpol_norm(:,27195:54390)], [0 10]); colorbar; title('Second Quarter of Full Flight');
%figure(97); imagesc([repmat(5 + 3*yhat(:,54390:81585),10,1);repmat(5 + 3*y(:,54390:81585),10,1); xpol_norm(:,54390:81585)], [0 10]); colorbar; title('Third Quarter of Full Flight');
%figure(98); imagesc([repmat(5 + 3*yhat(:,81585:108778),10,1);repmat(5 + 3*y(:,81585:108778),10,1); xpol_norm(:,81585:108778)], [0 30]); colorbar; title('Fourth Quarter of Full Flight');
