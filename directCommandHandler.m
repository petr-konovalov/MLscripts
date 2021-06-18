function ruls = directCommandHandler(sd, coms, ball, BPosHX, BPosHY, obstacles)
	global curTime oldTime
	persistent state;
	ruls = getEmptyRuls(size(coms, 2));
	ball = getFilteredBall(ball, BPosHX, BPosHY);
	attackerId = getAttacker(coms(sd, :), ball)
	attacker = coms(sd, attackerId);
	if isempty(state) || norm(ball.z-attacker.z) > 1000 || curTime - oldTime > 1
		state = 0;
	end
	switch state
		case 0
			ruls(attackerId) = 		
		case 1
				
	end
end

function ball = getFilteredBall(ball, BPosHX, BPosHY)
	ball.z = stableBallFiltering(BPosHX, BPosHY);
	ball.x = ball.z(1);
	ball.y = ball.z(2);
end

function pnt = getKickingPoint(attacker, ball)
	pnt = ball.z + normir(ball.z) * 500;
end

