function fig = label_comparison_fig(labels, predicted_labels, data)

% TODO: make y-axis depth values
% TODO: make x-axis distance values
% FIXME: axis gets cut off around labels plot/image; e.g. the axis box does not go all the way around the image
% TODO: make axis font sizes 14 pt (or at least something larger than the default)

LABEL_HEIGHT = 3;

% force labels to be row vectors
labels = labels(:)';
predicted_labels = predicted_labels(:)';


% using multiple colormaps in a single axis
% https://www.mathworks.com/matlabcentral/answers/194554-how-can-i-use-and-display-two-different-colormaps-on-the-same-figure

fig = figure();
ax1 = axes;
imagesc(ax1, [repmat(zeros(1, width(data)), LABEL_HEIGHT * 2, 1); data])

ax2 = axes;
imagesc(ax2, [repmat(labels, 3, 1); 2 * repmat(predicted_labels, 3, 1)]);

linkaxes([ax1, ax2])
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];

colormap(ax1, flipud(colormap('gray')));
colormap(ax2, [255, 255, 255; 163, 193, 102; 103, 163, 193]/255)

% add lin
% https://stackoverflow.com/questions/12902709/how-to-add-legend-in-imagesc-plot-in-matlab
L = line(ones(2),ones(2), 'LineWidth',2);
set(L,{'color'},mat2cell([163, 193, 102; 103, 163, 193]/255,ones(1,2),3));

legendobj = legend({'human labels', 'predicted labels'}, 'Location', 'southeast', 'EdgeColor', [1 1 1], 'FontSize', 14)

% setting legend background alpha:
% https://undocumentedmatlab.com/articles/transparent-legend
set(legendobj.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.3]));

end