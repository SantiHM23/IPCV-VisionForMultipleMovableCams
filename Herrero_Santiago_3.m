clear all;
close all;
clc;

addpath(cd)
addpath(genpath('ACT_lite'))
addpath(genpath('Lab5'))
addpath(genpath('extra_funs'))
addpath(genpath('allfns'))

load Afinal

n_images = 8;
My_Dataset = {}; %Cell to store the images

for i = 3:n_images
    %Open the input image
    filename = sprintf('./Images/Section2-3/Composition/composition_%d.jpg', i);
    im = imread(filename);
    MyDataset{i-2} = im;
end

%K = repmat(A, 1, 1, ncam);
filename_compo = sprintf('Images/Section2-3/Composition/');
[~, p_locations, features, MaxRatio, Metric] = POI_based_ImageMatching(filename_compo, 'KAZE', 'KAZE');

% ------------------------------------------------------------------------
% 1. Get the cloud points from the matchings
% ------------------------------------------------------------------------
point_matrix = n_view_matching(p_locations, features, MyDataset, MaxRatio, Metric);
q_data = homogenize_coords(point_matrix);
[~, npoints, ncam] = size(q_data);
K = repmat(A, 1, 1, ncam);


% ------------------------------------------------------------------------
% 2a. Compute the fundamental matrix using the first and last cameras
% of the camera set (N cameras)
% ------------------------------------------------------------------------
q_used_cams(:,:,1) = q_data(:,:,1); 
q_used_cams(:,:,2) = q_data(:,:,end);
[F_est,P_est,Q_est,q_est] = MatFunProjectiveCalib(q_used_cams);

% ------------------------------------------------------------------------
% 2b. Compute the mean reprojection error
% ------------------------------------------------------------------------
disp(['Resudual reprojection error. 8 point algorithm   = ' num2str( ErrorRetroproy(q_used_cams,P_est,Q_est)/2 )]);
draw_reproj_error(q_used_cams,P_est,Q_est);

% ------------------------------------------------------------------------
% 3a. Improve this initial reconstruction by means of a Projective Bundle
% Adjustment
% ------------------------------------------------------------------------
% Resectioning step
for i = 1:ncam
    [P_resect(:,:,i),~]= PDLT_NA(q_data(:,:,i),Q_est,0,0);
end

% Auxiliary matrix that indicates that all points are visible in all the cameras
vp = ones(npoints,ncam);
% Bundle adjustment
[P_bundle,Q_bundle,q_bundle] = BAProjectiveCalib(q_data,P_resect,Q_est,vp);

% ------------------------------------------------------------------------
% 3b. Compute the mean reprojection error after the resectioning step and
% after the bundle adjustment
% ------------------------------------------------------------------------
disp(['Resudual reprojection error. 8 point algorithm   = ' num2str( ErrorRetroproy(q_data,P_resect,Q_est)/2 )]);
draw_reproj_error(q_data,P_resect,Q_est);
disp(['Resudual reprojection error. 8 point algorithm   = ' num2str( ErrorRetroproy(q_data,P_bundle,Q_bundle)/2 )]);
draw_reproj_error(q_data,P_bundle,Q_bundle);

% ------------------------------------------------------------------------
% 4. Re-compute the Fundamental matrix between two of the cameras, using
% the projection matrices obtained in the bundle adjustment step
% ------------------------------------------------------------------------
F = vgg_F_from_P(P_bundle(:,:,1), P_bundle(:,:,2));

% Normalization of the fundamental matrix:
 F = F / max(max(F));

% ------------------------------------------------------------------------
% 5. Obtain the essential matrix (E) from the fundamental matrix (F) and the
% intrinsic parameter matrices (A) and use it to obtain an euclidean
% reconstruction of the scene
% ------------------------------------------------------------------------
% Calculate essential matrix 
E = K(:,:,2)'*F*K(:,:,1);

% Obtain extrinsic parameters
[R_est,T_est] = factorize_E(E);
 
% Obtain the possible combinations of the two cameras, being the first one
% fixed
[Rcam, Tcam] = camera_combinations(R_est, T_est);

% ------------------------------------------------------------------------
% 5. For each solution we obtain an Euclidean solution and we visualize it.
% ------------------------------------------------------------------------
npoints = size(q_data,2);
Q_euc = zeros(4,npoints,2); % Variable for recontructed points
P_euc = zeros(3,4,2);       % Variable for projection matrices
figNo=figure;

for rec=1:4
    % Euclidean triangulation to obtain the 3D points (use TriangEuc)
    Q_euc = TriangEuc(Rcam(:,:,2,rec), Tcam(:,2,rec), K(:,:,1:2), q_bundle);
    % visualize 3D reconstruction
    figure();
    draw_scene(Q_euc, K(:,:,1:2), Rcam(:,:,:,rec), Tcam(:,:,rec));
    title(sprintf('Solution %d', rec));
    
    % Compute the projection matrices from K, Rcam, Tcam
    for k=1:2
        P_euc(:,:,k) = K(:,:,k)*[Rcam(:,:,k,rec),-Rcam(:,:,k,rec)*Tcam(:,k,rec)];
    end
    
    % Visualize reprojectd points to check that all solutions correspond to
    % the projected images
    
     q_rep(:,:,1) = P_euc(:,:,1)*Q_euc;
     q_rep(:,:,2) = P_euc(:,:,2)*Q_euc;
    
    
    for k=1:2
      figure(figNo); subplot(4,2,2*(rec-1)+k); scatter(q_rep(1,:,k),q_rep(2,:,k),30,[1,0,0]);
      title(sprintf('Reprojection %d, image %d', rec, k));
      daspect([1, 1, 1]);
      pbaspect([1, 1, 1]);
      axis([-1000, 1000, -1000, 1000]);
    end
end