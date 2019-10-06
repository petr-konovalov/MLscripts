function res = ballInsideEmulation(agents, ball)
    res = false;
    for k = 1: numel(agents)
        res = res || robotBallInsideEmulation(agents(k).z, agents(k).ang, ball.z);
    end
end
