function rul = attack(agent, ball, aim)
    if (isState1(agent.z, ball.z) && ball.I)
        rul = MoveToWithRotation(agent, ball.z, ball.z, 1/1000, 20, 0, 2, 20, 0, 0, 0.1, false);
    else
        error_ang = errorAng(agent.z, ball.z, aim); 
        if (isState2(agent.z, ball.z, aim) && (~agent.isBallInside && isState3(agent.z, agent.ang, aim, 0.1)))
            %disp('st2');
            rul = goAroundPoint(agent, ball.z, 100, 1000 * sign(error_ang), 5, 20 + 8 * abs(error_ang)); 
        elseif (isState3(agent.z, agent.ang, aim, 0.015))
            %disp('st3');
            rul = MoveToWithRotation(agent, ball.z, aim, 0, 25, 0, 2, 9, 0, 0, 0.01, false);
        else
            %disp('st4');
            rul = MoveToWithRotation(agent, ball.z, aim, 0, 25, 0, 2, 9, 0, 0, 0.01, false);
            rul.AutoKick = 1;
        end
    end
end

% function rul = attack(agent, ball, aim, ballInside)
% if (isState1(agent.z, ball.z))
%         rul = MoveToWithRotation(agent, ball.z, ball.z, 1/1000, 20, 0, 2, 20, 0, 0, 0.1, false);
%     else
%         error_ang = errorAng(agent.z, ball.z, aim); 
%         if (isState2(agent.z, ball.z, aim))
%             rul = goAroundPoint(agent, ball.z, 200, 1000 * sign(error_ang), 5, 20 + 8 * abs(error_ang)); 
%         elseif (isState3(agent.z, agent.ang, aim))
%             rul = RotateToPID(agent, aim, 4, 10, 0, -30, 0.04, false);
%         elseif (~ballInside)
%             rul = MoveToWithRotation(agent, ball.z, aim, 0, 20, 0, 2, 15, 0, 0, 0.04, false);
%         else
%             rul = Crul(0, 0, 1, 0, 0);
%         end
% end
% end

%        global lastPos;
%     if isempty(lastPos)
%        lastPos = [0,0];
%     end
%     if (isState1(agent.z, ball.z)&& ball.I)
%         rul = MoveToWithRotation(agent, ball.z, ball.z, 1/1000, 20, 0, 2, 20, 0, 0, 0.03, false);
%         
%     else
%         error_ang = errorAng(agent.z, ball.z, aim); 
%         if (isState2(agent.z, ball.z, aim) && ball.I)
%             rul = goAroundPoint(agent, ball.z, 150, 1000 * sign(error_ang), 5, 20 + 8 * abs(error_ang)); 
%             
%         elseif (isState3(agent.z, agent.ang, aim) && ball.I)
%             rul = RotateToPID(agent, aim, 4, 10, 0, -30, 0.00, false);
%         elseif (~ballInside && ball.I)
%             rul = MoveToWithRotation(agent, ball.z, aim, 0, 20, 0, 2, 15, 0, 0, 0.03, false);
%         elseif ~ballInside && ~ball.I   
%             rul = MoveToWithRotation(agent, lastPos, aim, 0, 20, 0, 2, 15, 0, 0, 0.03, false);
%         else
%             rul = Crul(0, 0, 1, 0, 0);
%         end
%     end
%     if ball.I
%             lastPos = ball.z;
%         end

%     if (isState1(agent.z, ball.z))
%         rul = MoveToWithRotation(agent, ball.z, ball.z, 1/1000, 20, 0, 2, 20, 0, 0, 0.1, false);
%     else
%         error_ang = errorAng(agent.z, ball.z, aim); 
%         if (isState2(agent.z, ball.z, aim))
%             rul = goAroundPoint(agent, ball.z, 200, 1000 * sign(error_ang), 5, 20 + 8 * abs(error_ang)); 
%         elseif (isState3(agent.z, agent.ang, aim))
%             rul = RotateToPID(agent, aim, 4, 10, 0, -30, 0.04, false);
%         else
%             rul = MoveToWithRotation(agent, ball.z, aim, 0, 20, 0, 2, 15, 0, 0, 0.04, false);
%             if isState4(agent.z, agent.ang, ball.z)
%                 rul.kick = 1;
%             end
%         end
%     end

% ������ ������� � ����
function res = isState1(agent_pos, ball_pos)
    res = r_dist_points(agent_pos, ball_pos) > 250;
end

% �������� ������ ����� �� ������������
function res = isState2(agent_pos, ball_pos, aim)
    res = ((r_dist_point_line(ball_pos, agent_pos, aim) > 23) || (scalMult(aim - agent_pos, ball_pos - agent_pos) < 0));
end

% ������� �� ����
function res = isState3(agent_pos, agent_ang, aim, err) 
    v = agent_pos - aim;                              %vector to aim
    u = [-cos(agent_ang), -sin(agent_ang)];           %direction vector of the robot  
    angDifference = -r_angle_between_vectors(u, v);   %amount of angles to which robot should rotate 
    
    res = abs(angDifference) > err;
end


% ����������� � ������ (��������� ������� � ����)
function res = isState4(agent_pos, agent_ang, ball_pos)
    agent_dir = [cos(agent_ang), sin(agent_ang)];
    forward_center = agent_pos + 100 * agent_dir;
    res = scalMult(agent_pos - forward_center, ball_pos - forward_center) < 0;
end

% ��� �� ����������� �� ����� �������� � ����
function res = isState5(agent_pos, aim)
    v = agent_pos - aim;                              %vector to aim
    u = [-cos(agent_ang), -sin(agent_ang)];           %direction vector of the robot  
    angDifference = -r_angle_between_vectors(u, v);   %amount of angles to which robot should rotate 
    
    res = abs(angDifference) > 0.06;
end

function ang = errorAng(agent_pos, ball_pos, aim)
    wishV = aim - ball_pos;
    v = ball_pos - agent_pos;
    ang = r_angle_between_vectors(wishV, v);
end



% function rul = attack(agent, ball, aim, ballInside)
%     if (isState1(agent.z, ball.z))
%         rul = MoveToWithRotation(agent, ball.z, ball.z, 1/1000, 20, 0, 2, 20, 0, 0, 0.1, false);
%     else
%         error_ang = errorAng(agent.z, ball.z, aim); 
%         if (isState2(agent.z, ball.z, aim))
%             rul = goAroundPoint(agent, ball.z, 200, 1000 * sign(error_ang), 5, 20 + 8 * abs(error_ang)); 
%         elseif (isState3(agent.z, agent.ang, aim))
%             rul = RotateToPID(agent, aim, 4, 10, 0, -30, 0.04, false);
%         elseif (~ballInside)
%             rul = MoveToWithRotation(agent, ball.z, aim, 0, 20, 0, 2, 15, 0, 0, 0.04, false);
%         else
%             rul = Crul(0, 0, 1, 0, 0);
%         end
%     end

