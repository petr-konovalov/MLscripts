function ruls = freeKick(com, ball, kickPoint, BPosHX, BPosHY, obstacles, kickType, kickVoltage)
	global curTime oldTime;
	persistent state;
	if nargin <= 6
		kickType = 2;
	end
	if nargin <= 7
		kickVoltage = 3;
	end
	ballAttackDist = 100;
	robotRotThreshold = 5;
	ruls = getEmptyRuls(size(com, 2));
	ball = getFilteredBall(ball, BPosHX, BPosHY);
	attackerId = getAttacker(com, ball);
	attacker = com(attackerId);
	if isempty(state) || norm(ball.z-attacker.z) > 1000 || curTime - oldTime > 1
		state = 0;
	end
	middlePoint = getMiddlePoint(attacker, ball, kickPoint);
	switch state
		case 0
			ruls(attackerId) = MoveToWithFastBuildPath(attacker, middlePoint, 50, [obstacles; ball.x ball.y 150], 30);
			if norm(attacker.z-middlePoint) < 100
				state = 1;
			end
		case 1
			ruls(attackerId) = RotateToLinear(attacker, kickPoint, 3, 10, 0.01);
			if abs(ruls(attackerId).SpeedR) < robotRotThreshold
				movRul = MoveToConstAcc(attacker, ball.z, 0, 95, 10);
				ruls(attackerId).SpeedX = movRul.SpeedX;
				ruls(attackerId).SpeedY = movRul.SpeedY;
			end
			if norm(attacker.z-ball.z) < ballAttackDist
				ruls(attackerId).AutoKick = kickType;
				ruls(attackerId).KickVoltage = kickVoltage;
			end
	end
end

function pnt = getMiddlePoint(attacker, ball, kickPoint)
	pnt = ball.z + normir(ball.z-kickPoint) * 400;
end

function ball = getFilteredBall(ball, BPosHX, BPosHY)
	ball.z = stableBallFiltering(BPosHX, BPosHY);
	ball.x = ball.z(1);
	ball.y = ball.z(2);
end
