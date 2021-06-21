function ruls = directCommandHandler(sd, ks, coms, ball, BPosHX, BPosHY, BState, Gs, Vs, obstacles, goalSizes)
	if sd == ks
		ruls = freeKick(coms(sd, :), ball, getKickPoint(sd, ball, coms, Gs), BPosHX, BPosHY, obstacles);
	else
		keeperId = size(coms, 2);
		ruls = passiveDirectBahaviour(sd, coms(:, 1:keeperId-1), ball, BState, Gs, Vs, obstacles, goalSizes);
		ruls(keeperId) = GoalKeeperOnLine(coms(sd, keeperId), Gs(sd, :) + Vs(sd, :) * 150, Vs(sd, :), BPosHX, BPosHY, BState.BStand, BState.BSpeed);
	end
end

function ruls = passiveDirectBahaviour(sd, coms, ball, BState, Gs, Vs, obstacles, goalSizes)
	ruls = stopCommandHandler(sd, coms, ball, BState, Gs, Vs, obstacles, goalSizes);
end

function pnt = getKickPoint(sd, ball, coms, Gs)
	ballFiltDist = 1500;
	minDist = 1000000;
	pnt = [0, 0];
	for k = 1: size(coms, 2)
		curDist = norm(coms(sd, k).z-Gs(3-sd, :))
		if curDist < minDist && norm(coms(sd, k).z-ball.z) > ballFiltDist
			pnt = coms(sd, k).z;
		end
 	end
end

