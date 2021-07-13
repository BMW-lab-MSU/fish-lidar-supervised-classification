function frames = create_regions(data, window_size, overlap)

% SPDX-License-Identifier: BSD-3-Clause

arguments
   data (:,:) 
   window_size (1,1) double {mustBePositive, mustBeInteger}
   overlap (1,1) double {mustBeInRange(overlap, 0, 0.99)} = 0
end

n_instances = length(data);
n_frames = ceil(n_instances/(window_size * (1 - overlap)));

frames = cell(n_frames, 1);

stop = 0;
for i = 1:n_frames
    start = stop - floor(overlap * window_size) + 1;
    stop = start + window_size - 1;

    if stop > n_instances
        stop = n_instances;
    end

    frames{i} = data(start:stop, :);
end