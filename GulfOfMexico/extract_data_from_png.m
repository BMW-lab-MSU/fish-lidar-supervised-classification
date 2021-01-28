function datastruct = extract_data_from_png(filename)

rawdata = imread(filename);

file_parts = strsplit(filename, filesep);

cur_date = file_parts{end-1};
cur_filename = file_parts{end};

numshots = size(rawdata,2);

time = zeros(1,numshots);
lat = zeros(1,numshots);
lon = zeros(1,numshots);
co_gain = zeros(1,numshots);
x_gain = zeros(1,numshots);
tilt = zeros(1,numshots);
temp = zeros(1,numshots);
icath_co = zeros(1000,numshots);
icath_x = zeros(1000,numshots);
date = cell(1,numshots);
PNG_file = cell(1,numshots);
PNG_column = zeros(1,numshots);

for i = 1:numshots
    shot_data = rawdata(:,i);
    [time(i), lat(i), lon(i), co_gain(i), x_gain(i), tilt(i), temp(i)] = read_aux(shot_data);
    date{i} = cur_date;
    PNG_file{i} = cur_filename;
    PNG_column(i) = i;
    icath_co(:,i) = convert_shot(shot_data, co_gain(i), x_gain(i), 'co');
    icath_x(:,i) = convert_shot(shot_data, co_gain(i), x_gain(i), 'x');
end

datastruct.time = time;
datastruct.lat = lat;
datastruct.lon = lon;
datastruct.co_gain = co_gain;
datastruct.x_gain = x_gain;
datastruct.tilt = tilt;
datastruct.temp = temp;
datastruct.icath_co = icath_co;
datastruct.icath_x = icath_x;
datastruct.date = date;
datastruct.PNG_file = PNG_file;
datastruct.PNG_column = PNG_column;

end
