%sd - сторона за которую играет (1 или 2)
%coms(side) - команда за которую играет coms(3 - side) - другая комнада
%первые два игрока команды должы быть атакующими
%obst - расположение и радиусы объектов
%goals(side) - центр наших ворот obst(3 - side) - других
%Vs(side) - направление наших ворот Vs(3 - side) - других
%field(1) - левый нижний угол поля, field(2) - правый верхний

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
    %один робот едет на центр и фигачит по центру верним ударом, другой
    %где-то позади становится
    oppV = Vs(3 - sd, :);
    id = (sd-1)*size(coms,2) + 1; 
    if inHalfStrip(coms(sd, 1).z, ball.z, oppV, 30)
        ruls(1) = MoveToLinear(coms(sd, 1), ball.z, 0, 25, 0);
    else
        ruls(1) = MoveToWithFastBuildPath(coms(sd, 1), ball.z + oppV * 200, 0, obsts([1:id-1, id+1:size(obsts, 1)], :)); 
    end
    rotRul = RotateToLinear(coms(sd, 1), ball.z, 3, 10, 0.1);
    ruls(1).SpeedR = rotRul.SpeedR;
    ruls(1).AutoKick = 2;
    
    ruls(2) = MoveToWithFastBuildPath(coms(sd, 2), ball.z + oppV * 500, 50, obsts([1:id, id+2: size(obsts, 1)], :));
    rotRul = RotateToLinear(coms(sd, 2), ball.z, 3, 10, 0.1);
    ruls(2).SpeedR = rotRul.SpeedR;
end

function ruls = gamePassiveStart(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY)
    oppV = Vs(3 - sd, :);
    id = (sd-1)*size(coms,2) + 1;
    pnt = ball.z + oppV * 600;
    pntL = pnt + [oppV(2), -oppV(1)] * 70;
    pntR = pnt - [oppV(2), -oppV(1)] * 70;
    bigDist = 300;
    if r_dist_points(coms(sd, 1).z, pnt) > bigDist || r_dist_points(coms(sd, 2).z, pnt) > bigDist
        ruls(1) = MoveToWithFastBuildPath(coms(sd, 1), pnt, 0, obsts([1:id-1, id+1: size(obsts, 1)]));
        ruls(2) = MoveToWithFastBuildPath(coms(sd, 2), pnt, 0, obsts([1:id, id+2: size(obsts, 1)]));
    elseif r_dist_points(coms(sd, 1).z, pntL) < r_dist_points(coms(sd, 1).z, pntR)
        ruls(1) = MoveToLinear(coms(sd, 1), pntL, 1/750, 20, 10);
        ruls(2) = MoveToLinear(coms(sd, 2), pntR, 1/750, 20, 10);
    else
        ruls(1) = MoveToLinear(coms(sd, 1), pntR, 1/750, 20, 10);
        ruls(2) = MoveToLinear(coms(sd, 2), pntL, 1/750, 20, 10);
    end
    rotRul = RotateToLinear(coms(sd, 1), ball.z, 3, 10, 0.1);
    ruls(1).SpeedR = rotRul.SpeedR;
    rotRul = RotateToLinear(coms(sd, 2), ball.z, 3, 10, 0.1);
    ruls(2).SpeedR = rotRul.SpeedR;
end

function ruls = gameProc(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY)
    ruls = getEmptyRuls(size(coms, 2));
    %распределяем роли
    activeId = getAttacker(coms(sd, :), ball);
    passiveId = 3 - activeId;
    os = 3-sd;
    oPassiveId = (sd-1)*size(coms,2) + activeId; 
    lD = (os-1)*size(coms,2) + 1;
    rD = lD + size(coms, 2) - 1;
    %определяем позицию пассивного атакующего
    height = abs(field(1, 1) - field(2, 1));
    width = abs(field(1, 2) - field(2, 2));
    rV = [Vs(sd, 2), -Vs(sd, 1)];
    if activeId == 1
        P = goals(sd, :) + Vs(sd, :) * height * 0.5 + rV * width * 0.4;
    else
        P = goals(sd, :) + Vs(sd, :) * height * 0.8 - rV * width * 0.4;
    end
    %высчитываем управление
    if ballInGameZone(ball, field)
        ruls(activeId) = activeAttackRole(coms(sd, activeId), ball, coms(os, :), obsts(lD:rD, :), goals(os, :), Vs(os, :));
        ruls(passiveId) = passiveAttackRole(coms(sd, passiveId), ball, goals(os, :), Vs(os, :), P, obsts([1:oPassiveId-1, oPassiveId+1:size(obsts, 1)], :));
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
    
    %Если можем хорошо ударить по воротам, то бьём
    if checkDir(dir, ball, oppObst, G, oppV) && agent.isBallInside
        disp('shoot');
        rul = Crul(0, 0, 1, 0, 0);
    else
        [ownerId, own] = getBallOppOwner(ball, oppCom, smallDist);
        %Если какой-то робот противника слишком близко приблизился к мячу
        %то выполняется алгоритм перехвата мяча, инача выполняются
        %процедуры по подъезду и прицеливанию для удара по воротам
        if own && inHalfPlane(oppCom(ownerId).z, agent.z, dir)
            vec = ball.z - oppCom(ownerId).z;
            vec = vec / norm(vec);
            if  r_dist_points(agent.z, ball.z) < smallDist
                disp('stealBall');
                rul = stealBall(agent, ball.z, oppCom(ownerId), oppObst);
            else
                disp('hold dist');
                rul = MoveToLinear(agent, ball.z + vec * 400, 0, 30, 30);
                rotRul = RotateToLinear(agent, ball.z, 3, 10, 0.1);
                rul.SpeedR = rotRul.SpeedR;
            end
        else
            disp('take aim');
            if r_dist_points(agent.z, ball.z) < ownerDist
                %здесь начнутся проблемы когда добавим вратарей
                rul = optDirGoalAttack(agent, ball, oppCom, G, oppV);
            else
                disp('tuti')
                rul = MoveToWithFastBuildPath(agent, ball.z, 0, oppObst);
                rotRul = RotateToLinear(agent, ball.z, 3, 10, 0.1);
                rul.SpeedR = rotRul.SpeedR;
            end
        end
    end
end

function rul = passiveAttackRole(agent, ball, oppG, oppV, P, obsts)
    %заглушка
    rul = MoveToWithFastBuildPath(agent, P, 100, obsts);
end

function res = ballInGameZone(ball, field)
    res = field(1, 1) <= ball.x && ball.x <= field(2, 1) && ...
        field(1, 2) <= ball.y && ball.y <= field(2, 2);
end

function res = lookAtGoal(v, dir, ball, oppG, oppV)
    pnt = lineIntersect(ball.z, dir, oppG, [oppV(2), -oppV(1)]);
    res = r_dist_points(pnt, oppG) < v && scalMult(dir, pnt - ball.z) > 0;
end

function res = checkDir(dir, ball, oppObst, oppG, oppV)
    v = 300; %размер ворот
    R = 100; %радиус роботов
    k = 2.5;   %скорость мяча делённая на скорость робота
    F = ball.z + dir * 100000;
    res = lookAtGoal(v, dir, ball, oppG, oppV);
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

function ruls = getEmptyRuls(comSize)
    ruls(comSize, 1) = Crul(0, 0, 0, 0, 0);
    for k = 1: comSize
        ruls(k) = Crul(0, 0, 0, 0, 0);
    end
end
