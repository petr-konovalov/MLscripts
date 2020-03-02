function rul = moveWithBall(agent, ball, aim)
    if (isState1(agent.z, ball.z))
        %disp('st1')
        rul = MoveToWithRotation(agent, ball.z, ball.z, 1/1000, 20, 0, 2, 20, 0, 0, 0.1, false);
    else
        %disp('pepa');
        error_ang = errorAng(agent.z, ball.z, aim); 
        if (isState2(agent.z, ball.z, aim) && ~agent.isBallInside)
            %disp('kuku');
            rul = goAroundPoint(agent, ball.z, 80, 1000 * sign(error_ang), 5, 25 + 5 * abs(error_ang)); 
        else
            %disp('kek');
            rul = MoveToWithRotation(agent, aim, aim, 0, 25, 200, 3, 15, 0, 0, 0.05, false);
        end
    end
end

function res = isState1(agent_pos, ball_pos)
    res = r_dist_points(agent_pos, ball_pos) > 400;
end

% Вращение вокруг точки до прицеливания
function res = isState2(agent_pos, ball_pos, aim)
    res = ((r_dist_point_line(ball_pos, agent_pos, aim) > 35) || (scalMult(aim - agent_pos, ball_pos - agent_pos) < 0));
end

% Доворот до цели
function res = isState3(agent_pos, agent_ang, aim) 
    v = agent_pos - aim;                              %vector to aim
    u = [-cos(agent_ang), -sin(agent_ang)];           %direction vector of the robot  
    angDifference = -r_angle_between_vectors(u, v);   %amount of angles to which robot should rotate 
    
    res = abs(angDifference) > 0.1;
end

function ang = errorAng(agent_pos, ball_pos, aim)
    wishV = aim - ball_pos;
    v = ball_pos - agent_pos;
    ang = r_angle_between_vectors(wishV, v);
end