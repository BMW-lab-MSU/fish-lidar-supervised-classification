# Yellowstone fish lidar classification
This directory contains code used to process the Yellowstone Lake dataset. The code can be split into several groups:
- data preprocessing
- creating training/test sets
- parameter tuning
- classifier training
- classifier testing and results

#### Data preprocessing
The entry point for preprocessing the data is `create_processed_mat_files.m`. 

#### Creating training/test sets
`create_first_day_training_data.m` does a train/test split by using the first day of the Yellowstone Lake dataset as the training set. `create_rand_training_data.m` performs a stratified 80/20 train/test split.

#### Parameter tuning
All files that begin with `tune` are for parameter tuning. `tune_*_first_day_*.m` are for the "first day" training set, and the others are for the 80/20 split. 

#### Classifier training
`train_*.m` train classifiers with the tuned parameters.

#### Classifier testing and results
`test_classifiers*.m` test all trained classifiers on the relevant testing set and saves results. `collect_cv_results.m` collects cross-validation results obtained during parameter tuning.  

## Steps to reproduce results
In the files metioned in the following steps, the path(s) to the data files need to be set. This variable is typically called `box_dir`.

### Preprocessing
1. Preprocess the data: `create_processed_mat_files.m`

### First day results
1. Create the training data: `create_first_day_training_data.m`
2. Tune the undersampling ratio: `tune_sampling_first_day_{lda,nnet,rusboost,svm.tree}.m`
3. Tune each model's hyperparameters: `tune_hyperparams_first_day_{lda,nnet,rusboost,svm,tree}.m`
4. Tune the number of labels needed for a region of interest: `tune_roi_first_day_{lda,nnet,rusboost,svm,tree}.m`
5. Train the final classifiers: `train_first_day_{lda,nnet,rusboost,svm,tree}.m`
6. Collect cross validation results: `collect_cv_results.m`
7. Test the classifiers: `test_classifiers_first_day.m`

### 80/20 split results
1. Create the training data: `create_rand_training_data.m`
2. Tune the undersampling ratio: `tune_sampling_{lda,nnet,rusboost,svm.tree}.m`
3. Tune each model's hyperparameters: `tune_hyperparams_{lda,nnet,rusboost,svm,tree}.m`
4. Tune the number of labels needed for a region of interest: `tune_roi_{lda,nnet,rusboost,svm,tree}.m`
5. Train the final classifiers: `train_{lda,nnet,rusboost,svm,tree}.m`
6. Collect cross validation results: `collect_cv_results.m`
7. Test the classifiers: `test_classifiers.m`


## Reproducing paper figures
- Figures in the *Datasets* section of the paper can be produced by running `example_data_figures.m` 
- Figures in the *Results* section of the paper can be produced by running `results_figures.m`
- Images that were used to create the preprocessing overview figure in the *Methods* section can be produced by running `pictures_for_methods_overview_figure.m`
- `roi_examples.m` produces the region of interest example figure in the *Discussion* section

You need to set the appropriate path to the data files in all of the scripts mentioned above. 