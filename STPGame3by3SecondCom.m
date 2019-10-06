function [first_rul, second_rul, third_rul] = STPGame3by3SecondCom(ball, BPosHX, BPosHY, ballFastMoving, ballSaveDir, own, opp, ownG, oppG, ownV, oppV, ballInside, obstacles)
    first_rul = Crul(0, 0, 0, 0, 0);
    second_rul = Crul(0, 0, 0, 0, 0);
    third_rul = Crul(0, 0, 0, 0, 0);
    [ownerCmd, ownerId] = getBallOwner(ballFastMoving, ballSaveDir, ball, own, opp, ownG, oppG);
    
    switch ownerCmd
        case 1
            %disp('AttackGame');
            [first_rul, second_rul, third_rul] = attackGame(ownerId, ballFastMoving, ball, own, opp, ownG, oppG, ownV, oppV, ballInside, obstacles);
        case 2
            %disp('defenceGame');
            [first_rul, second_rul, third_rul] = defenceGame(ownerId, ballFastMoving, BPosHX, BPosHY, ball, own, opp, ownG, oppG, ownV, oppV, ballInside, obstacles);
        case -1
            %disp('neutralGame');
            [first_rul, second_rul, third_rul] = neutralGame(ball, own, opp, ownG, oppG, ownV, oppV, ballInside, obstacles);
    end
end

    function [frul, srul, trul] = attackGame(ownerId, ballFastMoving, ball, own, opp, ownG, oppG, ownV, oppV, ballInside, obstacles)
    frul = GoalKeeperOnLine(own(1), ball, ownG, ownV, obstacles);
    srul = Crul(0, 0, 0, 0, 0);
    trul = Crul(0, 0, 0, 0, 0);
     %trul = Crul(0, 0, 0, 30, 0);
    if (ownerId == 2)
        if ~ballFastMoving
            srul = optDirGoalAttack(own(2), ball, opp, oppG, oppV, ballInside);
            trul = defence(own(3), opp(2), ownG, obstacles);
        else
            srul = optDirGoalAttack(own(2), ball, opp, oppG, oppV, ballInside);
            %trul = defence(own(3), opp(2), ownG, obstacles);
            trul = Crul(0, 0, 0, 30, 0);
        end
    elseif ownerId == 3
        if ~ballFastMoving
            srul = defence(own(2), opp(2), ownG, obstacles);
            trul = optDirGoalAttack(own(3), ball, opp, oppG, oppV, ballInside);
        else
            trul = optDirGoalAttack(own(3), ball, opp, oppG, oppV, ballInside);
            %srul = defence(own(2), opp(2), ownG, obstacles);
        end    
    else
            P = 4/750;
            D = -1.5;
            vicinity = 50;
            minSpeed = 15;
            point = (ownG + oppG) / 2;
            
        if  norm(own(2).z - point) < norm(own(3).z - point)
            if ~ballFastMoving           
                frul = distAttack(own(1), ball, point, ballInside);
                %srul = MoveToPD(own(2), point, minSpeed, P, D, vicinity);
                srul = MoveToWithFBPPlusParam(own(2), point, vicinity, obstacles);
                trul = defence(own(3), opp(2), ownG, obstacles);
            else
                %srul = MoveToPD(own(2), point, minSpeed, P, D, vicinity);
                srul = MoveToWithFBPPlusParam(own(2), point, vicinity, obstacles);
                trul = defence(own(3), opp(2), ownG, obstacles);
            end
        else
            if ~ballFastMoving  
                frul = distAttack(own(1), ball, point, ballInside);
                srul = defence(own(2), opp(2), ownG, obstacles);
                %trul = MoveToPD(own(3), point, minSpeed, P, D, vicinity);
                trul = MoveToWithFBPPlusParam(own(3), point, vicinity, obstacles);
            else
                srul = defence(own(2), opp(2), ownG, obstacles);
                %trul = MoveToPD(own(3), point, minSpeed, P, D, vicinity);
                trul = MoveToWithFBPPlusParam(own(3), point, vicinity, obstacles);
            end
        end
    end
    end

function [frul, srul, trul] = defenceGame(ownerId, ballFastMoving, BPosHX, BPosHY, ball, own, opp, ownG, oppG, ownV, oppV, ballInside, obstacles)
    frul = GoalKeeperOnLine(own(1), ball, ownG, ownV, obstacles);
    if ~ballFastMoving
        srul = defence(own(2), opp(2), ownG, obstacles);
        trul = Crul(0,0,0,0,0);
    else
        if  norm(own(2).z - ball) < norm(own(3).z - ball)
            srul = receiveBall(own(2), BPosHX, BPosHY, obstacles);
            trul = defence(own(3), opp(2), ownG, obstacles);
        else
            srul = defence(own(2), opp(2), ownG, obstacles);
            trul = receiveBall(own(3), BPosHX, BPosHY, obstacles);
        end
    end
end

function [frul, srul, trul] = neutralGame(ball, own, opp, ownG, oppG, ownV, oppV, ballInside, obstacles)
    frul = GoalKeeperOnLine(own(1), ball, ownG, ownV, obstacles);
    srul = optDirGoalAttack(own(2), ball, opp, oppG, oppV, ballInside);
    trul = defence(own(3), opp(2), ownG, obstacles);
end

function [rul] = defence(agent, oppAttacker, G, obstacles)
    minSpeed = 15;
    P = 4/750;
    D = -1.5;
    vicinity = 50;
    koef = 0.8;
    point = (oppAttacker.z - G) * koef + G;
    %rul = MoveToPD(agent, point, minSpeed, P, D, vicinity);
    rul = MoveToWithFBPPlusParam(agent, point, vicinity, obstacles);
end

% 
% function res = checkBadBallZone(ball)
%     lX = -300;
%     rX = 300;
%     res = lX <= ball.x && ball.x <= rX;
% end


% function [dist, id] = calcBallCmdDist(ball, cmd)
%     dist = r_dist_points(ball.z, cmd(1).z);
%     id = 1;
%     for k = 2: numel(cmd)
%         curDist = r_dist_points(ball.z, cmd(k).z);
%         if (curDist <= dist)
%             dist = curDist;
%             id = k;
%         end
%     end
% end