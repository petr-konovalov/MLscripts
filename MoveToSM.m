%move to sliding mode
%agent - robot information structure
%w     - robot acceleration
%����� ����� ����� ������� ��������� ���� ��������������
function rul = MoveToSM(agent, w, aimPoint, Vmax, vicinity)
    function [Speed] = SMSpeedFunction(dist)
        persistent oldT;
        persistent v;
        curT = cputime();
        if isempty(oldT)
            oldT = curT;
        end
        if isempty(v)
            v = 0;
        end
        dT = curT - oldT;
        
        if dist < vicinity
            Speed = 0;
        % ������� ���� �� �������� ��-�� ����, ��� v w � �������� a dist �
        % �����������
        elseif v ^ 2 <= 2 * w * dist
            Speed = min(v + dT * w, Vmax);
        else
            Speed = max(v - dT * w, 0);
        end
        
        disp(v);
        v = Speed;
        oldT = curT;
    end
    
    Speed = MoveTo(agent, aimPoint, @SMSpeedFunction);
    rul = Crul(Speed(1), Speed(2), 0, 0, 0);
end