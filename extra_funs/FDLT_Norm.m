% FDLT_Norm  The normalized DLT 8-point algorithm for F (fundamental matrix) 
% Algorithm  10.1 p.265 from  Multiple View (Hartley)
%
% Input: point correspondences (P,Q)
%  - P(3,npoints) : hom. coords of the points in the first image
%  - Q(3,npoints) : hom. coords of the points in the second image
%
% Output:
%  - F(3,3) : fundamental matix computed using SVD or eigen-values/vectors of (A'*A)
%  - cost: value of the smallest singular value of F


function [F,cost]=FDLT_Norm(P,Q)

    % 1. Affine normalization of the points in the first image
    [Pn,Tp] = NormalizAfin(P);

    % 2. Affine normalization of the points in the second image
    [Qn,Tq] = NormalizAfin(Q);

    % ------------------------------------------------------------------------
    % Create matrix A that represents the the homogeneous system Af=0. Vector f contains the coefficients of the fundamental matrix
    % A is a matrix with as many rows as point correspondences and 9 columns
    % ------------------------------------------------------------------------
    A = zeros(size(P,2), 9);
    Pt = Pn';
    Qt = Qn';
    for i = 1:size(Pt,1)
        A(i,1:3) = Pt(i,:)*Qt(i,1);
        A(i,4:6) = Pt(i,:)*Qt(i,2);
        A(i,7:9) = Pt(i,:)*Qt(i,3);
    end
    
    % ----------------------------------------------------------------
    % SVD solution for F. Use svd()
    % ----------------------------------------------------------------
     [U,D,V] =  svd(A);
    
    f = V(:,end);
    F = reshape(f, [3,3]);
    F = F';
    
    if (size(P,2)==8) cost=0; 
    else
        S = diag(D);
        cost = S(end);
    end
    disp(['Minimum singular value = ',num2str(cost)]);
       
    % ----------------------------------------------------------------
    % Enforce ranf 2 for F
    % ----------------------------------------------------------------
    [U2, S2, V2] = svd(F);
    S2(9) = 0;
    F = U2*S2*V2';
    
    % 4. De-normalization
    F = normalize_matrix((Tq.')*F*Tp);
    
end
