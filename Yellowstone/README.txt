This README file will guide you through any file labeled runSVM*.m
	This refers to runSVM2015, runSVM2016, and so forth
	
runSVM201{5,6} have hardcoded h5 and csv file names; runSVM allow hardcoded 
filenames as well as lets users graphically select files. 

Addition Files Needed to runSVM*:
find_latlong.m
normalize_surface_vect.m
create_positive_label_vect.m

	
This document will be seperated according to the title of each MATLAB section:

%% This file builds and labels the dataset for the Matlab classification suite
NOTE: You must initialize your data in this section. Once you change the required fields, you can run the program without issue.

	- filename is a string showing the path to your .h5 data file
	- hitsFileName is a string showing the path to your known hits tables. (.txt, .dat, .csv, .xls*, .xlt*, .ods)
		- Note, this table should be organized in the following manner:
			Distance, Latitude, Longitude, FishDepth, BottomDepth, Estimated School Size (# of fish)
	- hits matrix hard coded estimated school size values due to the last column being a string, not an int
	
%% Setup
    - data_dir can be a relative or absolute path
        - an empty string will prompt a UI document selector.
    - data_filename
        - an empty string will prompt a UI document selector.
    - hitsFileName
        - Table of labeled instances
        - an empty string will prompt a UI document selector.

%% Load in the classifier mat file
    - load file from direct path or open file selector UI

%% Load dataset
    - load file from direct path or open file selector UI
    - .h5 file exclusive
    - IMAGE_DEPTH = the number of rows in xpol data

%% Load Human Labeled fish hits
    - load file from direct path or open file selector UI
    - full_filepath
        - Loads in hits matrix file path
    - hitsMatrix
        - Matrix of positive labels

%% Set the distances from the csv file
    - fish_distances
        - First column of hits matrix
    - fish_latitudes
        - Second column of hits matrix
    - fish_longitudes
        - Third column of hits matrix
    - school_size
        - seventh column of hits matrix

%% Plot the path and the fish locations
    - separation:
        - Column distance between plotted long, lat point.
    - Plots  2d scatter-plot of the flight path, can be overlayed on google maps!

%% Creating a "positive label" vector --- Author: Jackson Belford
	- avgWidthPerFish is the estimated number of columns per individual fish in labeled group
	- returns a hits_vector which labels columns based on the distance noted in the tables, and the estimated school size

%% Normalize Surface Index
    - depth_vector
        - shows the depth of each measurement column
    - xpol_norm
        - I might be wrong about what planeToSurf means.
    - Runs normalize_surface_vect() returning a normalized vector, smoothing bumps

%% Flooring and filtering of radiance data
	- The first filter is a high-pass filter, flooring values less then --- (xpol_norm(i, j) < 2 --- a value.
	
	
%% Windowing
	- Reduces column height to a region of interest
		- start: the row at which the column starts
		- stop:  the row at which the column ends
	- Clip max intensities to reduce outliers
		- MAX_INTENSITY is usually set to around 10
	- Cost Calculation
		- Low cost for incorrectly guessing a fish
		- High cost for missing a labeled fish

		
%% Now run the classification learner toolbox!

%% Specific label graphing (Before Area Application)
    - Shows a stem plot of predicted labels vs. chosen labels
	- Zoom out on the LIDAR Image Data to see a complete image
    - Confusion matrix values (can be mis-leading)

%% machine labeled area block
    - window
        - Set to the number of rows blocked around a hit
        - Should be based on school size?

%% Human labeled area block
    - Equivalent to the machine labeled block process for the y labels

%% Graphical Analysis
    Shows areas of interest.
	Uncomment last four figures to see the complete flight in sections.