function [time, lat, lon, co_gain, x_gain, tilt, temp] = read_aux(shot_data)

%% Time
hr = str2double(char(shot_data(2094+1:2095+1))');
mn = str2double(char(shot_data(2096+1:2097+1))');
fs = str2double(char(shot_data(2098+1:2103+1))');
time = hr + mn/60 + fs/3600;

%% Latitute and Longitude
lat = str2double(char(shot_data(2001+1:2009+1))');
lon = str2double(char(shot_data(2012+1:2020+1))');

%% PMT Gains
V0 = str2double(char(shot_data(2023+1:2029+1))');
co_gain = 10^(-3.0332+23.395*log10(V0) - 12.664*(log10(V0))^2);

V1 = str2double(char(shot_data(2031+1:2037+1))');
x_gain = 10^(-2.8862+23.239*log10(V1) - 12.152*(log10(V1))^2);

%% Tilt

tilt = 100*str2double(char(shot_data(2047+1:2053+1))');

%% Temperature

temp = 5.096*str2double(char(shot_data(2055+1:2062+1))') - 0.3129;

end