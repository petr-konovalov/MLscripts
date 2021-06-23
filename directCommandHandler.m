function ruls = directCommandHandler(sd, ks, coms, ball, BPosHX, BPosHY, BState, Gs, Vs, obstacles, goalSizes)
	if sd == ks
		ruls = freeKick(coms(sd, :), ball, getKickPoint(sd, ball, coms, Gs(3-sd, :), Vs(3-sd, :)), BPosHX, BPosHY, obstacles);
	else
		keeperId = size(coms, 2);
		ruls = passiveDirectBahaviour(sd, coms(:, 1:keeperId-1), ball, BState, Gs, Vs, obstacles, goalSizes);
		ruls(keeperId) = GoalKeeperOnLine(coms(sd, keeperId), Gs(sd, :) + Vs(sd, :) * 150, Vs(sd, :), BPosHX, BPosHY, BState.BStand, BState.BSpeed);
	end
end

function ruls = passiveDirectBahaviour(sd, coms, ball, BState, Gs, Vs, obstacles, goalSizes)
	ruls = stopCommandHandler(sd, coms, ball, BState, Gs, Vs, obstacles, goalSizes);
end

function pnt = getKickPoint(sd, ball, coms, G, V)
	global curTime;
	persistent attackGoalFlag;
	persistent initTime;
	if isempty(attackGoalFlag) || isempty(initTime)
		attackGoalFlag = [true, true];
		initTime = [curTime, curTime];
	end
	if isempty(attackGoalFlag) || curTime - initTime(sd) > 0.5
		attackGoalFlag(sd) = randi(100) > 30;
		initTime(sd) = curTime;
	end
	if attackGoalFlag
		ortV = [V(2), -V(1)];
		pnt = G + ortV * 230;
	else
		ballFiltDist = 1500;
		minDist = 1000000;
		pnt = [0, 0];
		for k = 1: size(coms, 2)-1
			curDist = norm(coms(sd, k).z-G);
			if curDist < minDist && norm(coms(sd, k).z-ball.z) > ballFiltDist
				minDist = curDist;
				pnt = coms(sd, k).z;
			end
	 	end
	 end
end

