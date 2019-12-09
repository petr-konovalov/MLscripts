function rul = MoveToWithFBPPlusParam(agent, aimPoint, aimVicinity, obstacles)
    step = 100;
    NormalSpeed = 30;
    infinity = 1000000;
    minSpeed = 10;
    minMovement = 100;
    coef = 2/750;

    
    [obst, ~] = getNearestObstacle(agent.z, obstacles);
    agentPos = agent.z;
    
    %{
        если робот оказался внутри препятсвия
        (например из-за погрешностей камеры или просто немного не вырулил)
        чтобы алгоритм расчёта маршрута сработал нормально, считаем маршрут
        не от робота, а от точки которая находится рядом с препятствием
    %}
    if isObstaclePoint(agentPos, [obstacles(obst, 1), obstacles(obst, 2)], obstacles(obst, 3))
        agentPos = getPointOutOfObstacle(agentPos, [obstacles(obst, 1), obstacles(obst, 2)], obstacles(obst, 3), 10);
    end
    
    if r_dist_points(agent.z, aimPoint) < aimVicinity
        rul = Crul(0, 0, 0, 0, 0);
        %{
    elseif ~CheckIntersect([agent.x, agent.y], aimPoint, obstacles)
        rul = MoveToLinear(agent, aimPoint, 0, NormalSpeed, 0);
        %}
    else
        path = fastBuildPath(agentPos, aimPoint, obstacles, step, 0);
        if path.size() > 2
            path = pathOptimize(path, obstacles);
        end
        
        if (~path.isEmpty())
            path.pop();
            point = path.getFirst();
            rul = MoveToLinear(agent, [point(1), point(2)], 0, NormalSpeed, 0);
        else
            rul = Crul(0, 0, 0, 0, 0);
        end
    end
end

function [res] = isObstaclePoint(point, obstCenter, obstRadius)
    res = r_dist_points(point, obstCenter) < obstRadius;
end

function [res] = getPointOutOfObstacle(point, obstCenter, obstRadius, step)
    vect = point - obstCenter;
    vect = vect / sqrt(vect(1) ^ 2 + vect(2) ^ 2) * (step + obstRadius * sign(step));
    res = obstCenter + vect;
end
