% Unit tests for find_water_surface.m
% run with runtests('find_water_surface_test')

% SPDX-License-Identifier: BSD-3-Clause

% setup
vect = [0 ; 0; 0; 1; 0; 0; 2; 1; 1; 20; 50; 120; 50; 20; 1; 0; 0; 0];
matrix = [vect, circshift(vect, 2), circshift(vect, -3)];

%% Test 1: 'before_max' algorithm type on 1-D vector
idx = find_water_surface(vect, 'before_max');
expected = 9;
assert(idx == expected)

%% Test 2: without specifying algorithm type on 1-D vector
idx = find_water_surface(vect);
expected = 9;
assert(idx == expected)

%% Test 3: 'max' algorithm type on 1-D vector
idx = find_water_surface(vect, 'max');
expected = 12;
assert(idx == expected)

%% Test 4: 'before_max' algorithm type on matrix
idx = find_water_surface(matrix, 'before_max');
expected = [9 11 6];
assert(all(idx == expected))

%% Test 5: 'max' algorithm type on matrix
idx = find_water_surface(matrix, 'max');
expected = [12 14 9];
assert(all(idx == expected))