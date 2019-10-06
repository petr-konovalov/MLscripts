function [dist, id] = calcBallCmdDist(ball, cmd)
    dist = r_dist_points(ball.z, cmd(1).z);
    id = 1;
    for k = 2: numel(cmd)
        curDist = r_dist_points(ball.z, cmd(k).z);
        if (curDist <= dist)
            dist = curDist;
            id = k;
        end
    end
end