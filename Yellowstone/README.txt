This README file will guide you through any file labeled runSVM*.m
	This refers to runSVM2015, runSVM2016, and so forth
	
runSVM201{5,6} have hardcoded h5 and csv file names; runSVM allow hardcoded 
filenames as well as lets users graphically select files. 

Addition Files Needed to runSVM*:
find_latlong.m
normalize_surface_vect.m    ---- (In the future we hope to combine the independent functionality
                                    of these two similar functions into a single file labeled under
                                    normalize_surface.m)

	
This document will be seperated according to the title of each MATLAB section:

%% This file builds and labels the dataset for the Matlab classification suite
NOTE: You must initialize your data in this section. Once you change the required fields, you can run the program without issue.

	- filename is a string showing the path to your .h5 data file
	- hitsFileName is a string showing the path to your known hits tables. (.txt, .dat, .csv, .xls*, .xlt*, .ods)
		- Note, this table should be organized in the following manner:
			Distance, Latitude, Longitude, FishDepth, BottomDepth, Estimated School Size (# of fish)
	- hits matrix hard coded estimated school size values due to the last column being a string, not an int
	
	
%% Creating a "positive label" vector --- Author: Jackson Belford
	- avgWidthPerFish is the estimated number of columns per individual fish in labeled group
	- returns a hits_vector which labels columns based on the distance noted in the tables, and the estimated school size


%% Flooring and filtering of radiance data
	- The first filter is a high-pass filter, flooring values less then --- (xpol_norm(i, j) < 2 --- a value.
	- The second filter I am still toying with, and will update this document later.
	
	
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
	Uncomment last four figures to see the complete flight in sections.
	- Zoom out on the LIDAR Image Data to see a complete image
	- View stem plot showing predicted labels vs. actual labels