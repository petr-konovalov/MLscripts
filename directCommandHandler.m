function ruls = directCommandHandler(sd, ks, coms, ball, BState, BPosHX, BPosHY, BState, Gs, Vs, obstacles, goalSizes)
	if sd == ks
		ruls = freeKick(coms(sd, :), ball, getKickPoint(), BPosHX, BPosHY, obstacles);
	else
		keeperId = size(coms, 2);
		ruls = passiveDirectBahaviour(sd, coms(:, 1:keeperId-1), ball, BState, Gs, Vs, obstacles, goalSizes);
		ruls(keeperId) = GoalKeeperOnLine(coms(sd, keeperId), Gs(sd, :) + Vs(sd, :) * 150, Vs(sd, :), BPosHX, BPosHY, BState.BStand, BState.BSpeed);
	end
end

function ruls = passiveDirectBahaviour(sd, coms, ball, BState, Gs, Vs, obstacles, goalSizes)
	ruls = stopCommandHandler(sd, coms, ball, BState, Gs, Vs, obstacles, goalSizes);
end

function pnt = getKickPoint()
	pnt = [0, 0];
end

