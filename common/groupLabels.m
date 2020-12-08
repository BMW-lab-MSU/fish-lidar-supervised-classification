function groupedLabels = groupLabels(labels, threshold, windowSize, overlap)
% groupLabels Group binary labels into (potentially) overlapping windows to
% determine regions of interest
%
%   groupedLabels = groupLabels(labels, threshold, windowSize) groups labels
%   into regions of interest of size windowSize. groupedLabels is a 
%   1-by-ceil(numel(labels) / windowSize) label vector, where a 1 corresponds
%   to a region of interest that has at least threshold number of hits.
%
%   groupedLabels = groupLabels(labels, threshold, windowSize, overlap) groups
%   labels into regions of into overlapping regions of interest. overlap is a
%   fraction of the window size between 0 and 1

arguments
   labels (1,:) double {mustBeInteger}
   threshold (1,1) double
   windowSize (1,1) double {mustBePositive, mustBeInteger}
   overlap (1,1) double {mustBeInRange(overlap, 0, 1)} = 0
end

if windowSize > numel(labels)
    error('windowSize must be less than or to the number of labels')
end

groupedLabels = sum(buffer(labels, windowSize, floor(overlap * windowSize))) >= threshold;
end