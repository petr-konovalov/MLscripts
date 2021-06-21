%sd - сторона за которую играет (1 или 2)
%coms(side) - команда за которую играет coms(3 - side) - друга€ комнада
%первые два игрока команды должы быть атакующими
%obst - расположение и радиусы объектов
%goals(side) - центр наших ворот obst(3 - side) - других
%Vs(side) - направление наших ворот Vs(3 - side) - других
%field(1) - левый нижний угол пол€, field(2) - правый верхний

function ruls = gameModel(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY, status, goalSizes)
    ActiveStartStatus = 1;
    PassiveStartStatus = 2;
    GameProcStatus = 3;
    StopGameStatus = 4;
    keeperId = size(coms, 2);
    
    if nargin <= 11
    	goalSizes = [1200, 2400];
    end
    
    ballZone = getBallZone(field, goals(sd, :), Vs(sd, :), goals(3-sd, :), Vs(3-sd, :), goalSizes, ball);
    
    switch status
        case ActiveStartStatus
            ruls = gameActiveStart(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY);
        case PassiveStartStatus
            ruls = gamePassiveStart(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY);
        case GameProcStatus
            ruls = gameProc(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY, ballZone, goalSizes);
        case StopGameStatus
            ruls = getEmptyRuls(size(coms, 2));
    end
    
    %¬ратарь
    if status ~= StopGameStatus
    	if bitand(ballZone, 2) == 2 && BState.BStand 
    		ruls(keeperId) = attack(coms(sd, keeperId), ball, coms(sd, 1).z, 2);
    		ruls(keeperId).KickVoltage = 3;
    	else
       		ruls(keeperId) = GoalKeeperOnLine(coms(sd, keeperId), goals(sd, :) + Vs(sd, :) * 150, Vs(sd, :), BPosHX, BPosHY, BState.BStand, BState.BSpeed);
       	end
    end
end

function res = getBallZone(field, ownG, ownV, oppG, oppV, goalSizes, ball)
	res = uint8(0);
	if ballInGameZone(ball, field)
		res = bitxor(res, 1);
	end
	if ballInGoalZone(ownG, ownV, goalSizes, ball.z)
		res = bitxor(res, 2);
	end
	if ballInGoalZone(oppG, oppV, goalSizes, ball.z)
		res = bitxor(res, 4);
	end
end

function ruls = gameActiveStart(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY)
    %один робот едет на центр и бьЄт по мачу верхним ударом, другой
    %где-то позади становитс€
    ruls = getEmptyRuls(size(coms, 2));
    oppV = Vs(3 - sd, :);
    ballAttackDist = 100;
    %id = (sd-1)*size(coms,2) + 1; 
    if inHalfStrip(coms(sd, 1).z, ball.z, oppV, 50)
    	%disp('k1');
        ruls(1) = MoveToConstAcc(coms(sd, 1), ball.z, 0, 95, 10);
    else
    	%disp('k2');
        ruls(1) = MoveToWithFastBuildPath(coms(sd, 1), ball.z + oppV * 500, 100, obsts); 
    end
    if norm([ruls(1).SpeedX, ruls(1).SpeedY]) < 40
    	rotRul = RotateToLinear(coms(sd, 1), ball.z - oppV * 500, 3, 10, 0.01);
    	ruls(1).SpeedR = rotRul.SpeedR;
    end
    if r_dist_points(coms(sd, 1).z, ball.z) < ballAttackDist
    	ruls(1).AutoKick = 2;
    	ruls(1).KickVoltage = 3;
    end
    
    %disp(ball.z);
    %disp(obsts);
    ruls(2) = MoveToWithFastBuildPath(coms(sd, 2), oppV * 1500, 100, obsts);
    if norm([ruls(2).SpeedX, ruls(2).SpeedY]) < 40
    	rotRul = RotateToLinear(coms(sd, 2), ball.z, 5, 15, 0.03);
    	ruls(2).SpeedR = rotRul.SpeedR;
   	end
end

function ruls = gamePassiveStart(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY)
    ruls = getEmptyRuls(size(coms, 2));
    oppV = Vs(3 - sd, :);
    %id = (sd-1)*size(coms,2) + 1;
    pnt = ball.z + oppV * 1200;
    pntL = pnt + [oppV(2), -oppV(1)] * 70;
    pntR = pnt - [oppV(2), -oppV(1)] * 70;
    bigDist = 300;
    if r_dist_points(coms(sd, 1).z, pnt) > bigDist || r_dist_points(coms(sd, 2).z, pnt) > bigDist
        ruls(1) = MoveToWithFastBuildPath(coms(sd, 1), pnt, 0, obsts);
        ruls(2) = MoveToWithFastBuildPath(coms(sd, 2), pnt, 0, obsts);
    else
		if r_dist_points(coms(sd, 1).z, pntL) < r_dist_points(coms(sd, 1).z, pntR)
		    ruls(1) = MoveToConstAcc(coms(sd, 1), pntL, 0, 0);
		    ruls(2) = MoveToConstAcc(coms(sd, 2), pntR, 0, 0);
		else
		    ruls(1) = MoveToConstAcc(coms(sd, 1), pntR, 0, 0);
		    ruls(2) = MoveToConstAcc(coms(sd, 2), pntL, 0, 0);
		end
		rotRul = RotateToLinear(coms(sd, 1), ball.z, 5, 20, 0.03);
		ruls(1).SpeedR = rotRul.SpeedR;
		rotRul = RotateToLinear(coms(sd, 2), ball.z, 5, 20, 0.03);
		ruls(2).SpeedR = rotRul.SpeedR;
    end
end

function ruls = gameProc(sd, coms, obsts, ball, goals, Vs, field, BState, BPosHX, BPosHY, ballZone, goalSizes)
    persistent dis disLastUpdTime;
    global curTime;
    ruls = getEmptyRuls(size(coms, 2));
    %распредел€ем роли
    activeId = getAttacker(coms(sd, :), ball);
    passiveId = mod(activeId, 6)+1;
    os = 3-sd;
    oPassiveId = (sd-1)*size(coms,2) + activeId; 
    lD = (os-1)*size(coms,2) + 1;
    rD = lD + size(coms, 2) - 1;
    %определ€ем позицию пассивного атакующего
    height = abs(field(1, 1) - field(2, 1));
    width = abs(field(1, 2) - field(2, 2));
    rV = [Vs(sd, 2), -Vs(sd, 1)];
    P = getPassPoints(goals(sd, :), Vs(sd, :));
	pAttackers = getAgentsPos(coms(sd, [1:activeId-1, activeId+1:size(coms, 2)-1]));
	%disp(activeId);
	if isempty(dis)
		dis = zeros(2, 4);
	end
	if dis(sd, 1) == 0 || curTime - disLastUpdTime > 0.3
		AD = minMaxEdgeBFAD(pAttackers, P);
        dis(sd, :) = AD.getDistribution;
		disLastUpdTime = curTime;
	end
    %высчитываем управление
    if ballZone == 1
        ruls(activeId) = activeAttackRole(coms(sd, activeId), coms(sd, [1:activeId-1, activeId+1:size(coms, 2)-1]), ball, BState, coms(os, :), obsts(lD:rD, :), goals(os, :), Vs(os, :));
        %ruls(passiveId) = passiveAttackRole(coms(sd, passiveId), ball, goals(os, :), Vs(os, :), P, obsts([1:oPassiveId-1, oPassiveId+1:size(obsts, 1)], :));
        j = 1;
        for k = [1: activeId-1, activeId+1:size(coms, 2)-1]
        	ruls(k) = passiveAttackRole(coms(sd, k), BState, ball, goals(os, :), Vs(os, :), P(dis(sd, j), :), obsts, goals, Vs, goalSizes);
        	j = j + 1;
        end
    elseif bitand(ballZone, 2) == 2
    	ruls(activeId) = MoveToWithFastBuildPath(coms(sd, activeId), [0, 0], 100, obsts); 
    elseif bitand(ballZone, 4) == 4
    	ruls(activeId) = Crul(0, 0, 0, 0, 0);
    end
end

function pnts = getPassPoints(G, V)
	ortV = [V(2), -V(1)];
	pnts = [
		G + 6000 * V - ortV * 2000;
		G + 6000 * V + ortV * 2000;
		G + 2000 * V - ortV * 300;
		G + 2000 * V + ortV * 300
	];
end

function agentsPos = getAgentsPos(agents)
	agentsPos = zeros(size(agents, 1), 2);
	for k = 1: size(agents, 2)
		agentsPos(k, :) = agents(k).z;
	end
end

function rul = activeAttackRole(agent, friends, ball, BState, oppCom, oppObst, oppG, oppV)
    persistent timeDetermined;
    persistent wasDetermined;
    passSegLen = 20;
    
    dir = [cos(agent.ang), sin(agent.ang)];
    smallDist = 150;
    ownerDist = 250;
    ownerAngle = pi/6.2;
    G = oppG - oppV * 400;
    catchArea = 1500;
	tauchArea = 35;
	ballCatching = true;
    
    if isempty(timeDetermined)
        timeDetermined = 0;
    end
    
    if isempty(wasDetermined)
        wasDetermined = true;
    end
    
    agent.isBallInside = inRect(ball.z, agent.z, dir, 30, 100);
    %disp('is ball inside');
    %disp(agent.isBallInside);
    if BState.BFast
    	proec = ball.z + normir(BState.BSpeed) * dot(agent.z-ball.z, BState.BSpeed);
    	if norm(proec - agent.z) < tauchArea && inHalfPlane(agent.z, ball.z, BState.BSpeed)
    		rul = RotateToLinear(agent, ball.z, 3, 10, 0.1);
   		elseif norm(proec - agent.z) < catchArea && inHalfPlane(agent.z, ball.z, BState.BSpeed) && ~pntInZone(proec, getGoalZone(Gs(1, :), Vs(1, :), goalSizes)) && ~pntInZone(proec, getGoalZone(Gs(2, :), Vs(2, :), goalSizes))
    		rul = MoveToWithFastBuildPath(agent, proec, 30, obsts);
    	else
    		ballCatching = false;
    	end
    end
    
    if ballCatching
		%≈сли можем хорошо ударить по воротам, то бьЄм
		if checkDir(dir, ball, oppObst, G, oppV) && agent.isBallInside
		    %disp('shoot');
		    rul = Crul(10, 0, 1, 0, 0);
		else
		    [ownerId, own] = getBallOppOwner(ball, oppCom, ownerDist);
		    %≈сли какой-то робот противника слишком близко приблизилс€ к м€чу
		    %то выполн€етс€ алгоритм перехвата м€ча, иначе выполн€ютс€
		    %процедуры по подъезду и прицеливанию дл€ удара по воротам
		    %disp(own && inHalfPlane(oppCom(ownerId).z, agent.z - dir * 200, dir));
		    if own && inHalfPlane(oppCom(ownerId).z, agent.z - dir * 200, dir)
		        disp('stealBall');
		       	rul = stealBall(agent, ball.z, oppCom(ownerId), oppObst);
		       	rul.EnableSpinner = true;
		       	rul.SpinnerSpeed = 1000000;
		       	if randi(100) > 97
				   	rul.KickVoltage = 2;
				   	rul.AutoKick = 1;
				end
		    else
		        %disp('take aim');
		        if findRobotsOnStrip(getOpenFriends(friends, oppCom, agent), agent.z, dir, 1500, 400) && agent.isBallInside
		            %disp('pass');
		            %≈сли смотрим на сокомандника и можем ударить, делаем это
		            rul = Crul(10, 0, 0, 0, 1);
		            rul.KickVoltage = 3;
		        elseif r_dist_points(agent.z, ball.z) < ownerDist && inHalfStrip(ball.z, agent.z, dir, 70)
		            %здесь начнутс€ проблемы когда добавим вратарей
		            [rul, isDetermined] = optDirGoalAttack(agent, ball, oppCom, G, oppV);
		            curTime = cputime();
		            if isDetermined
		                if wasDetermined
		                    timeDetermined = curTime;
		                    wasDetermined = true;
		                elseif curTime - timeDetermined > passSegLen
		                    wasDetermined = true;
		                end
		            else
		                wasDetermined = false;
		            end
		            if ~wasDetermined
		                %если ворота не просматриваютс€, то делаем пас
		                %сокоманднику верхним ударом
		                friend = getNearestOpenFriend(friends, oppCom, agent, dir);
		                rul = attack(agent, ball, friend.z, 2);
		            end
		        else
		            %disp('tuti');
		            rul = MoveToWithFastBuildPath(agent, ball.z, 0, oppObst);
		            rotRul = RotateToLinear(agent, ball.z, 3, 10, 0.1);
		            rul.SpeedR = rotRul.SpeedR;
		        end
		    end
		end
	end
end

function res = getNearestOpenFriend(friends, oppCom, agent, dir)
	ang = 2*pi;
	res = friends(randi(size(friends, 2)));
	for friend = getOpenFriends(friends, oppCom, agent)
		curAng = abs(getAngle(friends(1).z-agent.z, dir));
		if curAng <= ang
			res = friend;
			and = curAng;
		end
	end
end

function res = getOpenFriends(friends, oppCom, agent)
	thresholdAng = pi/12;
	res = [];
	for friend = friends
		dir = normir(friend.z - agent.z);
		if ~findRobotOnSector(oppCom, agent.z, dir, thresholdAng)
			res = [res, friend];
		end
	end
end

function res = findRobotsOnStrip(robots, origin, dir, gap, width)
	res = false;
	for robot = robots
		res = res || inHalfStrip(robot.z, origin + dir * gap, dir, width);
	end
end

function res = findRobotOnSector(robots, origin, dir, thresholdAng)
	res = false;
	for robot = robots
		res = res || abs(getAngle(robot.z-origin, dir)) < thresholdAng;
	end
end

function rul = passiveAttackRole(agent, BState, ball, oppG, oppV, P, obsts, Gs, Vs, goalSizes)
	catchArea = 1500;
	tauchArea = 35;
	if BState.BStand
    	rul = MoveToWithFastBuildPath(agent, P, 100, obsts);
    else
    	proec = ball.z + normir(BState.BSpeed) * dot(agent.z-ball.z, BState.BSpeed);
    	if norm(proec - agent.z) < tauchArea && inHalfPlane(agent.z, ball.z, BState.BSpeed)
    		rul = RotateToLinear(agent, ball.z, 3, 10, 0.1);
   		elseif norm(proec - agent.z) < catchArea && inHalfPlane(agent.z, ball.z, BState.BSpeed) && ~pntInZone(proec, getGoalZone(Gs(1, :), Vs(1, :), goalSizes)) && ~pntInZone(proec, getGoalZone(Gs(2, :), Vs(2, :), goalSizes))
    		rul = MoveToWithFastBuildPath(agent, proec, 30, obsts);
    	else
    		rul = MoveToWithFastBuildPath(agent, P, 100, obsts);
    	end
    end
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
    k = 2.5;   %скорость м€ча делЄнна€ на скорость робота
    F = ball.z + dir * 100000;
    res = lookAtGoal(v, dir, ball, oppG, oppV);
    for k = 1: size(oppObst, 1)
        pnts = SegmentCircleIntersect(ball.x, ball.y, F(1), F(2), oppObst(k, 1), oppObst(k, 2), R);
        if numel(pnts) > 0
            res = false;
            break;
        end
    end
    %disp(attackDirectQuality(dir, ball.z, oppObst, R, k));
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
