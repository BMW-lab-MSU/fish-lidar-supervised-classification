%% Water Height Normalization Function
% Joseph Aist

% This function noramlizes the height of the water so that the starting
% height of the water is the same throughout the section being observed.

% if unclear about what data to input, below are examples of the initial
% LIDAR data required for this function. 
%   filename = 'yellowstone_wfov_20160928.processed.h5';
%   filename = 'yellowstone_20150923.processed.h5';
%   xpol_from_plane = h5read(filename,'/crosspol/radiance');
%   copol_from_plane = h5read(filename,'/copol/radiance');
%   idx = h5read(filename,'/info/surface_index');

% add xpol and copol to get the total radiance. Skip the first 512 samples
% because they are just the air
% since I have added the xpol and copol, the radiance off the surface of
% the water should be the max radiance.

% index_1 is the index of the collumn you want to start at and index_2 is
% the index of the collumn you are ending at
% LIDAR was not reading water surface properly before 3837, so choose index
% values greater than or equal to 3838.

% Depth is how deep into the water you want to view. sky_height is the 
% amount of air above the surface of the water.

function [normalized_surface,idx] = surface_normalization(xpol_from_plane,copol_from_plane,index_1,index_2,depth,sky_height)

idx = zeros(1,size(copol_from_plane,2));
skip_samp = 512;
rad = copol_from_plane(skip_samp:end,:)+xpol_from_plane(skip_samp:end,:);
rad(rad<5) = 0;
column_length = size(xpol_from_plane,1);
xpol_from_plane_zeropad = [xpol_from_plane;zeros(depth,size(xpol_from_plane,2))];


normalized_surface = zeros(depth,index_2-index_1+1);
for k = index_1:index_2
%      bb = 1/11*ones(1,11);
%      rad_lpf = filter(bb,1,rad(:,k));
%      rad_med = medfilt1(rad(:,k),3);
    if k == index_1
        [~,loc] = findpeaks(rad(:,k));
    else 
        [~,loc] = findpeaks(rad(idx(k-1)-20:idx(k-1)+20,k));
    end 
        if size(loc)>=1
            if k == index_1
                idx(k) = loc(1);
            else
                [~,idx_peak] = min(abs(idx(k-1)-loc));
                idx(k) = loc(idx_peak)+idx(k-1);
            end
            if (idx(k)+skip_samp+depth) < column_length
                normalized_surface(:,k-index_1+1) = xpol_from_plane(skip_samp+idx(k)-sky_height:skip_samp+idx(k)-sky_height+depth-1,k);
            else
                normalized_surface(1:depth,k-index_1+1) = xpol_from_plane_zeropad(skip_samp+idx(k)-sky_height:skip_samp+idx(k)-sky_height+depth-1,k);
            end 
        else
            % skip shot if no peak is detected
        end
        
end
idx = idx + skip_samp - sky_height;
end

