%sd - ������� �� ������� ������ (1 ��� 2)
%coms(side) - ������� �� ������� ������ coms(3 - side) - ������ �������
%������ ��� ������ ������� ����� ���� ����������
%obst - ������������ � ������� ��������
%goals(side) - ����� ����� ����� obst(3 - side) - ������
%Vs(side) - ����������� ����� ����� Vs(3 - side) - ������
%field(1) - ����� ������ ���� ����, field(2) - ������ �������

function ruls = gameModel(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY, status)
    ActiveStartStatus = 1;
    PassiveStartStatus = 2;
    GameProcStatus = 3;
    StopGameStatus = 4;
    
    switch status
        case ActiveStartStatus
            ruls = gameActiveStart(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY);
        case PassiveStartStatus
            ruls = gamePassiveStart(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY);
        case GameProcStatus
            ruls = gameProc(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY);
        case StopGameStatus
            ruls = getEmptyRuls(size(coms, 2));
    end
end

function ruls = gameActiveStart(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY)
   
end

function ruls = gamePassiveStart(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY)

end

function ruls = gameProc(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY)
    ruls = getEmptyRuls(size(coms, 2));
    %������������ ����
    activeId = getAttacker(coms(sd, :), ball);
    passiveId = 3 - activeId;
    os = 3-sd;
    oActiveId = (sd-1)*size(coms,2) + activeId; 
    lD = (os-1)*size(coms,2) + 1;
    rD = lD + size(coms, 2) - 1;
    %���������� ������� ���������� ����������
    height = abs(field(1, 1) - field(2, 1));
    width = abs(field(1, 2) - field(2, 2));
    rV = [Vs(sd, 2), -Vs(sd, 1)];
    if activeId == 1
        P = goals(sd, :) + Vs(sd, :) * height * 0.5 + rV * width * 0.4;
    else
        P = goals(sd, :) + Vs(sd, :) * height * 0.8 - rV * width * 0.4;
    end
    disp(P);
    %����������� ����������
    if ballInGameZone(ball, field)
        ruls(activeId) = activeAttackRole(coms(sd, activeId), ball, coms(os, :), obsts(lD:rD, :), goals(os, :), Vs(os, :));
        ruls(passiveId) = passiveAttackRole(coms(sd, passiveId), ball, goals(os, :), Vs(os, :), P, obsts([oActiveId, lD:rD], :));
    end
end

function res = getAttacker(com, ball)
    if (r_dist_points(com(1).z, ball.z) < r_dist_points(com(2).z, ball.z))
        res = 1;
    else
        res = 2;
    end
end

function rul = activeAttackRole(agent, ball, oppCom, oppObst, oppG, oppV)
    dir = [cos(agent.ang), sin(agent.ang)];
    smallDist = 150;
    ownerDist = 300;
    G = oppG - oppV * 400;
    
    %���� ����� ������ ������� �� �������, �� ����
    if checkDir(dir, ball, oppObst, G, oppV) && agent.isBallInside
        disp('shoot');
        rul = Crul(0, 0, 1, 0, 0);
    else
        [ownerId, own] = getBallOppOwner(ball, oppCom, ownerDist);
        %���� �����-�� ����� ���������� ������� ������ ����������� � ����
        %�� ����������� �������� ��������� ����, ����� �����������
        %��������� �� �������� � ������������ ��� ����� �� �������
        if own && inHalfPlane(oppCom(ownerId).z, agent.z, dir)
            disp('stealBall');
            rul = stealBall(agent, ball.z, oppCom(ownerId), oppObst);
        else
            disp('take aim');
            if r_dist_points(agent.z, ball.z) < ownerDist
                %����� �������� �������� ����� ������� ��������
                rul = optDirGoalAttack(agent, ball, oppCom, G, oppV);
            else
                rul = MoveToWithFastBuildPath(agent, ball.z, 0, oppObst);
                rotRul = RotateToLinear(agent, ball.z, 3, 10, 0.1);
                rul.SpeedR = rotRul.SpeedR;
            end
        end
    end
end

function rul = passiveAttackRole(agent, ball, oppG, oppV, P, obsts)
    %��������
    rul = MoveToWithFastBuildPath(agent, P, 100, obsts);
end

function res = ballInGameZone(ball, field)
    res = field(1, 1) <= ball.x && ball.x <= field(2, 1) && ...
        field(1, 2) <= ball.y && ball.y <= field(2, 2);
end

function res = checkDir(dir, ball, oppObst, oppG, oppV)
    v = 300; %������ �����
    R = 100; %������ �������
    k = 2.5;   %�������� ���� ������� �� �������� ������
    F = ball.z + dir * 100000;
    pnt = lineIntersect(ball.z, dir, oppG, [oppV(2), -oppV(1)]);
    res = r_dist_points(pnt, oppG) < v && scalMult(dir, pnt - ball.z) > 0;
    for k = 1: size(oppObst, 1)
        pnts = SegmentCircleIntersect(ball.x, ball.y, F(1), F(2), oppObst(k, 1), oppObst(k, 2), R);
        if numel(pnts) > 0
            res = false;
            break;
        end
    end
    disp(attackDirectQuality(dir, ball.z, oppObst, R, k));
    res = res && attackDirectQuality(dir, ball.z, oppObst, R, k) < 0;
end

function [res, own] = getBallOppOwner(ball, oppCom, ownerDist)
    res = 1;
    dst = r_dist_points(ball.z, oppCom(1).z);
    for k = 2: size(oppCom, 2)
        curDst = r_dist_points(ball.z, oppCom(k).z);
        if curDst < dst
            dst = curDst;
            res = k;
        end
    end
    own = dst < ownerDist;
end

function res = inHalfPlane(pnt, A, vec)
    res = scalMult(pnt - A, vec) > 0;
end

function ruls = getEmptyRuls(comSize)
    ruls(comSize, 1) = Crul(0, 0, 0, 0, 0);
    for k = 1: comSize
        ruls(k) = Crul(0, 0, 0, 0, 0);
    end
end
