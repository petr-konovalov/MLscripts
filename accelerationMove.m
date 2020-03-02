%agent - agent information structure
%agentH - history of robot position
%aimPoint - point to which robot is moving
%accReal - phisical robot acceleration
%initAcc - initial robot acceleration (in program)

function rul = accelerationMove(agent, agentH, aimPoint, accReal, initAcc)
    persistent correction;
    persistent oldSpeedAbs;
    if isempty(correction) || nargin == 0
        correction = zeros(1, 12);
    end
    if isempty(oldSpeedAbs) || nargin == 0
        oldSpeedAbs = zeros(1, 12);
    end
    
    if nargin > 0
        v = aimPoint - [agent.x, agent.y];     %vector to aim
        u = [cos(agent.ang), sin(agent.ang)];  %direction vector of the robot
        dist = sqrt(v(1)^2+v(2)^2);            %distance from robot to aim
        v = v / dist;

        SpeedY = -v(2)*u(1)+v(1)*u(2);          %speed on axis X 
        SpeedX = +v(1)*u(1)+v(2)*u(2);          %speed on axis Y

        T1 = agentH(1, 1) - agentH(2, 1);
        T2 = agentH(2, 1) - agentH(3, 1);
        curT = cputime();
        if curT - agentH(3, 1) > 0.4
            SpeedAbs = oldSpeedAbs(agent.id) + initAcc * T1;
        elseif curT - agentH(1, 1) > 0.01
            SpeedAbs = oldSpeedAbs(agent.id);
        else
            T = (T1 + T2) / 2;
            V = norm(agentH(1, [2, 3]) - agentH(2, [2, 3])) / (T1 * 1000);
            oldV = norm(agentH(2, [2, 3]) - agentH(3, [2, 3])) / (T2 * 1000);
            A = (V - oldV) / T;
            correction(agent.id) = correction(agent.id) + oldSpeedAbs(agent.id) / V * (accReal - A);
            SpeedAbs = max(0, oldSpeedAbs(agent.id) + initAcc * T1);
            fprintf('V: %f oV: %f A: %f Corr: %f cf: %f', V, oldV, A, correction(agent.id), oldSpeedAbs(agent.id) / V * (accReal - A));
        end
        oldSpeedAbs(agent.id) = SpeedAbs;
        
        Speed = [SpeedAbs*SpeedX, SpeedAbs*SpeedY];
        rul = Crul(Speed(1), Speed(2), 0, 0, 0);   
    else
        rul = Crul(0, 0, 0, 0, 0);
    end
end