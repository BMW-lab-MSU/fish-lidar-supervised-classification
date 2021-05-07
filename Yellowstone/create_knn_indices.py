import scipy
import numpy as np
import h5py

from scipy.io import savemat, loadmat
from pynndescent import NNDescent

data_file = '../../Box/Data/Yellowstone/training/training_data.mat'

mat_contents = loadmat(data_file)

# Transpose so obversations are in rows
data = mat_contents['training_data'].T
labels = np.squeeze(mat_contents['training_labels'].T) == 1

print('creating full knn index')
index = NNDescent(data, n_neighbors=11, diversify_prob=0.0)
knn_index_full = np.int32(index.neighbor_graph[0]) + 1;
knn_index_full = knn_index_full[:,1:]
print(knn_index_full.shape)

print('creating minority class knn index')
index = NNDescent(data[labels,:], n_neighbors=11, diversify_prob=0.0)
knn_index_minority = np.int32(index.neighbor_graph[0]) + 1;
knn_index_minority = knn_index_minority[:,1:]
print(knn_index_minority.shape)

savemat('training_data_knn_indices.mat', 
    {'knn_index_full': knn_index_full, 'knn_index_minority': knn_index_minority}
    )