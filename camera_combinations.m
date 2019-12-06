function [Rcam, Tcam] = camera_combinations(R_est, T_est)
% ------------------------------------------------------------------------
% Save the 4 solutions (R,t) in the structures Rcam(3,3,cam,sol), T(3,cam,sol),
% where cam indicates the camera number and sol indicates the solution number (1, 2, 3 or 4).
% ------------------------------------------------------------------------
Rcam = zeros(3,3,2,4);
Tcam = zeros(3,2,4);
for i = 1:size(R_est,3)
    for j = 1:size(Rcam,4)
        if (i == 1)
            Rcam(:,:,i,j) = eye(3);
            Tcam(:,i,j) = zeros(3,1);
        else
            if(mod(j,2)==0)
                Tcam(:,i,j) = -T_est;
            else
                Tcam(:,i,j) = T_est;
            end
            if(j > size(Rcam,4)/2)
                Rcam(:,:,i,j) = R_est(:,:,2);
            else
                Rcam(:,:,i,j) = R_est(:,:,1);
            end
        end
    end
end