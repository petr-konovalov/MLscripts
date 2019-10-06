function res = robotBallInsideEmulation(agent_pos, agent_ang, ball_pos)
    agent_dir = [cos(agent_ang), sin(agent_ang)];
    attackDist = 102;
    forward_center = agent_pos + attackDist * agent_dir;
    ballVect = forward_center - ball_pos;
    sMult = scalMult(-agent_dir, ballVect);
    vMult = vectMult(-agent_dir, ballVect);
    res = -50 < sMult && sMult < 0 && abs(vMult) < 50;
end