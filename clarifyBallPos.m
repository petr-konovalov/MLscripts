function res = clarifyBallPos(agents, BPEstim)
    res = BPEstim;
    for agent = agents
        if agent.isBallInside
            aDir = [cos(agent.ang), sin(agent.ang)];
            res = agent.z + aDir * 90;
        end
    end
end