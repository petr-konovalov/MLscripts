function [rul] = RotateToPD(agent, aimPoint, minAngularSpeed, P, D, eps)    
    function [angSpeed] = PIDAngFunction(angDiff)
        persistent oldAngDiff;
        persistent oldT;
        persistent oldAngSpeed;
        
        resetTime = 0.5;
        minReactionTime = 0.05;
        if isempty(oldT)
            oldT = zeros(1, 12);
        end
        curT = cputime();
        dT = curT - oldT(agent.id);
        
        if isempty(oldAngDiff) || dT > resetTime
            oldAngDiff = zeros(1, 12);
        end
        
        if isempty(oldAngSpeed) || dT > resetTime
            oldAngSpeed = zeros(1, 12);
        end
        
        if dT < minReactionTime
            angSpeed = oldAngSpeed(agent.id);
        else
            if abs(angDiff) > eps
                angSpeed = sign(angDiff) * minAngularSpeed + angDiff * P + (oldAngDiff(agent.id) - angDiff) * D / dT;
            else
                angSpeed = 0;
            end

            oldAngDiff(agent.id) = angDiff;
            oldT(agent.id) = curT;
            oldAngSpeed(agent.id) = angSpeed;
        end
    end

    rul = Crul(0, 0, 0, RotateTo(agent, aimPoint, @PIDAngFunction), 0);
end

