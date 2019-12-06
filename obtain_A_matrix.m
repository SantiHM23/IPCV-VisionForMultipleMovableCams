function [Amatrix] = obtain_A_matrix(ch_size, n_images, selected_points, dataset)


Pts_cell = {}; %Cell for storing the manual selected points
Hom_cell = {}; %Cell for storing the homographies
Final_homography = {}; %Cell for storing the refined homographies

%Obtain the position of (at least) 9 points in the pattern:
[c, im_pattern] = get_real_points_checkerboard_vmmc(selected_points, ch_size, 1);

%Obtain the homography of every image
for i = 1:n_images
    %Open the input image
    filename = sprintf('./Images/Section1/%s/%s_%d.jpg', dataset, dataset, i);
    im = imread(filename);
    
    %Select the homography points manually and store them
    Pts_cell{i} = get_user_points_vmmc(im);
    
    %Compute the homography and refine it
    Hom_cell{i} = homography_solve_vmmc(c', Pts_cell{i});
    [Final_homography{i}, ~] = homography_refine_vmmc(c', Pts_cell{i}, Hom_cell{i});

    %Apply the homography to obtain the output image
    T = maketform('projective', Final_homography{i}');
    tr_ima = imtransform(im_pattern,T);
    
end

Amatrix = internal_parameters_solve_vmmc(Final_homography);