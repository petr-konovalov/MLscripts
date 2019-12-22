%sd - ������� �� ������� ������ (1 ��� 2)
%coms(side) - ������� �� ������� ������ coms(3 - side) - ������ �������
%������ ��� ������ ������� ����� ���� ����������
%obst - ������������ � ������� ��������
%goals(side) - ����� ����� ����� obst(3 - side) - ������
%Vs(side) - ����������� ����� ����� Vs(3 - side) - ������
%field(1) - ����� ������ ���� ����, field(2) - ������ �������

function ruls = gameModel(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY)
    ruls = getEmptyRuls(size(coms, 2));
    %������������ ����
    activeId = getAttacker(coms(sd, :), ball);
    passiveId = 3 - activeId;
    os = 3-sd;
    lD = (sd-1)*size(coms,2) + 1;
    rD = lD + size(coms, 2) - 1;
    
    %����������� ����������
    if ballInGameZone(ball, field)
        ruls(activeId) = activeAttackRole(coms(sd, activeId), ball, coms(os, :), obsts(lD:rD, :), goals(os, :), Vs(os, :));
        ruls(passiveId) = passiveAttackRole(coms(sd, passiveId), ball, goals(os, :), Vs(os, :));
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
    ownerDist = 500;
    
    %���� ����� ������ ������� �� �������, �� ����
    if checkDir(dir, ball, oppObst, oppG, oppV) && agent.isBallInside
        rul = Crul(0, 0, 1, 0, 0);
    else
        [ownerId, own] = getBallOppOwner(ball, oppCom, ownerDist);
        %���� �����-�� ����� ���������� ������� ������ ����������� � ����
        %�� ����������� �������� ��������� ����, ����� �����������
        %��������� �� �������� � ������������ ��� ����� �� �������
        if own
            rul = stealBall(agent, ball.z, oppCom(ownerId), oppObst);
        else
            if r_dist_points(agent.z, ball.z) < ownerDist
                %����� �������� �������� ����� ������� ��������
                rul = optDirGoalAttack(agent, ball, oppCom, oppG, oppV);
            else
                rul = MoveToWithFastBuildPath(agent, ball.z, 0, oppObst);
            end
        end
    end
end

function rul = passiveAttackRole(agent, ball, oppG, oppV)
    %��������
    rul = Crul(0, 0, 0, 0, 0);
end

function res = ballInGameZone(ball, field)
    res = field(1, 1) <= ball.x && ball.x <= field(2, 1) && ...
        field(1, 2) <= ball.y && ball.y <= field(2, 2);
end

function res = checkDir(dir, ball, oppObst, oppG, oppV)
    v = 300; %������ �����
    R = 100; %������ �������
    k = 2;   %�������� ���� ������� �� �������� ������
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
    res = res && attackDirectQuality(dir, ball.z, oppObst, R, k) < 0;
end

function [res, own] = getBallOppOwner(ball, oppCom, ownerDist)
    res = 1;
    dst = r_dist_points(ball.z, oppCom(1).z);
    for k = 2: size(oppCom, 1)
        curDst = r_dist_points(ball.z, oppCom(k).z);
        if curDst < dst
            dst = curDst;
            res = k;
        end
    end
    own = dst < ownerDist;
end

function ruls = getEmptyRuls(comSize)
    ruls(comSize, 1) = Crul(0, 0, 0, 0, 0);
    for k = 1: comSize
        ruls(k) = Crul(0, 0, 0, 0, 0);
    end
end
