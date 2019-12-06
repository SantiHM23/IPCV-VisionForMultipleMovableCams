clear all;
close all;
clc;

addpath(cd)
addpath(genpath('Lab2'))

%Calibrate your camera, using the  large  checkerboard  provided, 
%with  a  square  size  of  70  mm, and the small checkboard provided, with
%a square size of 36 mm
ch_square_Big = 70;
ch_square_Small = 36;
ch_sizeBig = 8 * ch_square_Big; %Size of the big checkboard
ch_sizeSmall = 8 * ch_square_Small; %Size of the small checkboard
n_images = 6; %Number of images in each dataset
selected_points = 9; %points to obtain from the checkboard

%Exercise 1
dataBig = sprintf('BigBoard');
[Amatrix_BigBoard] = obtain_A_matrix(ch_sizeBig, n_images, selected_points, dataBig);

%Exercise 2
dataSmall = sprintf('SmallBoard');
[Amatrix_SmallBoard] = obtain_A_matrix(ch_sizeSmall, n_images, selected_points, dataSmall);