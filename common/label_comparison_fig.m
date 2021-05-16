function fig = label_comparison_fig(labels, predicted_labels, data, depth_increment)

LABEL_HEIGHT = 3;

% force labels to be row vectors
labels = labels(:)';
predicted_labels = predicted_labels(:)';

depth = [-ones(1, LABEL_HEIGHT * 2), depth_increment * (0:height(data) - 1)];

distance = 1:length(data);


%% lidar data image
fig = figure();
ax1 = axes;
imagesc(ax1, distance, depth, [repmat(zeros(1, width(data)), LABEL_HEIGHT * 2, 1); data]);

% remove first tick (-1) so the ticks start at 0 at the surface
ax1.YTick = ax1.YTick(2:end);

ax1.FontSize = 12;
ax1.YLabel.String = 'Depth [m]';
ax1.XLabel.String = 'Distance [shots]';

% remove axis box so the axis forms an "L" instead of a box; this makes the
% figure look better because the labels image cuts off the top part of the axis
ax1.Box = 'off';


%% labels image
ax2 = axes;
imagesc(ax2, distance, (-1:1/(2 * LABEL_HEIGHT):0), [repmat(labels, 3, 1); 2 * repmat(predicted_labels, 3, 1)]);
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];


%% overlay axes and set colormaps
% using multiple colormaps in a single axis
% https://www.mathworks.com/matlabcentral/answers/194554-how-can-i-use-and-display-two-different-colormaps-on-the-same-figure
linkaxes([ax1, ax2]);
colormap(ax1, flipud(colormap(brewermap(10000,'*PuBu'))));
colormap(ax2, [255, 255, 255; 220, 49, 0; 133, 194, 226]/255);


%% legend

% add "fake" lines so we can have a legend for the label blocks
% https://stackoverflow.com/questions/12902709/how-to-add-legend-in-imagesc-plot-in-matlab
L = line(ones(2),ones(2), 'LineWidth',2);
set(L,{'color'},mat2cell([220, 49, 0; 133, 194, 226]/255,ones(1,2),3));

legendobj = legend({'human labels', 'predicted labels'}, 'Location', 'southeast', 'EdgeColor', [1 1 1], 'FontSize', 12);

% setting legend background alpha:
% https://undocumentedmatlab.com/articles/transparent-legend
set(legendobj.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.3]));
set(legendobj.BoxEdge, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.3]));
end