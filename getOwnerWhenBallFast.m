function [cmd, id] = getOwnerWhenBallFast(ballSaveDir, prevOwnerCmd, prevOwnerId)
    %если м€ч при быстром движении сохран€ет направление, то владельцем
    %считаем робота который владел м€чом раньше, иначе вледец не
    %определЄн
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
        %дистанци€ необходима€ дл€ того, чтобы при отлЄте м€ча
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