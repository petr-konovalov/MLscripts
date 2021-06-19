function ruls = penaltyCommandHandler(sd, ks, coms, ball, BPosHX, BPosHY, BState, Gs, Vs, obstacles, goalSizes, isPreparation)
	if sd == ks && ~isPreparation
		ortV = [Vs(3-sd, 2), -Vs(3-sd, 1)];
		ruls = freeKick(coms(sd, :), ball, Gs(3-sd, :)+ortV*400, BPosHX, BPosHY, obstacles, 1, 3);
	else
		if sd == ks && isPreparation
			activeId = getAttacker(coms(sd, :), ball);
			ruls(activeId) = MoveToWithFastBuildPath(coms(sd, activeId), ball.z+Vs(3-sd, :)*500, 50, [obstacles; ball.x ball.y 300], 30);
		else
			activeId = getNearestAgentToPoint(coms(sd, 1:size(coms, 2)-1), Gs(sd, :)+Vs(sd, :)*goalSizes(1));
			ruls(activeId) = MoveToWithFastBuildPath(coms(sd, activeId), Gs(sd, :)+Vs(sd, :)*goalSizes(1), 50, [obstacles; ball.x ball.y 500], 30);
		end
		keeperId = size(coms, 2);
		for k = [1: activeId-1, activeId+1:size(coms, 2)-1]
			ruls(k) = goToCenterLine(coms(sd, k), ball, obstacles);
		end
		ruls(keeperId) = GoalKeeperOnLine(coms(sd, keeperId), Gs(sd, :)+Vs(sd, :) * 150, Vs(sd, :), BPosHX, BPosHY, BState.BStand, BState.BSpeed);
	end
end

function rul = goToCenterLine(agent, ball, obstacles)
	rul = MoveToWithFastBuildPath(agent, [0, agent.y], 50, [obstacles; ball.x ball.y 500], 30);
end

