function ruls = stopCommandHandler(sd, coms, ball, Gs, Vs, obstacles, goalSizes, gap, normalSpeed)
	ruls = getEmptyRuls(size(coms, 2));
	ballDist = 500;
	defStep = 500;
	rndStep = 200;
	if nargin <= 6 
		goalSizes = [1000, 2000]; 
	end
	if nargin <= 7 
		gap = 700; 
	end
	if nargin <= 8 
		normalSpeed = 10; 
	end
	gapedGoalSizes = goalSizes + [1, 2] * gap;
	gapedBallDist = ballDist + gap;
	for k = 1: size(coms, 2)-1
		ruls(k) = attackerStopHandler(coms(sd, k), ball, Gs, Vs, obstacles, gapedBallDist, gapedGoalSizes, defStep, rndStep, normalSpeed);
	end
	ruls(size(coms, 2)) = keeperStopHandler(coms(sd, size(coms, 2)), ball, Gs(sd, :), Vs(sd, :), obstacles, gapedBallDist, defStep, rndStep, normalSpeed);
end

function rul = attackerStopHandler(agent, ball, Gs, Vs, obstacles, gapedBallDist, goalSizes, defStep, rndStep, normalSpeed)
	rul = Crul(0, 0, 0, 0, 0);
	rngAng = 2*pi*rand(1, 1);
	rndDir = rndStep*[cos(rngAng), sin(rngAng)];
	if norm(agent.z - ball.z) < gapedBallDist
		rul = MoveToWithFastBuildPath(agent, agent.z+defStep*normir(agent.z-ball.z)+rndDir, 20, obstacles, normalSpeed);
	elseif ballInGoalZone(Gs(1, :), Vs(1, :), goalSizes, agent.z)
		rul = MoveToWithFastBuildPath(agent, agent.z+defStep*normir(agent.z-Gs(1, :))+rndDir, 20, obstacles, normalSpeed); 
	elseif ballInGoalZone(Gs(2, :), Vs(2, :), goalSizes, agent.z)	
		rul = MoveToWithFastBuildPath(agent, agent.z+defStep*normir(agent.z-Gs(2, :))+rndDir, 20, obstacles, normalSpeed);
	end
end

function rul = keeperStopHandler(agent, ball, G, V, obstacles, gapedBallDist, defStep, rndStep, normalSpeed)
	rul = Crul(0, 0, 0, 0, 0);
	if norm(agent.z - ball.z) < gapedBallDist
		rngAng = 2*pi*rand(1, 1);
		rndDir = rndStep*[cos(rngAng), sin(rngAng)];
		rul = MoveToWithFastBuildPath(agent, agent.z+defStep*normir(agent.z-ball.z)+rndDir, 20, obstacles, normalSpeed);
	elseif norm(ball.z - G) > gapedBallDist
		rul = MoveToWithFastBuildPath(agent, G+V*400, 20, obstacles, normalSpeed);
	end
end
