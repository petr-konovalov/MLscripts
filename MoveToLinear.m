%MoveToLinear calculate the velocity vector nessary for the robot to move
%from its current positoin to destination point, wherein the speed magnitude
%have linearly depends on the distance

%agent - robot information structure
%aimPoint - point to which robot is moving
%coef - linear velocity coefficient
%minSpeed - minimal speed

function [rul] = MoveToLinear(agent, aimPoint, coef, minSpeed, vicinity)
    %function which show linear influence of distance to speed
    function [Speed] = linearSpeedFunction(dist)
        speedCoef = 60;
        if (dist > vicinity)
            Speed = minSpeed + speedCoef * coef * dist;
        else
            Speed = 0;
        end
    end

    Speed = MoveTo(agent, aimPoint, @linearSpeedFunction);
    rul = Crul(Speed(1), Speed(2), 0, 0, 0);
end

