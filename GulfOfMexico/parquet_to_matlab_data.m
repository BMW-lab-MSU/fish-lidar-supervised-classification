% Simple function to convert a .parquet file in to a matlab data file
data_path = "C:\Users\kyler\Documents\Research\afrl-project\Oregon\ExamplePGM_08-21-2005\";
file = "jim_data.parquet";
output_path = "C:\Users\kyler\Box Sync\AFRL_Data\Data\OregonCoast";
output_file = "jim_data.mat";

disp("Loading parquet file");
disp(parquetinfo(data_path+file));
disp("Parquet file loaded");

disp("Saving parquet file as MATLAB table");
data = parquetread(data_path+file, );

save(output_path + output_file, data)
disp("Successfully save MATLAB table in location" + output_path);