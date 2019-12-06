clear all;
close all;
clc;

addpath(cd)
addpath(genpath('Lab5'))
addpath(genpath('allfns'))

n_images = 8;
My_Dataset = {}; %Cell to store the images

for i = 1:n_images
    %Open the input image
    filename = sprintf('./Images/Section2-3/Panoramic/mydataset_%d.jpg', i);
    im = imread(filename);
    MyDataset{i} = im;
end

%Create the montage of the images
figure(); montage(MyDataset);

%Addresses for the matching step and generating the panoramic image
filename_match = sprintf('Images/Section2-3/Matching/');
filename_pano = sprintf('Images/Section2-3/Panoramic/');

%Images used for the matching, and to be used to check the performance of
%the fundamental matrix
image1 = imread(sprintf('./Images/Section2-3/Matching/ima1.jpg'));
image2 = imread(sprintf('./Images/Section2-3/Matching/ima2.jpg'));

%Create the panoramic image
doPanorama(filename_pano);

%Obtain the matched points of the images to match, with the corresponding 
%selected descriptor and detector 
[matchedPoints] = POI_based_ImageMatching(filename_match, 'KAZE', 'KAZE'); 

%Estimate the fundamental matrix of the obtained matched points
[F,inliersIndex] = estimateFundamentalMatrix(matchedPoints{1},matchedPoints{2});

%Get the number of inliers from the fundamental matrix
n_inliers = sum(inliersIndex(:));

%Visualize the performance of the fundamental matrix
fig = vgg_gui_F(image1,image2,F');