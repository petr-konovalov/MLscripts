function rul = GoalKeeperOnLine(agent, G, V, BPosHX, BPosHY, ballStanding, ballSpeed, v)
    if nargin == 7
        v = 650;
    end
    eps = 50;
    %minBallSpeed = 0.5;
    %historyLength = 8;
    hPoly = 3;
    hLen = size(BPosHX, 2);
    BPos = [BPosHX(hLen), BPosHY(hLen)];

    if (~ballStanding && dot(V, BPos - G) >= 0 && dot(V, ballSpeed) < 0)
        p = polyfit(BPosHX(hLen - hPoly: hLen), BPosHY(hLen - hPoly: hLen), 1);
        [x, y] = getPointForGoalkeeper([0, p(2)], [1, p(1) + p(2)], G, V);
        if (r_dist_points([x, y], G) <= v + eps)
           %rul = MoveToPD(agent, [x, y], 50, 1/750, 0, 60);
           rul = MoveToConstAcc(agent, [x, y], 0, 40);
        else
           rul = RotateToLinear(agent, BPos, 2, 20, 0.05);
        end
    else
        %rul = MoveToPD(agent, G, 15, 2/750, 0, 50);
        rul = MoveToConstAcc(agent, G+[0 1]*max(-v, min(v, BPos(2)/3)), 0, 40);
        rotRul = RotateToLinear(agent, BPos, 2, 20, 0.05);
        rul.SpeedR = rotRul.SpeedR;
    end
end
