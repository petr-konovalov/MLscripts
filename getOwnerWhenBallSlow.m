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
    goalKeeperArea = 900;
    res = r_dist_points(ball.z, G) < goalKeeperArea;
end


