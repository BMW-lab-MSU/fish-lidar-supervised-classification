function surface_data = normalize_surface_vect(xpol,surface_index,depth)

    N = length(surface_index);
    surface_data = zeros(160,N);
    
    for i = 1:N
        start = surface_index(i) - 10;  % Start a little above the surface of the water
        stop = start + depth(i) - 1;
        if stop - start < 159
            surface_data(1:stop-start+1,i) = xpol(start:stop,i);
        else
            surface_data(:,i) = xpol(start:stop,i);
        end
    end
end