%agent - robot info
%aimPoint - point to which robot is moving
%SpeedFunction - function which characterize influence of distance to speed

%basic movements to the point
%agent - structure of robot state
%SpeedFunction - function of speed versus distance

function [Speed] = MoveTo(agent, aimPoint, SpeedFunction)
    %[agent.x, agent.y] - robot position
    %agent.ang - angle between robot axis and global reference system axis

    v = aimPoint - [agent.x, agent.y];     %vector to aim
    u = [cos(agent.ang), sin(agent.ang)];  %direction vector of the robot
    dist = sqrt(v(1)^2+v(2)^2);            %distance from robot to aim
    v = v / dist;
    
    SpeedAbs = SpeedFunction(dist);        %absolute value of speed
    SpeedY = -v(2)*u(1)+v(1)*u(2);          %speed on axis X 
    SpeedX = +v(1)*u(1)+v(2)*u(2);          %speed on axis Y
    
        %disp(dist);
    Speed = [SpeedAbs*SpeedX, SpeedAbs*SpeedY];
end

