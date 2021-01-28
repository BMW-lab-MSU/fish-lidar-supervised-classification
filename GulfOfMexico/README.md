# Gulf of Mexico fish lidar classification

## Steps to reproduce results
In the files metioned in the following steps, the path(s) to the data files need to be set. This variable is typically called `box_dir`.

1. Convert the PNG files into MAT files: `script_extract_data_from_day.m`
1. Preprocess the data: `create_processed_mat_files.m`
2. Create the training data: `create_training_data.m`
3. Train the RUSBoost ensmeble: `train_classifier.m`
4. Test the classifier and see results: `test_classifier.m`

*Note*: due to the nature of random undersampling, it is likely that the results will vary a little bit when reproducing the experiments because different majority class samples will be used during training.

*Note*: `create_processed_mat_files.m` uses a lot of RAM (>32 GB), so you either need more RAM than that or you need some swap space.

## Reproducing paper figures
- Figures in the *Datasets* section of the paper can be produced by running `example_data_figures.m` 
- Figures in the *Results* section of the paper can be produced by running `results_figures.m`

You need to set the appropriate path to the data files in all of the scripts mentioned above. 
