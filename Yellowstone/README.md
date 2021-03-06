# Yellowstone fish lidar classification

## Steps to reproduce results
In the files metioned in the following steps, the path(s) to the data files need to be set. This variable is typically called `box_dir`.

1. Preprocess the data: `create_processed_mat_files.m`
2. Create the training data: `create_training_data.m`
3. Train the RUSBoost ensmeble: `train_classifier.m`
4. Test the classifier and see results: `test_classifier.m`

*Note*: due to the nature of random undersampling, it is likely that the results will vary a little bit when reproducing the experiments because different majority class samples will be used during training.

## Reproducing paper figures
- Figures in the *Datasets* section of the paper can be produced by running `example_data_figures.m` 
- Figures in the *Results* section of the paper can be produced by running `results_figures.m`
- Images that were used to create the preprocessing overview figure in the *Methods* section can be produced by running `pictures_for_methods_overview_figure.m`

You need to set the appropriate path to the data files in all of the scripts mentioned above. 