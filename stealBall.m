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
    if r_dist_points(BPEstim, agent.z) > bigDist %|| ~inHalfStrip(agent.z, ballOwner.z, vec, takeWidth)  
        disp('MoveToBall');
        pnt = BPEstim + vec * 150;
        rul = MoveToWithFastBuildPath(agent, pnt, 0, obstacles);
        rotRul = RotateToLinear(agent, BPEstim, 3, 10, 0.1);
        rul.SpeedR = rotRul.SpeedR;
    elseif inHalfStrip(ballOwner.z, agent.z, agentDir, takeWidth) || r_dist_points(BPEstim, ballOwner.z) < smallDist 
        disp('state 2');
        %change pushing direction
        if r_dist_points(agent.z, BPEstim) > 120%~agent.isBallInside
            rul = MoveToLinear(agent, BPEstim, 0, 15, 0);
            rotRul = RotateToLinear(agent, BPEstim, 3, 10, 0.1);
            rul.SpeedR = rotRul.SpeedR;
        else
            if randi(100) > 85
                pushDir(agent.id) = -1 - pushDir(agent.id);
                spinSpeed(agent.id) = (randi(2) - 1) * 30 + 10;
            end
            rul = Crul(8, 8 * pushDir(agent.id), 0, spinSpeed(agent.id) * pushDir(agent.id), 0);
        end
    else
        disp('state 3');
        %Здесь надо будет добавить проверку:
        %Если нет опасности выпнуть из поля или по своим воротам, то пинаем
        %rul = Crul(0, 0, 0, 0, 1);
        %Иначе просто фигачим вперёд
        rul = Crul(15, 12 * pushDir(agent.id), 0, 2 * pushDir(agent.id), 0);
        rotRul = RotateToLinear(agent, BPEstim, 3, 10, 0.1);
        rul.SpeedR = rotRul.SpeedR;
    end
end