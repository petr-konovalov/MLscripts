function [rul] = RotateToPD(agent, aimPoint, minAngularSpeed, P, D, eps)    
    function [angSpeed] = PIDAngFunction(angDiff)
        persistent oldAngDiff;
        persistent oldT;
        persistent oldAngSpeed;
        
        if isempty(oldAngDiff)
            oldAngDiff = zeros(1, 12);
        end
        
        if isempty(oldT)
            oldT = zeros(1, 12);
        end
        
        if isempty(oldAngSpeed)
            oldAngSpeed = zeros(1, 12);
        end
        curT = cputime();
        dT = curT - oldT(agent.id);
        
        if dT == 0
            angSpeed = oldAngSpeed(agent.id);
        elseif abs(angDiff) > eps
            angSpeed = sign(angDiff) * minAngularSpeed + angDiff * P + (oldAngDiff(agent.id) - angDiff) * D / dT;
        else
            angSpeed = 0;
        end
        
        disp(angSpeed);
        oldAngDiff(agent.id) = angDiff;
        oldT(agent.id) = curT;
        oldAngSpeed(agent.id) = angSpeed;
    end

    rul = Crul(0, 0, 0, RotateTo(agent, aimPoint, @PIDAngFunction), 0);
end

