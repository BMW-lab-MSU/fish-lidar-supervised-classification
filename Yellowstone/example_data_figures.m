data_dir = 'C:\Users\bugsbunny\Box\AFRL_Data\Data\Yellowstone';

load([data_dir filesep 'processed_data_2016.mat'])


%%
cmap = flipud(colormap('gray'));

%%
col_start = 110250;
col_stop = 110500;
row_start =1400;
row_stop = 1540;

close all
fig_fish_example_raw = figure;
imagesc(xpol_raw(row_start:row_stop, col_start:col_stop), [0, 50]);
colormap(cmap);
hold on
set(gca, 'FontSize', 12)

annotation('ellipse', [0.62 0.64 0.05 0.2], 'LineStyle', '-', 'Color', '#67A3C1', ...
    'LineWidth', 3)
annotation('arrow', [0.2, 0.25], [0.9, 0.75], 'LineWidth', 2, 'Color', '#a3c166')
annotation('ellipse', [0.35 0.2 0.1 0.45], 'LineStyle', '--', 'LineWidth', 3, ...
    'Color', '#c18566')

xlabel('Flight Distance [m]')
xticks([0 xticks])
xticklabels(location.distance(col_start:col_stop))
ylabel('Distance from Airplane [m]')
yticks([0 yticks])
yticklabels(metadata.depth_increment*(row_start:row_stop))


fig_fish_example_processed = figure;
imagesc(xpol_processed(:, col_start:col_stop), [0, 50]);
colormap(cmap);
hold on
set(gca, 'FontSize', 12)

annotation('ellipse', [0.632 0.52 0.05 0.3], 'LineStyle', '-', 'Color', '#67A3C1', ...
    'LineWidth', 3)
annotation('arrow', [0.2, 0.3], [0.7, 0.85], 'LineWidth', 2, 'Color', '#a3c166')

xlabel('Flight Distance [m]')
xticks([0 xticks])
xticklabels(location.distance(col_start:col_stop))
ylabel('Depth [m]')
yticks([0 yticks])
yticklabels(metadata.depth_increment*(0:size(xpol_processed, 1) - 1))


%%
exportgraphics(fig_fish_example_raw, 'figs/fish_example_raw.pdf', 'ContentType', 'vector');
exportgraphics(fig_fish_example_processed, 'figs/fish_example_processed.pdf', 'ContentType', 'vector');