function rul = stealBall(agent, BPEstim, ballOwner, obstacles)
    bigDist = 160;
    smallDist = 100;
    if r_dist_points(BPEstim, agent.z) > bigDist
        vec = BPEstim - ballOwner.z;
        vec = vec / norm(vec);
        pnt = BPEstim + vec * 150;
        rul = MoveToWithFastBuildPath(agent, pnt, 0, obstacles);
        rotRul = RotateToLinear(agent, BPEstim, 3, 10, 0.1);
        rul.SpeedR = rotRul.SpeedR;
    elseif ~agent.isBallInside
        rul = MoveToLinear(agent, BPEstim, 0, 10, 0);
        rotRul = RotateToLinear(agent, BPEstim, 3, 10, 0.1);
        rul.SpeedR = rotRul.SpeedR;
    else
        rul = Crul(10, 10, 0, 5, 0);
    end
end