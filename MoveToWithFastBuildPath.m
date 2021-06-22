function rul = MoveToWithFastBuildPath(agent, aimPoint, aimVicinity, obstacles, NormalSpeed, minSpeed)
    step = 300; %�������� ��������� ���������� ��������, ������� ���������� ������ �� �����������
    infinity = 1000000; %������ �������������
    zeroSpeedThreshold = 500;
    
    if nargin <= 4
        NormalSpeed = 100; %�������� ���������� �������
    end
    
    if nargin <= 5
    	minSpeed = 10;
    end
    %��������� ��� ����� ������ ��������� ��������
    %minSpeed = 10; 
    %minMovement = 100;
    %coef = 2/750;
    NormalSpeed = min(NormalSpeed, 70);
    %��������� ����������� ������� ���� ��� �����
    ownObst = getOwnObst(agent.z, obstacles);
    %disp([agent.id, ownObst]);
    obstacles = obstacles([1:ownObst-1, ownObst+1:size(obstacles, 1)], :);
    
    %���� ��������� ����������� � ������ � � ����
    [obst, ~] = getNearestObstacle(agent.z, obstacles);
    [obstAim, ~] = getNearestObstacle(aimPoint, obstacles);
    agentPos = agent.z;
    
    %{
        ���� ����� ��� ���� ��������� ������ ����������
        (�������� ��-�� ������������ ������ ��� ������ ������� �� �������)
        ����� �������� ������� �������� �������� ���������, ������� �������
        �� �� ������, � �� ����� ������� ��������� ����� � ������������
    %}
    if isObstaclePoint(agentPos, [obstacles(obst, 1), obstacles(obst, 2)], obstacles(obst, 3))
        agentPos = getPointOutOfObstacle(agentPos, [obstacles(obst, 1), obstacles(obst, 2)], obstacles(obst, 3), 10);
    end
    if isObstaclePoint(aimPoint, [obstacles(obstAim, 1), obstacles(obstAim, 2)], obstacles(obstAim, 3))
        aimPoint = getPointOutOfObstacle(aimPoint, [obstacles(obstAim, 1), obstacles(obstAim, 2)], obstacles(obstAim, 3), 10);
    end
    %disp([agent.id, aimPoint]);
    
    if r_dist_points(agent.z, aimPoint) < aimVicinity
        rul = Crul(0, 0, 0, 0, 0);
    else
        % �������� ��� ���� (������� ���������� � ��������� ������)
        firstPath = fastBuildPath(agentPos, aimPoint, obstacles, -step, 0);
        secondPath = fastBuildPath(agentPos, aimPoint, obstacles, step, 0);
        %������� ������ ������������� ����� ��������
        if firstPath.size() > 2
            firstPath = pathOptimize(firstPath, obstacles);
        end
        if secondPath.size() > 2
            secondPath = pathOptimize(secondPath, obstacles);
        end
        
        firstLength = 0;
        if (~firstPath.isEmpty())
            prevPnt = firstPath.pop();
            firstPoint = firstPath.getFirst();
            % ��������� ����� ������� ��������
            while ~firstPath.isEmpty()
                firstLength = firstLength + r_dist_points(prevPnt, firstPath.getFirst());
                prevPnt = firstPath.pop();
            end
        else
            firstLength = infinity;
        end
        
        secondLength = 0;
        if (~secondPath.isEmpty())
            prevPnt = secondPath.pop();
            secondPoint = secondPath.getFirst();
            % ��������� ����� ������� �������
            while ~secondPath.isEmpty()
                secondLength = secondLength + r_dist_points(prevPnt, secondPath.getFirst());
                prevPnt = secondPath.pop();
            end
        else
            secondLength = infinity;
        end
    
        if (firstLength ~= infinity || secondLength ~= infinity)
            if (firstLength < secondLength)
                point = [firstPoint(1), firstPoint(2)];
            else
                point = [secondPoint(1), secondPoint(2)];
            end
            goalSpeed = minSpeed;
            if norm(point - aimPoint) < zeroSpeedThreshold
            	goalSpeed = 0;
           	end
            rul = MoveToConstAcc(agent, point, goalSpeed, aimVicinity, NormalSpeed);
        else
            rul = Crul(0, 0, 0, 0, 0);  
        end
    end
end

%���������� ����� ����������� ������� �������� ��� �����
function [res] = getOwnObst(agentPos, obstacles)
    res = 0;
    OwnR = 40;
    for k = 1: size(obstacles, 1)
        if r_dist_points(agentPos, obstacles(k, [1, 2])) < OwnR
            res = k;
        end
    end
end

%��������� ����������� �� ����� ���������� � �������� ������� � ��������
function [res] = isObstaclePoint(point, obstCenter, obstRadius)
    res = r_dist_points(point, obstCenter) <= obstRadius;
end

%���������� ����� ������� ��� ���������� � �������� ������� (obstCenter) 
%� �������� (obstRadius) � ������� �� ���� ���������� �� ������ ���������� 
%� ����������� �������� ����� (point). �������� step ���������� ����������
%������������ ����� �� �������� ����������
function [res] = getPointOutOfObstacle(point, obstCenter, obstRadius, step)
    vect = point - obstCenter; 
    vect = vect / sqrt(vect(1) ^ 2 + vect(2) ^ 2) * (step + obstRadius * sign(step));
    res = obstCenter + vect;
end
