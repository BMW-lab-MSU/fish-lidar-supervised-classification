full_data = load('CLASSIFICATION_DATA_09-24.mat');
xpol_data = full_data.labeled_xpol_data(1:1000,:);
label_data = full_data.labeled_xpol_data(1001:1004,:);

%% Find maximum xpol radiance

surface_index = zeros(1,length(xpol_data));

for idx = 1:length(xpol_data)
    [m, surface_index(1,idx)] = max(xpol_data(:, idx));
end



surface_index(isnan(surface_index))=0;

normalized_xpol = normalize_surface_height(xpol_data, surface_index, 0);

%% Plots

data_to_plot = xpol_data(:,390000:400000);
figure();
subplot(311); plot(data_to_plot); colorbar; title('Lineplot of xpol values as depth increases. Note a surface near 410');
norm_data_plot = normalized_xpol(:,390000:400000);
figure();
subplot(311); plot(norm_data_plot); colorbar; title('Lineplot of xpol values as depth increases. Note a surface near 410');
figure();
image(data_to_plot,'CDataMapping', 'scaled'); colorbar; title('Xpol Data (Non-normalized): (390k, 400k)');
figure();
image(norm_data_plot,'CDataMapping', 'scaled'); colorbar; title('Xpol Data (Non-normalized): (390k, 400k)');