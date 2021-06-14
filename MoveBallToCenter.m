function ruls = MoveBallToCenter(agents, ball, center, vicinity, obstacles)
    ruls = getEmptyRuls(size(agents, 2));
    if r_dist_points(ball.z, center) > vicinity
        idNearest = getNearestAgent(agents, ball);
        ruls(idNearest) = moveWithBall(agents(idNearest), ball, center);
        for k = [1: idNearest-1, idNearest+1:size(agents, 2)]
            aimPnt = getOutOfLinePnt(agents(k).z, ball.z, center);
            ruls(k) = MoveToWithFastBuildPath(agents(k), aimPnt, 50, obstacles);
        end
    end
end

function id = getNearestAgent(agents, ball)
    id = 1;
    dst = r_dist_points(agents(1).z, ball.z);
    for k = 2: size(agents, 2)
        curDst = r_dist_points(agents(k).z, ball.z);
        if curDst < dst
            dst = curDst;
            id = k;
        end
    end
end

function res = getOutOfLinePnt(pnt, A, B)
    npnt = getNearestPntToLine(pnt, A, B);
    vec = pnt - npnt;
    vec = vec / norm(vec);
    res = npnt + vec * 300;
end
