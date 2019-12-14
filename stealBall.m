function rul = stealBall(agent, BPEstim, ballOwner, obstacles)
    bigDist = 160;
    smallDist = 110;
    takeWidth = 100;
    persistent pushDir;
    persistent spinSpeed;
    if (isempty(pushDir))
        pushDir = zeros(1, 20);
    end
    if (isempty(spinSpeed))
       spinSpeed = 15 * ones(1, 20);
    end
    agentDir = [cos(agent.ang), sin(agent.ang)];
    vec = BPEstim - ballOwner.z;
    vec = vec / norm(vec);
    if r_dist_points(BPEstim, agent.z) > bigDist || ~inHalfStrip(agent.z, ballOwner.z, vec, takeWidth)  
        pnt = BPEstim + vec * 150;
        rul = MoveToWithFastBuildPath(agent, pnt, 0, obstacles);
        rotRul = RotateToLinear(agent, BPEstim, 3, 10, 0.1);
        rul.SpeedR = rotRul.SpeedR;
    elseif inHalfStrip(ballOwner.z, agent.z, agentDir, takeWidth) || r_dist_points(BPEstim, ballOwner.z) < smallDist 
        %change pushing direction
        if ~agent.isBallInside
            rul = MoveToLinear(agent, BPEstim, 0, 15, 0);
            rotRul = RotateToLinear(agent, BPEstim, 3, 10, 0.1);
            rul.SpeedR = rotRul.SpeedR;
        else
            if randi(100) > 80
                pushDir(agent.id) = -1 - pushDir(agent.id);
                spinSpeed(agent.id) = randi(10) + 10;
            end
            rul = Crul(10, 10 * pushDir(agent.id), 0, spinSpeed(agent.id) * pushDir(agent.id), 0);
        end
    else
        %����� ���� ����� �������� ��������:
        %���� ��� ��������� ������� �� ���� ��� �� ����� �������, �� ������
        %rul = Crul(0, 0, 0, 0, 1);
        %����� ������ ������� ����� (����, �� ����� ����)
        rul = Crul(40, 0, 0, 0, 0);
    end
end

%required norm(SDir) == 1
function res = inHalfStrip(pnt, SCenter, SDir, SWidth)
    res = abs(vectMult(pnt - SCenter, SDir)) < SWidth &&  scalMult(pnt - SCenter, SDir) > 0;
end