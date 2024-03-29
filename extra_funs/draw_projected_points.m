function  draw_projected_points(q)
% draw_projected_points shows the points projected in each camera
% q(3,npoints,ncam) projected points in all cameras

    q = DeshomogeneizaCoords(q);
    ncam = size(q,3);
    for k=1:ncam
        figure();
        hold on
        scatter(q(1,:,k),q(2,:,k),30,[1,0,0]);
        % DibujaCuboProy(q(:,:,k));
        % scatter(q_est(1,:,k),q_est(2,:,k),30,[0,0,1]);
    end

end

