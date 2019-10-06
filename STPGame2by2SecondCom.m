function [frul, srul] = STPGame2by2FirstCom(ball, BPosHX, BPosHY, ballFastMoving, ballSaveDir, ballStanding, ballSpeed, own, opp, ownG, oppG, ownV, oppV)
    frul = Crul(0, 0, 0, 0, 0);
    srul = Crul(0, 0, 0, 0, 0);
    [ownerCmd, ownerId] = getBallOwner(ballFastMoving, ballSaveDir, ball, own, opp, ownG, oppG);
    
    switch ownerCmd
        case 1
            %disp('SAttackGame');
            [frul, srul] = attackGame(ownerId, ballFastMoving, ballStanding, ballSpeed, BPosHX, BPosHY, ball, own, opp, ownG, oppG, ownV, oppV);
        case 2
            %disp('SdefenceGame');
            [frul, srul] = defenceGame(ballFastMoving, ballStanding, ballSpeed, BPosHX, BPosHY, own, opp, ownG, ownV);
        case -1
            %disp('SneutralGame');
            [frul, srul] = neutralGame(ball, ballStanding, ballSpeed, BPosHX, BPosHY, own, opp, ownG, oppG, ownV, oppV);
    end
end

function [frul, srul] = attackGame(ownerId, ballFastMoving, ballStanding, ballSpeed, BPosHX, BPosHY, ball, own, opp, ownG, oppG, ownV, oppV)
    frul = GoalKeeperOnLine(own(1), ownG, ownV, BPosHX, BPosHY, ballStanding, ballSpeed);
    srul = Crul(0, 0, 0, 0, 0);
    
    if (ownerId == 2)
        if ~ballFastMoving
            srul = optDirGoalAttack(own(2), ball, opp, oppG, oppV);
        end
    else
        if ~ballFastMoving
            minSpeed = 50;
            %P = 4/750;
            %D = -1.5;
            vicinity = 50;
            %frul = distAttack(own(1), ball, (ownG + oppG) / 2, own(1).isBallInside);
            frul = attack(own(1), ball, (ownG + oppG) / 2);
            srul = MoveToPD(own(2), (ownG +  oppG)/2 , minSpeed, 0, 0, vicinity);
        else
            %srul = distAttack(own(1), ball, (ownG + oppG) / 2, own(1).isBallInside);
            srul = receiveBall(own(2), BPosHX, BPosHY);
        end
    end
end

function [frul, srul] = defenceGame(ballFastMoving, ballStanding, ballSpeed, BPosHX, BPosHY, own, opp, ownG, ownV)
    frul = GoalKeeperOnLine(own(1), ownG, ownV, BPosHX, BPosHY, ballStanding, ballSpeed);
    if ~ballFastMoving
        srul = defenceGoalFor2by2(own(2), opp(2), ownG);
    else
        srul = receiveBall(own(2), BPosHX, BPosHY);
    end
end

function [frul, srul] = neutralGame(ball, ballStanding, ballSpeed, BPosHX, BPosHY, own, opp, ownG, oppG, ownV, oppV)
    frul = GoalKeeperOnLine(own(1), ownG, ownV, BPosHX, BPosHY, ballStanding, ballSpeed);
    %srul = optDirGoalAttack(own(2), ball, opp, oppG, oppV);
    srul = defenceGoalFor2by2(own(2), opp(2), ownG);
end

function [cmd, id] = getBallOwner(ballFastMoving, ballSaveDir, ball, own, opp, ownG, oppG)
    persistent prevOwnerCmd;
    persistent prevOwnerId;
    
    if (isempty(prevOwnerId) || isempty(prevOwnerCmd))
        %предыдущий владелец не определён
        prevOwnerCmd = -1;
        prevOwnerId = -1;
    end
    
    if ballFastMoving
        [cmd, id] = getOwnerWhenBallFast(ballSaveDir, prevOwnerCmd, prevOwnerId);
    else
        [cmd, id] = getOwnerWhenBallSlow(ball, own, opp, ownG, oppG);
    end
    
    prevOwnerCmd = cmd;
    prevOwnerId = id;
end

function res = checkBadBallZone(ball)
    lX = -300;
    rX = 300;
    res = lX <= ball.x && ball.x <= rX;
end

function [cmd, id] = getOwnerWhenBallFast(ballSaveDir, prevOwnerCmd, prevOwnerId)
    %если мяч при быстром движении сохраняет направление, то владельцем
    %считаем робота который владел мячом раньше, иначе вледец не
    %определён
    if (ballSaveDir)
        cmd = prevOwnerCmd;
        id = prevOwnerId;
    else
        cmd = -1;
        id = -1;
    end
        %{
    elseif prevOwnerCmd == -1
        cmd = -1;
        id = -1;
    else
        %дистанция необходимая для того, чтобы при отлёте мяча
        %установилось направление
        ownerDist = 500;
        if prevOwnerCmd == 1 && r_dist_points(own(prevOwnerId).z, ball.z) < ownerDist || prevOwnerCmd == 2 && r_dist_points(opp(prevOwnerId).z, ball.z) < ownerDist
            cmd = prevOwnerCmd;
            id = prevOwnerId;
        else
            cmd = -1;
            id = -1;
        end
    end
        %}
end

function [cmd, id] = getOwnerWhenBallSlow(ball, own, opp, ownG, oppG)
    %разница между расстояниями до мяча необходимая для определения
    %владельца
    distMinDiff = 200;
    %размер окрестности мяча (зоны владения) удобной для манипуляций с ним
    ballOwnerArea = 300;
    
    %проверка на вратарские зоны
    if checkGoalKeeperZone(ball, ownG)
        cmd = 1;
        id = 1;
    elseif checkGoalKeeperZone(ball, oppG)
        cmd = 2;
        id = 1;
    else
        [fDist, fOwner] = calcBallCmdDist(ball, own);
        [sDist, sOwner] = calcBallCmdDist(ball, opp);
        if fDist < ballOwnerArea && sDist < ballOwnerArea
            %если в зоне владения мяча есть роботы из разных команд то
            %владелец не определён
            cmd = -1;
            id = -1;
        %иначе проверяем обе команды по отдельности
        elseif fDist < ballOwnerArea
            cmd = 1;
            id = fOwner;
        elseif sDist < ballOwnerArea
            cmd = 2;
            id = sOwner;
        elseif abs(fDist - sDist) < distMinDiff
            %если расстояние до мяча команд отличаются не значительно то
            %вледелец не определён
            cmd = -1;
            id = -1;
            %иначе проверяем какая команда ближе
        elseif fDist < sDist
            cmd = 1;
            id = fOwner;
        else
            cmd = 2;
            id = sOwner;
        end
    end
end

function res = checkGoalKeeperZone(ball, G)
    goalKeeperArea = 500;
    res = r_dist_points(ball.z, G) < goalKeeperArea;
end

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
