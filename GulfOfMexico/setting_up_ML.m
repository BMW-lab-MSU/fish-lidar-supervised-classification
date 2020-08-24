file_name = 'CLASSIFICATION_DATA_09-24.mat'
full_data = load(file_name);
xpol_data = full_data.labeled_xpol_data(1:1000,:);
label_data = full_data.labeled_xpol_data(1001:1004,:);

%% Find maximum xpol radiance

surface_index = zeros(1,length(xpol_data));

for idx = 1:length(xpol_data)
    [m, surface_index(1,idx)] = max(xpol_data(:, idx));
end



surface_index(isnan(surface_index))=0;

normalized_xpol = normalize_surface_height(xpol_data, surface_index, 0);


%% Remove empty columns
col_total = 0;
for idx = length(normalized_xpol)
    col_sum = sum(idx, 1);
    col_total =+ col_sum;
end
col_avg = col_total/length(normalized_xpol);
for idx = length(normalized_xpol)
    col_sum = sum(idx, 1);
    if col_sum < col_avg*.15 && all(label_data(:, idx)==0)
        normalized_xpol(:, idx) = [];
    end
end

%% Save Data
save(file_name, 'normalized_xpol', '-v7.3');
disp('Saved: ' + file_save_name)
%% Plots

data_to_plot = xpol_data(:,390000:400000);
figure();
subplot(311); plot(data_to_plot); colorbar; title('Lineplot of xpol values as depth increases. Note a surface near 410');
norm_data_plot = normalized_xpol(:,390000:400000);
subplot(312); plot(norm_data_plot); colorbar; title('Lineplot of xpol values as depth increases. Note a surface near 410');
figure();
subplot(311);
image(data_to_plot,'CDataMapping', 'scaled'); colorbar; title('Xpol Data (Non-normalized): (390k, 400k)');
subplot(312);
image(norm_data_plot,'CDataMapping', 'scaled'); colorbar; title('Xpol Data (Normalized): (390k, 400k)');
subplot(313);
image(label_data(:, 390000:400000)); colorbar; title('Label Data');