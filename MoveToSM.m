%move to sliding mode
%agent - robot information structure
%ac    - robot acceleration
%sr    - отношение ральной скорости робота (в м/с) к скорости в программе
%Здесь важно чтобы единицы измерения были согласованными
function rul = MoveToSM(agent, ac, sr, aimPoint, vicinity)
    %dist  - расстояние в метрах
    %Speed - модуль скорости в метрах в секунду 
    function [Speed] = SMSpeedFunction(dist)
        persistent oldT;
        persistent v;
        curT = cputime();
        if isempty(oldT)
            oldT = ones(1, 8) * curT;
        end
        if isempty(v)
            v = zeros(1, 8);
        end
        dT = curT - oldT(agent.id);
        
        if dist < vicinity
            Speed = 0;
        elseif v(agent.id) ^ 2 <= 2 * ac * dist
            Speed = min(v(agent.id) + dT * ac, 100 * sr);
        else
            Speed = max(v(agent.id) - dT * ac, 0);
        end
        
        v(agent.id) = Speed;
        oldT(agent.id) = curT;
    end
    
    Speed = MoveTo(agent, aimPoint, @(dist)(SMSpeedFunction(dist / 1000) / sr));
    rul = Crul(Speed(1), Speed(2), 0, 0, 0);
end