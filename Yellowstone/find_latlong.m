function column = find_latlong(lat,long,latlong)

    latitudes = latlong(1,:);
    longitudes = latlong(2,:);
    
    tol = 0.0005;
    
    lat_diff = abs(lat-latitudes);
    correct_lats = find(lat_diff<tol);
    
    long_diff = abs(long-longitudes);
    correct_longs = find(long_diff<tol);
    
    column = intersect(correct_lats,correct_longs);
    column = round(median(column));
    
    if isnan(column)
        column = 1000;
    end

end