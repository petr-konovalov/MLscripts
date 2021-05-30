%agent - robot info
%aimPoint - point to which robot is moving
%coef - linear velocity coefficient
%minSpeed - minimal speed

function [rul] = MoveToConstAcc(agent, aimPoint, goalSpeed, vicinity, maxSpeed, acc)
    if nargin <= 4
    	maxSpeed = 100;
    end
    if nargin <= 5
    	acc = 1.5;
    end
    function [Speed] = linearSpeedFunction(dist)
        if (dist > vicinity)
            Speed = min(goalSpeed + 20*sqrt(2*acc*dist/1000), maxSpeed);
        else
            Speed = 0;
        end
    end

    Speed = MoveTo(agent, aimPoint, @linearSpeedFunction);
    rul = Crul(Speed(1), Speed(2), 0, 0, 0);
end

