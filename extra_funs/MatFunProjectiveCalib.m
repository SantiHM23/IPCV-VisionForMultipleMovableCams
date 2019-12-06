function [F,P,X3d,xc] = MatFunProjectiveCalib(x)
%  MatFunProjectiveCalib Computes a projective calibration from points in both images
%
% Input:
%  - x(3,npoints,2): hom. coords of the points in the images
%
% Output:
%  - F(3,3): fundamental matrix 
%  - P(3,4,2): projection matrices
%  - X3d(4,npoints): 3D points in hom. coordinates
%  - xc(3,npoints,ncam): hom. coords of the reprojected points

[dim,npoints,ncam] = size(x);
P = zeros(3,4,ncam);

% ------------------------------------------------------------------------
% Fundamental matrix using FDLT_Norm
% ------------------------------------------------------------------------
[F, cost] = FDLT_Norm(x(:,:,1), x(:,:,2));
% ------------------------------------------------------------------------
% Compute the projection matrices from F using the definition in Hartley.
% You can use the function NumKernel that computes the left kernel of F (which is the right kernel of transposed F).
% Warning! Be careful with the order of the cameras to be compatible with
% the computed F. See Hartley p. 256 
% ------------------------------------------------------------------------
e_prime = NumKernel(F');
e_prime_x = Cross2Matrix(e_prime);
P1 = [eye(3),zeros(3,1)];
v = [0, 0, 0];
lambda = 1;
P_prime = [e_prime_x*F+e_prime*v, lambda*e_prime];
P(:,:,1) = P1;
P(:,:,2) = P_prime;


% ------------------------------------------------------------------------
% Compute the 3D points with the function linear_triangulation
% ------------------------------------------------------------------------
[X3d, cost] = linear_triangulation(x,P);

% ------------------------------------------------------------------------
% Compute the reprojected points 
% ------------------------------------------------------------------------
xc(:,:,1) = P1*X3d;
xc(:,:,2) = P_prime*X3d;



end
