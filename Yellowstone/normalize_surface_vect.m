function surface_data = normalize_surface_vect(xpol,surface_index,depth, planeToSurf)
% Authors: Dr. Bradley Whitaker, Kyle Rust
% usage:   surface_data = normalize_surface_vect(xpol,surface_index,depth
%          xpol = Vector of cross polarized LiDAR Data
%          surface_index = Vector of surface indices for each column of
%                          xpol LiDAR data
%          depth = Vector of depths to traverse down. Each column is given
%          a default value before being passed into this function. If the
%          default value is added to the surface index and the results is
%          out of bounds the greatest possible is calculated. That value is
%          reassigned to that column. This effectively appends zeros to
%          columns that are too shallow, which normalizes the surface
%          without changing the data. 
%  

    N = length(surface_index);
    surface_data = zeros(planeToSurf,N);
    surfacePad = 10;
    
    for i = 1:N
        start = surface_index(i) - surfacePad;  % Start a little above the surface of the water
        stop = start + depth(i) - 1;
        if stop - start < (planeToSurf-1)
            surface_data(1:stop-start+1,i) = xpol(start:stop,i);
        else
            surface_data(:,i) = xpol(start:stop,i);
        end
    end
end