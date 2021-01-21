# Yellowstone fish lidar classification

## Steps to reproduce results
1. Preprocess the data: `create_processed_mat_files`
2. Create the training data: `create_training_data`
3. Train the RUSBoost ensmeble: `train_classifier`
4. Test the classifier and see results: `test_classifier`

Note: due to the nature of random undersampling, it is likely that the training and testing results will vary because different majority class samples were used during training
