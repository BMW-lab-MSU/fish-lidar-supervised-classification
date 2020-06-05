function surface_data = normalize_surface(xpol,surface_index,DEPTH)

    N = length(surface_index);
    surface_data = zeros(DEPTH,N);
    
    for i = 1:N
        start = surface_index(i) - 10;  % Start a little above the surface of the water
        stop = start + DEPTH - 1;
        surface_data(:,i) = xpol(start:stop,i);
    end
end